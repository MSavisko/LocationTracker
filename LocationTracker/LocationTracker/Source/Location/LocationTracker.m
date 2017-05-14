//
//  LocationTracker.m
//  LocationTracker
//
//  Created by Maksym Savisko on 5/13/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "LocationTracker.h"
#import "LocationConfiguration.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationTracker () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocationManager *locationTimerManager;
@property (nonatomic, strong) NSTimer *scheduleTimer;

@property (nonatomic) BOOL deferringUpdates;
@property (nonatomic) NSDate *lastLocationTime;

@property (nonatomic) NSMutableSet <id <LocationTrackerObserver>> *observers;
@property (nonatomic, strong) NSSortDescriptor *timeStamplocationDescriptor;

@end

@implementation LocationTracker

#pragma mark - Initialization Methods

+ (nullable instancetype) defaultTracker
{
    return [self trackerWithConfiguration:[LocationConfiguration defaultConfiguration]];
}

+ (nullable instancetype) trackerWithConfiguration:(nonnull LocationConfiguration *) configuration
{
    return [[self alloc] initWithConfiguration:configuration];
}

- (nullable instancetype) initWithConfiguration:(nonnull LocationConfiguration *) configuration
{
    self = [super init];
    
    if (self)
    {
        [self initLocationManager];
        [self initTimerLocationManager];
        [self initObservers];
        [self initNotifications];
        _configuration = configuration;
    }
    
    return self;
}

- (void) initLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.observers = [NSMutableSet set];
}

- (void) initTimerLocationManager
{
    self.locationTimerManager = [[CLLocationManager alloc] init];
    self.locationTimerManager.delegate = self;
}

- (void) initObservers
{
    self.observers = [NSMutableSet set];
}

- (void) initNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeferringState:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeferringState:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods

+ (BOOL) isLocationServiceRequested
{
    return ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined);
}

+ (BOOL) isServiceEnabled
{
    if ([CLLocationManager locationServicesEnabled])
    {
        CLAuthorizationStatus const authStatus = [CLLocationManager authorizationStatus];
        switch (authStatus)
        {
            case kCLAuthorizationStatusAuthorizedWhenInUse:
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusNotDetermined:
                return YES;
                break;
            case kCLAuthorizationStatusRestricted:
            case kCLAuthorizationStatusDenied:
                return NO;
                break;
        }
    }
    
    return NO;
}

- (void)start
{
    if (!_isStarted)
    {
        if ([self.class isServiceEnabled])
        {
            [self updateConfiguration:_configuration];
            [self.locationManager requestAlwaysAuthorization];
            [self.locationManager startUpdatingLocation];
            _isStarted = YES;
        }
    }
}

- (void)stop
{
    [self.locationManager stopUpdatingLocation];
    [self stopScheduleTimer];
    [self.locationTimerManager stopUpdatingLocation];
    _isStarted = NO;
}

- (nullable CLLocation *) lastLocation
{
    CLLocation *distanceLocation = self.locationManager.location;
    CLLocation *timerLocation = self.locationTimerManager.location;
    
    if (!distanceLocation && !timerLocation)
    {
        return nil;
    }
    else if (!distanceLocation && timerLocation)
    {
        return timerLocation;
    }
    else if (distanceLocation && !timerLocation)
    {
        return distanceLocation;
    }
    
    if (distanceLocation.horizontalAccuracy < 0. && timerLocation.horizontalAccuracy < 0.)
    {
        return nil;
    }
    
    NSComparisonResult dateCompare = [distanceLocation.timestamp compare:timerLocation.timestamp];
    
    if (dateCompare == NSOrderedSame && dateCompare == NSOrderedDescending)
    {
        return distanceLocation;
    }
    else
    {
        return timerLocation;
    }
}

#pragma mark - LocationTrackerObserver Methods

- (void) addObserver:(id <LocationTrackerObserver>)observer
{
    if ([self.class isServiceEnabled])
    {
        [self.observers addObject:observer];
    }
    else
    {
        [self observer:observer onLocationError:[NSError lt_errorWithCode:kCLErrorDenied]];
    }
}

-(void) removeObserver:(id <LocationTrackerObserver>)observer {
    [self.observers removeObject:observer];
}

- (void)observer:(id<LocationTrackerObserver>)observer onLocationError:(NSError *) error
{
    if ([(NSObject *)observer respondsToSelector:@selector(onLocationError:)])
    {
        [observer onLocationError:error];
    }
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [self processLocation:[self latestLocationFromList:locations]];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self processLocationError:error];
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    [self processLocationError:error];
}

#pragma mark - Properties

- (NSSortDescriptor *) timeStamplocationDescriptor
{
    if (_timeStamplocationDescriptor == nil)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NSStringFromSelector(@selector(timestamp))
                                                                       ascending:NO];
        _timeStamplocationDescriptor = sortDescriptor;
    }
    
    return _timeStamplocationDescriptor;
}

- (BOOL) deferringUpdates
{
    return _deferringUpdates && [CLLocationManager deferredLocationUpdatesAvailable] &&
    [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
}

#pragma mark - Configuration Methods

- (void) updateConfiguration:(nonnull LocationConfiguration *) configuration
{
    self.locationManager.desiredAccuracy = configuration.desiredAccuracy;
    self.locationManager.distanceFilter = configuration.distanceFilter;
    
    self.locationTimerManager.desiredAccuracy = configuration.desiredAccuracy;
    self.locationTimerManager.distanceFilter = kCLDistanceFilterNone;
    
    if (configuration.allowTimeFilter)
    {
        [self startScheduleTimerWithInterval:configuration.timeFilter];
    }
    else
    {
        [self stopScheduleTimer];
    }
    
    if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)])
    {
        self.locationManager.allowsBackgroundLocationUpdates = configuration.allowBackgroundUpdates;
        self.locationTimerManager.allowsBackgroundLocationUpdates = configuration.allowBackgroundUpdates;
    }
}

- (void) updateDeferringState:(NSNotification *) notification
{
    /*
    if (notification.name == UIApplicationWillResignActiveNotification && _configuration.allowDeferredUpdates && self.isStarted)
    {
        [self stopScheduleTimer];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.locationManager allowDeferredLocationUpdatesUntilTraveled:_configuration.distanceFilter timeout:_configuration.timeFilter];
        });
    }
    else if (notification.name == UIApplicationWillEnterForegroundNotification && _configuration.allowDeferredUpdates && self.isStarted)
    {
        [self startScheduleTimerWithInterval:_configuration.timeFilter];
        [self.locationManager disallowDeferredLocationUpdates];
        _locationManager.distanceFilter = _configuration.distanceFilter;
    }
    */
}

#pragma mark - Private Location Methods

- (void)processLocation:(CLLocation *)location
{
    if (location.horizontalAccuracy < 0.)
    {
        return;
    }
    
    self.lastLocationTime = [NSDate date];
    
    for (id observer in self.observers.copy)
    {
        [observer onLocationUpdate:location];
    }
}

- (void)processLocationError:(NSError *) error
{
    if (![self isLocationUnknownError:error])
    {
        for (id observer in self.observers.copy)
        {
            [observer onLocationError:[NSError lt_errorWithCode:error.code]];
        }
    }
}

- (void) quickRequestLocation
{
    if (self.isStarted)
    {
        [self.locationTimerManager requestAlwaysAuthorization];
        [self.locationTimerManager requestLocation];
    }
}

#pragma mark - Private Timer Methods

- (void) stopScheduleTimer
{
    [self.scheduleTimer invalidate];
    self.scheduleTimer = nil;
}

- (void) startScheduleTimerWithInterval:(NSTimeInterval)timeInterval
{
    [self stopScheduleTimer];
    
    self.scheduleTimer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(quickRequestLocation) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.scheduleTimer forMode:NSRunLoopCommonModes];
}

#pragma mark - Private Helpers Methods

- (BOOL) isLocationUnknownError:(NSError *) error
{
    return (error.code == kCLErrorLocationUnknown);
}

- (CLLocation *) latestLocationFromList:(NSArray<CLLocation *> *)locationsList
{
    return [self sortLocations:locationsList bySortDescriptors:@[self.timeStamplocationDescriptor]].firstObject;
}

- (NSArray <CLLocation *> *) sortLocations:(NSArray <CLLocation *> *)locations bySortDescriptors:(NSArray <NSSortDescriptor *> *) descriptors
{
    return [locations sortedArrayUsingDescriptors:descriptors];
}


@end

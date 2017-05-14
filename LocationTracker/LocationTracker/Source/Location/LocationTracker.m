//
//  LocationTracker.m
//  LocationTracker
//
//  Created by Maksym Savisko on 5/13/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "LocationTracker.h"
#import "LocationConfiguration.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationTracker () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic) BOOL allowDeferredUpdates;
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
        [self updateConfiguration:configuration];
    }
    
    return self;
}

- (void) initLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
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
            [self.locationManager requestAlwaysAuthorization];
            [self.locationManager startUpdatingLocation];
            _isStarted = YES;
        }
    }
}

- (void)stop
{
    [self.locationManager stopUpdatingLocation];
    _isStarted = NO;
}

- (nullable CLLocation *) lastLocation
{
    if (self.locationManager.location.horizontalAccuracy < 0.) return nil;
    return self.locationManager.location;
}

#pragma mark - LocationTrackerObserver Methods

-(void) addObserver:(id <LocationTrackerObserver>)observer {
    if (!self.isStarted)
    {
        if ([self.class isServiceEnabled])
        {
            [self.observers addObject:observer];
        }
        else
        {
            [self observer:observer onLocationError:[NSError lt_errorWithCode:kCLErrorDenied]];
        }
    } else {
        BOOL updateLocation = ![self.observers containsObject:observer];
        [self.observers addObject:observer];
        if ([self lastLocationIsValid] && updateLocation)
        {
            [observer onLocationUpdate:self.lastLocation];
        }
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

#pragma mark - Configuration Methods

- (void) updateConfiguration:(nonnull LocationConfiguration *) configuration
{
    _configuration = configuration;
    
    if (configuration.allowDeferredUpdates && [CLLocationManager deferredLocationUpdatesAvailable])
    {
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        [self.locationManager allowDeferredLocationUpdatesUntilTraveled:configuration.distanceFilter timeout:configuration.timeFilter];
        self.allowDeferredUpdates = YES;
    }
    else
    {
        self.locationManager.distanceFilter = configuration.distanceFilter;
        [self.locationManager disallowDeferredLocationUpdates];
        self.allowDeferredUpdates = NO;
    }
    
    if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)])
    {
        self.locationManager.allowsBackgroundLocationUpdates = configuration.allowBackgroundUpdates;
    }
    
    self.locationManager.desiredAccuracy = configuration.desiredAccuracy;
}

#pragma mark - Private

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

- (BOOL) isLocationUnknownError:(NSError *) error
{
    return (error.code == kCLErrorLocationUnknown);
}

- (BOOL)lastLocationIsValid
{
    return (([self lastLocation] != nil) && ([self.lastLocationTime timeIntervalSinceNow] > -300.0));
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

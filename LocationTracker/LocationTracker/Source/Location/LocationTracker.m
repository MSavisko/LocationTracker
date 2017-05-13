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

#pragma mark - Public

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

#pragma mark - Update Methods

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

@end

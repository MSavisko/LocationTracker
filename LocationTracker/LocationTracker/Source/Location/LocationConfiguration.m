//
//  LocationConfiguration.m
//  LocationTracker
//
//  Created by Maksym Savisko on 5/13/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "LocationConfiguration.h"
#import <CoreLocation/CLLocation.h>

static NSTimeInterval const kDefaultConfigurationTimeFilter = 300.0;
static double const kDefaultConfigurationDistanceFilter = 200.0;
static BOOL const kDefaultConfigurationDeferredUpdates = YES;
static BOOL const kDefaultConfigurationBackgroundUpdates = YES;

@implementation LocationConfiguration

#pragma mark - Public

+ (instancetype) defaultConfiguration
{
    LocationConfiguration *configuration = [[LocationConfiguration alloc] init];
    configuration.timeFilter = kDefaultConfigurationTimeFilter;
    configuration.distanceFilter = kDefaultConfigurationDistanceFilter;
    configuration.allowDeferredUpdates = kDefaultConfigurationDeferredUpdates;
    configuration.allowBackgroundUpdates = kDefaultConfigurationBackgroundUpdates;
    configuration.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    return configuration;
}

#pragma mark - Initialization

- (instancetype) init
{
    self = [super init];
    
    if (self)
    {
        _timeFilter = 0;
        _distanceFilter = 0;
        _allowDeferredUpdates = NO;
        _allowBackgroundUpdates = NO;
        _desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    return self;
}

@end

//
//  LocationTracker.h
//  LocationTracker
//
//  Created by Maksym Savisko on 5/13/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@class LocationConfiguration;

@interface LocationTracker : NSObject

// clue for improper use (produces compile time error)
- (nullable instancetype)init __attribute__((unavailable("init not available, call defaultTracker instead")));
+ (nullable instancetype) new __attribute__((unavailable("new not available, call defaultTracker instead")));

@property (nonatomic, strong, readonly, nonnull) LocationConfiguration *configuration;
@property (nonatomic, readonly) BOOL isStarted;

+ (nullable instancetype) defaultTracker;
+ (nullable instancetype) trackerWithConfiguration:(nonnull LocationConfiguration *) configuration;

+ (BOOL) isLocationServiceRequested;
+ (BOOL) isServiceEnabled;

- (void)start;
- (void)stop;

- (nullable CLLocation *) lastLocation;

@end

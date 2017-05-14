//
//  LTDataHelper+Location.h
//  LocationTracker
//
//  Created by Maksym Savisko on 5/14/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "LTDataHelper.h"
#import "LTDataHelperConstants.h"

@class LocationManagedModel, CLLocation;

@interface LTDataHelper (Location)

+ (void) saveLocations:(NSArray <CLLocation *> *) locations withCompletion:(LTDataHelperVoidCompletionBlock) completion;

@end

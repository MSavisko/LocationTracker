//
//  LTDataHelper+User.m
//  LocationTracker
//
//  Created by Maksym Savisko on 5/14/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "LTDataHelper+User.h"
#import "LTDataHelper+Private.h"
#import "UserManagedModel.h"

@implementation LTDataHelper (User)

+ (UserManagedModel *)currentUserModelInContext:(NSManagedObjectContext *)context
{
    UserManagedModel *user = [UserManagedModel MR_findFirstInContext:context];
    
    if (!user)
    {
        [self saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext)
        {
            UserManagedModel *user = [UserManagedModel MR_createEntityInContext:localContext];
            user.dataId = [NSString lt_uuidString];
        }
        backgroundQueue:NO];
    }
    
    return [UserManagedModel MR_findFirstInContext:context];
}

+ (UserManagedModel *)currentUserModel
{
    return [self currentUserModelInContext:[self mainContext]];
}

@end

//
//  NSDate+LTTimeAgo.m
//  LocationTracker
//
//  Created by Maksym Savisko on 5/14/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "NSDate+LTTimeAgo.h"

#define SECOND 1
#define MINUTE (SECOND * 60)
#define HOUR (MINUTE * 60)
#define DAY (HOUR * 24)
#define WEEK (DAY * 7)
#define MONTH (DAY * 31)
#define YEAR (DAY * 365.24)

@implementation NSDate (LTTimeAgo)

+ (NSDateFormatter *)timeAgoDateFormatter
{
    static dispatch_once_t pred;
    static id _timeAgoDateFormatter = nil;
    dispatch_once(&pred, ^{
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NO];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        _timeAgoDateFormatter = formatter;
    });
    
    return _timeAgoDateFormatter;
}

- (NSString *)lt_formattedAsTimeAgo
{
    
    NSDate *now = [NSDate date];
    NSTimeInterval secondsSince = -(int)[self timeIntervalSinceDate:now];
    
    if (secondsSince < 0)
        return NSLocalizedString(@"future", @"v1.0");
    
    if (secondsSince < MINUTE)
        return NSLocalizedString(@"now", @"v1.0");
    
    if (secondsSince < HOUR) {
        int minutesSince = (int)secondsSince / MINUTE;
        return [NSString stringWithFormat:@"%d %@", minutesSince, NSLocalizedString(@"min", @"v1.0")];
    }
    
    if (secondsSince < DAY) {
        int hoursSince = (int)secondsSince / HOUR;
        return [NSString stringWithFormat:@"%d %@", hoursSince, NSLocalizedString(@"h", @"v1.0")];
    }
    
    return [[self.class timeAgoDateFormatter] stringFromDate:self];
}

@end

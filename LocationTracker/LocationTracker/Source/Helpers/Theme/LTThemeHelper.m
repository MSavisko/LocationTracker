//
//  LTThemeHelper.m
//  LocationTracker
//
//  Created by Maksym Savisko on 5/12/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "LTThemeHelper.h"

#import "UIColor+LTTheme.h"
#import "UIFont+LTTheme.h"

static CGFloat const kButtonCornerRadius = 5.0;
static CGFloat const kButtonBorderWidth = 1.0;

@implementation LTThemeHelper

+ (void)customizeTabBar:(__kindof UITabBar *)tabBar
{
    [tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [obj setTitleTextAttributes:@{
                                      NSFontAttributeName : [UIFont lt_tabBarFontWithWeight:UIFontWeightRegular],
                                      NSForegroundColorAttributeName : [UIColor lt_tabBarItemColor]
                                      }
                           forState:UIControlStateNormal];
        
        [obj setTitleTextAttributes:@{
                                      NSFontAttributeName : [UIFont lt_tabBarFontWithWeight:UIFontWeightRegular],
                                      NSForegroundColorAttributeName : [UIColor lt_tabBarItemColorSelected]
                                      }
                           forState:UIControlStateSelected];
        
    }];
}

+ (void)customizeNavigationBar:(__kindof UINavigationBar *)navigationBar
{
    [navigationBar setTitleTextAttributes:@{
                                            NSForegroundColorAttributeName : [UIColor lt_navigationTitleColor],
                                            NSFontAttributeName : [UIFont lt_navigationBartTitleFontWithWeight:UIFontWeightBold],
                                            NSKernAttributeName : @(1.f)
                                            }];
    
    [navigationBar setTintColor:[UIColor lt_navigationTintColor]];
}

+ (void)customizeButton:(__kindof UIButton *) button
{
    [button setTitleColor:[UIColor lt_buttonTitleColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont lt_actionButtonFontWithWeight:UIFontWeightMedium]];
}

+ (void)customizeLayoutButton:(__kindof UIButton *) button
{
    button.layer.cornerRadius = kButtonCornerRadius;
    button.layer.borderColor = [UIColor lt_buttonBorderColor].CGColor;
    button.layer.borderWidth = kButtonBorderWidth;
}

@end
//
//  UIColor+LTTheme.m
//  LocationTracker
//
//  Created by Maksym Savisko on 5/13/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "UIColor+LTTheme.h"

@implementation UIColor (LTTheme)

#pragma mark - Primary colors

+ (UIColor *)lt_primaryGreenColor
{
    return [UIColor colorWithRed:202.f / 255.f green:0.f / 255.f blue:255.f / 255.f alpha:1.0];
    //return [UIColor colorWithRed:0.f / 255.f green:36.f / 255.f blue:255.f / 255.f alpha:1.0];
    //return [UIColor colorWithRed:64.f / 255.f green:255.f / 255.f blue:64.f / 255.f alpha:1.0];
}

+ (UIColor *)lt_primaryGreyColor
{
    return [UIColor blackColor];
    //return [UIColor colorWithRed:152.f / 255.f green:149.f / 255.f blue:143.f / 255.f alpha:1.0];
}

+ (UIColor *)lt_primaryWhiteColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)lt_primaryBlackColor
{
    return [UIColor blackColor];
}

#pragma mark - 

+ (UIColor *)lt_tabBarItemColor
{
    return [self lt_primaryGreyColor];
}

+ (UIColor *)lt_tabBarItemColorSelected
{
    return [self lt_primaryGreenColor];
}

+ (UIColor *)lt_navigationTitleColor
{
    return [self lt_primaryGreenColor];
}

+ (UIColor *)lt_navigationTintColor
{
    return [UIColor lt_primaryGreenColor];
}

+ (UIColor *)lt_buttonTitleColor
{
    return [UIColor lt_primaryGreenColor];
}

+ (UIColor *)lt_buttonBorderColor
{
    return [UIColor lt_primaryGreenColor];
}

+ (UIColor *)lt_historyCellTitleColor
{
    return [self lt_primaryGreyColor];
}

+ (UIColor *)lt_historyCellDateColor
{
    return [self lt_primaryGreenColor];
}

+ (UIColor *)lt_placeholderTextColor
{
    return [self lt_primaryBlackColor];
}

@end

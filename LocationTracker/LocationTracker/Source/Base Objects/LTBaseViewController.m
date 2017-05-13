//
//  LTBaseViewController.m
//  LocationTracker
//
//  Created by Maksym Savisko on 5/13/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "LTBaseViewController.h"
#import <KVOController/NSObject+FBKVOController.h>

@interface LTBaseViewController ()

@end

@implementation LTBaseViewController

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initializeKVO];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self initializeKVO];
    }
    
    return self;
}

- (void)initializeKVO
{
    __unused FBKVOController *initializedKVO = self.KVOController; //inititialize kvo to prevent crashes when this variable is created in dealloc method
}

- (void)dealloc
{
    [self.KVOController unobserveAll];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end

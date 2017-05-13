//
//  LTLauncherViewController.m
//  LocationTracker
//
//  Created by Maksym Savisko on 5/13/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "LTLauncherViewController.h"
#import "LTThemeHelper.h"

@interface LTLauncherViewController ()
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@end

@implementation LTLauncherViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Launcher", @"v1.0");
    self.navigationController.tabBarItem.title = NSLocalizedString(@"Launcher", @"v1.0");
    
    [self.actionButton setTitle:NSLocalizedString(@"Start tracking", @"v1.0") forState:UIControlStateNormal];
    [LTThemeHelper customizeButton:self.actionButton];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [LTThemeHelper customizeLayoutButton:self.actionButton];
}

#pragma mark - Action Methods

- (IBAction)actionButtonDidPressed:(id)sender
{
    
}

@end

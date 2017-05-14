//
//  LTHistoryViewController.m
//  LocationTracker
//
//  Created by Maksym Savisko on 5/13/17.
//  Copyright © 2017 Maksym Savisko. All rights reserved.
//

#import "LTHistoryViewController.h"
#import "NSIndexPath+LTExtension.h"
#import "LTHistoryCell.h"
#import "LTThemeHelper.h"

#import "LocationManagedModel.h"
#import "NSFetchedResultsController+LocationHistory.h"
#import <CoreData/NSFetchedResultsController.h>

@interface LTHistoryViewController () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation LTHistoryViewController

#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Location History", @"v1.0");
    self.navigationController.tabBarItem.title = NSLocalizedString(@"History", @"v1.0");
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"v1.0") style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllDidPressed)];
    [LTThemeHelper customizeDestructiveBarItem:rightButton];
    [self.navigationItem setRightBarButtonItem:rightButton];
}

#pragma mark - Action Methods

- (void) deleteAllDidPressed
{
    
}

#pragma mark - Properties

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    _fetchedResultsController = [NSFetchedResultsController lt_allLocationHistoryFetchedResultsControllerDelegate:self];
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        abort();
    }
    
    return _fetchedResultsController;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationManagedModel *item = self.fetchedResultsController.fetchedObjects[indexPath.row];
    
    LTHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:LTHistoryCellIdentifier];
    [cell addLocation:item];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LTHistoryCellDefaultHeight;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeMove: {
            if (![indexPath lt_isEqualToIndexPath:newIndexPath]) {
                [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
        }
        case NSFetchedResultsChangeUpdate: {

            break;
        }
    }
}



@end

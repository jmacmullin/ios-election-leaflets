//
//  PickListViewController.m
//  Election Leaflets
//
//  Created by Lachlan Wright on 6/05/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import "PickListViewController.h"
#import "DetailsViewController.h"

@interface PickListViewController ()

@property (nonatomic, strong) NSMutableIndexSet *selectedIndexes;

@end

@implementation PickListViewController

@synthesize pickList;
@synthesize multipleSelectionMode;
@synthesize orderedKeys;
@synthesize resultKey;
@synthesize selectedIndexes;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedIndexes = [[NSMutableIndexSet alloc] init];

    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.pickList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PickListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *key = self.orderedKeys[indexPath.row];
    cell.textLabel.text = [self.pickList objectForKey:key];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self.selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (indexPath.row == idx){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            *stop = YES;
        }
    }];
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.multipleSelectionMode){
        [self.selectedIndexes removeAllIndexes];
    }
    [self.selectedIndexes addIndex:indexPath.row];
    [self.tableView reloadData];
    if (!self.multipleSelectionMode){
        //If only one key is required, we can select it and then transition back the details table view controller
        NSString *selectedKey = [self.orderedKeys objectAtIndex:indexPath.row];
        DetailsViewController *detailsVC = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 2];
        [detailsVC selectedPickListKeys:[NSArray arrayWithObject:selectedKey] forPickListType:self.title];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

#pragma mark - View Will Disappear

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isMovingFromParentViewController && [self.selectedIndexes count] > 1){
        //Assuming the only way available is back to the details view controller
        DetailsViewController *detailsVC = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 1];
        NSArray *selectedKeys = [self.orderedKeys objectsAtIndexes:self.selectedIndexes];
        [detailsVC selectedPickListKeys:selectedKeys forPickListType:self.title];
    }
    [super viewWillDisappear:animated];
}

@end

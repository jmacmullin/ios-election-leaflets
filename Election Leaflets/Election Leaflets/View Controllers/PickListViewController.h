//
//  PickListViewController.h
//  Election Leaflets
//
//  Created by Lachlan Wright on 6/05/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickListViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *pickList;
@property (nonatomic, strong) NSArray *orderedKeys;
@property (nonatomic) BOOL multipleSelectionMode;

@end

//
//  JMMAboutViewController.m
//  Election Leaflets
//
//  Created by Jake MacMullin on 24/04/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import "JMMAboutViewController.h"

@interface JMMAboutViewController ()

@end

@implementation JMMAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self!=nil) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self!=nil) {
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"info_icon_selected"]
                      withFinishedUnselectedImage:[UIImage imageNamed:@"info_icon"]];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

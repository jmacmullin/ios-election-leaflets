//
//  JMMAppDelegate.m
//  Election Leaflets
//
//  Created by Jake MacMullin on 22/04/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import "JMMAppDelegate.h"
#import "JMMElectionLeafletsClient.h"
#import "JMMBrowseViewController.h"

@implementation JMMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    JMMBrowseViewController *browseController = (JMMBrowseViewController *)tabController.viewControllers[0];
    
    JMMElectionLeafletsClient *client = [JMMElectionLeafletsClient sharedClient];
    [client getLatestLeafletsAndProcessWithBlock:^(NSArray *leaflets) {
        [browseController setLeaflets:leaflets];
    }];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end

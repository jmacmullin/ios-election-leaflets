//
//  JMMAppDelegate.m
//  Election Leaflets
//
//  Created by Jake MacMullin on 22/04/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import <HockeySDK/HockeySDK.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import "JMMAppDelegate.h"
#import "JMMElectionLeafletsClient.h"
#import "JMMBrowseViewController.h"

@implementation JMMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:@"7bf3449927e2a43c4fa2ad187e86d346"
                                                         liveIdentifier:nil
                                                               delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    [tabController.tabBar setBackgroundImage:[UIImage imageNamed:@"tab_background"]];
    [tabController.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"tab_selection_indicator"]];
    
    NSDictionary *dict = @{ UITextAttributeTextColor : [UIColor darkGrayColor] };
    [[UITabBarItem appearance] setTitleTextAttributes:dict forState:UIControlStateSelected];

    NSDictionary *navigationBarTitleAttributes = @{
                                                    UITextAttributeTextColor : [UIColor darkGrayColor],
                                                    UITextAttributeTextShadowColor : [UIColor whiteColor]
                                                   };
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:navigationBarTitleAttributes];
    
    UINavigationController *navigationController = (UINavigationController *)tabController.viewControllers[0];
    JMMBrowseViewController *browseController = (JMMBrowseViewController *)navigationController.topViewController;
    
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

#ifdef CONFIGURATION_AdHoc
#pragma mark - BITUpdateManagerDelegate
- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
    return nil;
}
#endif


@end

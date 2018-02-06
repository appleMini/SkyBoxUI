//
//  SouAppDelegate.m
//  SkyBoxUI
//
//  Created by appleMini on 12/01/2017.
//  Copyright (c) 2017 appleMini. All rights reserved.
//

#import "SouAppDelegate.h"
#import <SkyBoxUI/SkyBoxUI.h>
#import <MMDrawerController/MMDrawerVisualState.h>

@interface SouAppDelegate ()

@property (nonatomic,strong) MMDrawerController * drawerController;

@end

@implementation SouAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
//    SPMainTabBarController *mainVC = [[SPMainTabBarController alloc] init];
//    SPMenuViewController *menuVC = [[SPMenuViewController alloc] init];
    //    SPHomeViewController *homeVC = [[SPHomeViewController alloc] init];
    SPMainViewController *mainVC = [[SPMainViewController alloc] init];
    SPNavigationController *naviVC = [[SPNavigationController alloc] initWithNavigationBarClass:[SPNavigationBar class] toolbarClass:nil];
    naviVC.viewControllers = @[mainVC];
//    SPNavigationController *naviVC = [[SPNavigationController alloc] initWithRootViewController:mainVC];

//    self.drawerController = [[MMDrawerController alloc]initWithCenterViewController:naviVC leftDrawerViewController:menuVC];
//    [self.drawerController setShowsShadow:NO];//设置是否有阴影
//    [self.drawerController setShouldStretchDrawer:NO];//设置是否回弹效果
//    [self.drawerController setMaximumLeftDrawerWidth:kScreen_Width];//最大距离
//    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
//    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
//    [self.drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
//
//    }];
    
//    self.window.rootViewController = self.drawerController;
    self.window.rootViewController = naviVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
}
@end

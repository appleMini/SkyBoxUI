//
//  SPNavigationController.m
//  SkyBoxUI_Example
//
//  Created by Shao shuqiang on 2017/12/1.
//  Copyright © 2017年 appleMini. All rights reserved.
//

#import "SPNavigationController.h"

@implementation SPNavigationController
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle{
    return self.topViewController;
}

@end

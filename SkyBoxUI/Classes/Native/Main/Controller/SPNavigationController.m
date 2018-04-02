//
//  SPNavigationController.m
//  SkyBoxUI_Example
//
//  Created by Shao shuqiang on 2017/12/1.
//  Copyright © 2017年 appleMini. All rights reserved.
//

#import "SPNavigationController.h"
@interface SPNavigationController()

@property (nonatomic, strong) UIView *statusView;
@end

@implementation SPNavigationController
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIViewController *)childViewControllerForStatusBarStyle{
    return self.topViewController;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return 1 << UIDeviceOrientationPortrait;
}

- (UIView *)statusView {
    if (!_statusView) {
        _statusView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, SCREEN_WIDTH, 20)];
        
        _statusView.backgroundColor = [UIColor clearColor];
    }
    
    return _statusView;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self setStatusBarBackgroundColor:[UIColor clearColor]];
    if (!_statusView) {
        [self.navigationBar addSubview:self.statusView];
    }
}

//设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}
@end

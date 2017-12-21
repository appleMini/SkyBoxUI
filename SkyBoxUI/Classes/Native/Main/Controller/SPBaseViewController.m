//
//  SPBaseViewController.m
//  SkyBoxUitl
//
//  Created by Shao shuqiang on 2017/11/29.
//  Copyright © 2017年 Shao shuqiang. All rights reserved.
//

#import "SPBaseViewController.h"

@interface SPBaseViewController ()

@end

@implementation SPBaseViewController

- (instancetype)initWithSomething {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    [self forceAutorotateInterfaceOrientation:UIInterfaceOrientationPortrait];
    [UIViewController attemptRotationToDeviceOrientation];
    
    //设置导航栏背景图片为一个空的image，这样就透明了
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    //去掉透明后导航栏下边的黑边
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //    如果不想让其他页面的导航栏变为透明 需要重置
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)forceAutorotateInterfaceOrientation:(UIInterfaceOrientation)orientation{
    if([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  =NSSelectorFromString(@"setOrientation:");
        NSInvocation*invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = RGBCOLOR(62, 63, 75);
    
    NSString *til = [self titleOfLabelView];
    if(til) {
        [self setupTitleView:til];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return 1 << UIDeviceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)setupTitleView:(NSString *)til {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = til;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:17.0];
    label.textColor = [UIColor whiteColor];
    label.frame = CGRectMake(0, 0, 200, 44);
    
    self.titleLabel = label;
    self.navigationItem.titleView = label;
}
    
- (NSString *)titleOfLabelView {
    return nil;
}

- (void)setupNaviView {
    
}
- (NSArray *)leftNaviItem {
    return nil;
}
- (NSArray *)rightNaviItem {
    return nil;
}
- (void)refresh {
    
}
@end
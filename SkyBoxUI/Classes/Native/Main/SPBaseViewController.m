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

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    [self forceAutorotateInterfaceOrientation:UIInterfaceOrientationPortrait];
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
    
    NSString *til = [self titleOfLabelView];
    if(til) {
        [self setupTitleView:til];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return 1 << UIDeviceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)setupTitleView:(NSString *)til {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = til;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:17.0];
    label.textColor = [UIColor redColor];
    label.frame = CGRectMake(0, 0, 100, 44);
    
    self.navigationItem.titleView = label;
}
    
- (NSString *)titleOfLabelView {
    return nil;
}
    
@end

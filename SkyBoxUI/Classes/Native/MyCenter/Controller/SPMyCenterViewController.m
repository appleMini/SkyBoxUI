//
//  SPMyCenterViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/1.
//

#import "SPMyCenterViewController.h"
#import "SPSwitchBar.h"

@interface SPMyCenterViewController ()

@end

@implementation SPMyCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"Click" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectZero;
    
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(60);
        make.center.mas_equalTo(0);
    }];
    
    [self.view addSubview:[SPSwitchBar shareSPSwitchBar]];
}

- (void)click:(UIButton *)sender {
    NSUInteger selectedIndex = self.tabBarController.selectedIndex;
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:nativeToUnityType],
                             kTopViewController: self,
                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex]
                                 };
    
    [sender bubbleEventWithUserInfo:notify];
}

- (NSString *)titleOfLabelView {
    return @"我的";
}
@end

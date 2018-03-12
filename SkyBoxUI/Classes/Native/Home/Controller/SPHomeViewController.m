//
//  SPHomeViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/1.
//

#import "SPHomeViewController.h"
#import "SPHelpRootViewController.h"
#import "SPNavigationBar.h"

@interface SPHomeViewController ()

@property (nonatomic, strong) UIBarButtonItem *addItem;
@end

@implementation SPHomeViewController

- (instancetype)initWithSomething {
    self = [super initWithType:LocalFilesType displayType:TableViewType];
    if (self) {
        
    }
    return self;
}

- (NSString *)titleOfLabelView {
    return @"MY VIDEOS";
}

- (NSString *)cellIditify {
    return @"MY_VIDEOS_CellID";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (NSArray *)rightNaviItem {
    return @[self.addItem];
}

- (UIBarButtonItem *)addItem {
    if (!_addItem) {
        UIButton *addItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [addItem setImage:[Commons getPdfImageFromResource:@"Home_titlebar_button_add"] forState:UIControlStateNormal];
        addItem.backgroundColor = [UIColor clearColor];
        addItem.userInteractionEnabled = NO;
        addItem.frame = CGRectMake(0, 0, 20, 20);
        [addItem addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _addItem = [[UIBarButtonItem alloc] initWithCustomView:addItem];
    }
    
    return _addItem;
}

- (void)addClick:(UIButton *)item {
    //    [ServiceCall callGetActionParams:nil requestUrl:@"http://192.168.7.241:8080/REST/json" resultctxCall:^(NSDictionary *result) {
    //        NSLog(@"%@", result);
    //        NSUInteger selectedIndex = self.tabBarController.selectedIndex;
    //        NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:TestType],
    //                                 kTopViewController: self,
    //                                 kFunctionName: @"__iosNativeLoadNetworkVideoInfoByUnity",
    //                                 kParams:result.mj_JSONString
    //                                };
    //
    //                                               [item bubbleEventWithUserInfo:notify];
    //
    //                                               } errorCall:nil];
//    NSUInteger selectedIndex = -1;
//    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:HomeHelpMiddleVCType],
//                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex],
//                             @"Done": @YES
//                             };
//
//    [self.view bubbleEventWithUserInfo:notify];
    SPHelpRootViewController *helpRootVC =  [[SPHelpRootViewController alloc] initWithDoneAction];
    SPNavigationController *naivc = [[SPNavigationController alloc] initWithNavigationBarClass:[SPNavigationBar class] toolbarClass:nil];
    naivc.viewControllers = @[helpRootVC];
    
    [self presentViewController:naivc animated:YES completion:nil];
}
@end


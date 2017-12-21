//
//  SPHomeViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/1.
//

#import "SPHomeViewController.h"

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
        [addItem setImage:nil forState:UIControlStateNormal];
        addItem.backgroundColor = [UIColor blueColor];
        addItem.frame = CGRectMake(0, 0, 40, 40);
        [addItem addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _addItem = [[UIBarButtonItem alloc] initWithCustomView:addItem];
    }
    
    return _addItem;
}

- (void)addClick:(UIButton *)item {
    [ServiceCall callGetActionParams:nil requestUrl:@"http://192.168.7.241:8080/REST/json" resultctxCall:^(NSDictionary *result) {
        NSLog(@"%@", result);
        NSUInteger selectedIndex = self.tabBarController.selectedIndex;
        NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:testType],
                                 kTopViewController: self,
                                 kFunctionName: @"__iosNativeLoadNetworkVideoInfoByUnity",
                                 kParams:result.mj_JSONString
                                };
                                               
                                               [item bubbleEventWithUserInfo:notify];
                                               
                                               } errorCall:nil];
}
@end

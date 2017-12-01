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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *til = [self titleOfLabelView];
    if(til) {
        [self setupTitleView:til];
    }
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

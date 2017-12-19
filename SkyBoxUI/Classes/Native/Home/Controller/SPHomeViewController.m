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
    
}
@end

//
//  SPHistoryViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "SPHistoryViewController.h"

@interface SPHistoryViewController()

@property (nonatomic, strong) UIBarButtonItem *deleteItem;
@end

@implementation SPHistoryViewController

- (instancetype)initWithSomething {
    self = [super initWithType:HistoryVideosType displayType:CollectionViewType];
    if (self) {
        
    }
    return self;
}

- (NSString *)titleOfLabelView {
    return @"HISTORY";
}

- (NSString *)cellIditify {
    return @"HISTORY_CellID";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (NSArray *)rightNaviItem {
    return @[self.deleteItem];
}

- (UIBarButtonItem *)deleteItem {
    if (!_deleteItem) {
        UIButton *deleteItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteItem setImage:[Commons getPdfImageFromResource:@"History_titlebar_button_delete"] forState:UIControlStateNormal];
        deleteItem.backgroundColor = [UIColor clearColor];
//        deleteItem.frame = CGRectMake(0, 0, 20, 20);
        [deleteItem addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
        
        _deleteItem = [[UIBarButtonItem alloc] initWithCustomView:deleteItem];
    }
    
    return _deleteItem;
}

- (void)deleteItem:(UIButton *)item {
    
}
@end

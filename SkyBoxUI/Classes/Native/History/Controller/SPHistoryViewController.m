//
//  SPHistoryViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "SPHistoryViewController.h"

@interface SPHistoryViewController()

@end

@implementation SPHistoryViewController

- (instancetype)initWithSomething {
    self = [super initWithType:HistoryVideosType displayType:CollectionViewType];
    if (self) {
        
    }
    return self;
}

- (NSString *)titleOfLabelView {
    return NSLocalizedString(@"Menu_History", @"HISTORY");
}

- (NSString *)cellIditify {
    return @"HISTORY_CellID";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
@end


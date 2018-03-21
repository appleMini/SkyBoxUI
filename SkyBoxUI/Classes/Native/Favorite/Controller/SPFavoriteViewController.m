//
//  SPFavoriteViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/18.
//

#import "SPFavoriteViewController.h"

@interface SPFavoriteViewController ()

@end

@implementation SPFavoriteViewController

- (instancetype)initWithSomething {
    self = [self initWithType:FavoriteVideosType displayType:TableViewType];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSString *)titleOfLabelView {
    return @"FAVORITE";
}

- (NSString *)cellIditify {
    return @"FAVORITE_VIDEOS_CellID";
}

@end

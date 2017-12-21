//
//  SPNetworkViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/18.
//

#import "SPNetworkViewController.h"

@interface SPNetworkViewController ()

@end

@implementation SPNetworkViewController

- (instancetype)initWithSomething {
    self = [self initWithType:LocalFilesType displayType:TableViewType];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSString *)titleOfLabelView {
    return @"Local Network";
}

- (NSString *)cellIditify {
    return @"Local_Network_CellID";
}

@end

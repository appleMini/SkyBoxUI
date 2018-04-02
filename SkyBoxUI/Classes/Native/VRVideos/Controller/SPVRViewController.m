//
//  ViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/18.
//

#import "SPVRViewController.h"

@interface SPVRViewController ()

@end

@implementation SPVRViewController

- (instancetype)initWithSomething {
    self = [super initWithType:VRVideosType displayType:TableViewType];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSString *)titleOfLabelView {
    return NSLocalizedString(@"Menu_VRVideos", @"VR VIDEOS");
}

- (NSString *)cellIditify {
    return @"VR_VIDEOS_CellID";
}

@end

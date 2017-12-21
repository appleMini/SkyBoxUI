//
//  SPAirScreenResultViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/21.
//

#import "SPAirScreenResultViewController.h"

@interface SPAirScreenResultViewController ()

@property (nonatomic, strong) UIView *topView;
@end

@implementation SPAirScreenResultViewController

- (instancetype)initWithSomething {
    self = [self initWithType:AirScreenType displayType:TableViewType];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNaviView];
}

- (void)setupNaviView {
    self.navigationItem.titleView = self.topView;
}

- (UIView *)topView {
    if (_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 180, 60)];
        _topView.backgroundColor = [UIColor blueColor];
        _topView.layer.cornerRadius = 10;
    }
    
    return _topView;
}

@end

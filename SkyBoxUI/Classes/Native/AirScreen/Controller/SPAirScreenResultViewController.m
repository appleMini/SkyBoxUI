//
//  SPAirScreenResultViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/21.
//

#import "SPAirScreenResultViewController.h"

@interface SPAirScreenResultViewController () {
    BOOL _showDisconnect;
}

@property (nonatomic, strong) UIButton *disconnBtn;
@property (nonatomic, strong) UIButton *serverBtn;
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
    
    [self topViewAddToKeyWindow];
    self.topView.hidden = NO;
}

- (void)setAirscreen:(SPAirscreen *)airscreen {
    _airscreen = airscreen;
    self.topView.hidden = NO;
    [self.serverBtn setTitle:[_airscreen computerName] forState:UIControlStateNormal];
}

- (void)showOrHiddenTopView:(BOOL)show {
    self.topView.hidden = !show;
}

- (void)dealloc {
    [self.topView removeFromSuperview];
}

- (void)topViewAddToKeyWindow {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.topView];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat height = 44;
        CGFloat x = 80*kWSCALE;
        CGFloat y = [SPDeviceUtil isiPhoneX] ? 34 : 20;
        make.top.mas_equalTo(y);
        make.leading.mas_equalTo(x);
        make.trailing.mas_equalTo(-x);
        make.height.mas_equalTo(height);
    }];
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.backgroundColor = [UIColor blueColor];
        _topView.layer.cornerRadius = 10;
        _topView.clipsToBounds = YES;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
        [btn setTitle:@"xiaoxiao" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(showOrHiddenOtherView) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor redColor];
        [_topView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.leading.mas_equalTo(0);
            make.trailing.mas_equalTo(0);
            make.height.mas_equalTo(44);
        }];
        self.serverBtn = btn;
    }
    
    return _topView;
}

- (UIButton *)disconnBtn {
    if (!_disconnBtn) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
        [btn setTitle:@"DISCONNECT" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(disconnection:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor blackColor];
        _disconnBtn = btn;
    }
    
    return _disconnBtn;
}

- (void)disconnection:(id)sender {
    NSUInteger selectedIndex = -1;
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:AirScreenMiddleVCType],
                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex],
                             
                             };
    
    [self.view bubbleEventWithUserInfo:notify];
}

- (void)showOrHiddenOtherView {
    if(!_showDisconnect){
        _showDisconnect = YES;
        
        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            CGFloat height = 44;
            CGFloat x = 80*kWSCALE;
            CGFloat y = [SPDeviceUtil isiPhoneX] ? 34 : 20;
            make.top.mas_equalTo(y);
            make.leading.mas_equalTo(x);
            make.trailing.mas_equalTo(-x);
            make.height.mas_equalTo(height * 2);
        }];
        
        [self.topView addSubview:self.disconnBtn];
        [self.disconnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(0);
            make.trailing.mas_equalTo(0);
            make.height.mas_equalTo(44);
            make.bottom.mas_equalTo(0);
        }];
    }else{
        _showDisconnect = NO;
        [self.disconnBtn removeFromSuperview];
        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            CGFloat height = 44;
            CGFloat x = 80*kWSCALE;
            CGFloat y = [SPDeviceUtil isiPhoneX] ? 34 : 20;
            make.top.mas_equalTo(y);
            make.leading.mas_equalTo(x);
            make.trailing.mas_equalTo(-x);
            make.height.mas_equalTo(height);
        }];
    }
    
    [self.topView updateConstraints];
}
@end


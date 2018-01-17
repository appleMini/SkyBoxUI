//
//  SPAirScreenResultViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/21.
//

#import "SPAirScreenResultViewController.h"
#import "SPButton.h"

@interface SPAirScreenResultViewController () {
    BOOL _showDisconnect;
}

@property (nonatomic, strong) UIButton *disconnBtn;
@property (nonatomic, strong) UIButton *serverBtn;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *maskView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
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

- (void)showTopViewAlpha:(CGFloat)alpha {
    self.topView.alpha = alpha;
}

- (void)dealloc {
    [self.topView removeFromSuperview];
    [self.maskView removeFromSuperview];
}

- (void)topViewAddToKeyWindow {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGFloat height = 32;
    CGFloat x = (SCREEN_WIDTH - 334/2)/2;
    CGFloat y = [SPDeviceUtil isiPhoneX] ? 34 + (44 - 32)/2 : 20 + (44 - 32)/2;
    CGFloat width = 334/2;
    self.topView.frame = CGRectMake(x, y, width, height);
    [window addSubview:self.topView];
    
    //    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        CGFloat height = 32;
    //        CGFloat x = 80*kWSCALE;
    //        CGFloat y = [SPDeviceUtil isiPhoneX] ? 34 + (44 - 32)/2 : 20 + (44 - 32)/2;
    //        make.top.mas_equalTo(y);
    //        make.leading.mas_equalTo(x);
    //        make.trailing.mas_equalTo(-x);
    //        make.height.mas_equalTo(height);
    //    }];
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.backgroundColor = [UIColor whiteColor];
        _topView.layer.cornerRadius = 16;
        _topView.clipsToBounds = YES;
        
        SPButton *btn = [[SPButton alloc] initWithFrame:CGRectZero];
        btn.titleLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:15.0];
        [btn setTitleColor:[SPColorUtil getHexColor:@"#4a4d55"] forState:UIControlStateNormal];
        [btn setTitle:@"xiaoxiao" forState:UIControlStateNormal];
        [btn setImage:[Commons getPdfImageFromResource:@"AirScreen_titlebar_arrow"] forState:UIControlStateNormal];
        // button标题的偏移量
        //        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -btn.imageView.bounds.size.width+2, 0, btn.imageView.bounds.size.width);
        // button图片的偏移量
        //        btn.imageEdgeInsets = UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width, 0, -btn.titleLabel.bounds.size.width);
        [btn addTarget:self action:@selector(showOrHiddenOtherView) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor clearColor];
        CGFloat x = 16;
        CGFloat y = 0;
        CGFloat width = 334/2 - 16 * 2;
        CGFloat height = 32;
        btn.frame = CGRectMake(x, y, width, height);
        [_topView addSubview:btn];
        //        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.top.mas_equalTo(0);
        //            make.leading.mas_equalTo(16);
        //            make.trailing.mas_equalTo(-16);
        //            make.height.mas_equalTo(32);
        //        }];
        self.serverBtn = btn;
        
        x = 16;
        //        y = self.serverBtn.frame.origin.y + self.serverBtn.frame.size.height;
        width = self.serverBtn.frame.size.width;
        height = self.serverBtn.frame.size.height;
        
        self.disconnBtn.frame = CGRectMake(x, 0, width, height);
        [_topView addSubview:self.disconnBtn];
        self.disconnBtn.alpha = -1.0;
    }
    
    return _topView;
}

- (UIButton *)disconnBtn {
    if (!_disconnBtn) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
        btn.titleLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:15.0];
        [btn setTitleColor:[SPColorUtil getHexColor:@"#ffffff"] forState:UIControlStateNormal];
        [btn setTitle:@"DISCONNECT" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(disconnection:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [SPColorUtil getHexColor:@"#4b4d56"];
        _disconnBtn = btn;
    }
    
    return _disconnBtn;
}

- (void)releaseAction {
    [self.maskView removeGestureRecognizer:_tapGesture];
}

- (void)disconnection:(id)sender {
    NSUInteger selectedIndex = -1;
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:AirScreenMiddleVCType],
                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex],
                             
                             };
    
    [self.view bubbleEventWithUserInfo:notify];
}

- (UIView *)maskView {
    if (!_maskView) {
        UIView *maskView = [[UIView alloc] initWithFrame:CGRectZero];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0.0;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colseTopView:)];
        [maskView addGestureRecognizer:tapGesture];
        _maskView = maskView;
        _tapGesture = tapGesture;
    }
    return _maskView;
}

- (void)colseTopView:(UIGestureRecognizer *)gesture {
    [self showOrHiddenOtherView];
}

- (void)showOrHiddenOtherView {
    if(!_showDisconnect){
        _showDisconnect = YES;
        //添加遮罩
        [KEYWINDOW addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0 ));
        }];
        
        [KEYWINDOW bringSubviewToFront:self.topView];
        
        [UIView animateWithDuration:0.6 animations:^{
            
            CGRect frame = self.topView.frame;
            CGFloat height = 32;
            CGFloat width = 376/2;
            CGFloat x = (SCREEN_WIDTH - width)/2;
            
            frame.size.height = height * 2 + 20;
            frame.origin.x = x;
            frame.size.width = width;
            self.topView.frame = frame;
            
            //        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            //            CGFloat height = 32;
            //            CGFloat x = 80*kWSCALE;
            //            CGFloat y = [SPDeviceUtil isiPhoneX] ? 34 + (44 - 32)/2 : 20 + (44 - 32)/2;
            //            make.top.mas_equalTo(y);
            //            make.leading.mas_equalTo(x);
            //            make.trailing.mas_equalTo(-x);
            //            make.height.mas_equalTo(height * 2 + 20);
            //        }];
            frame = self.serverBtn.frame;
            frame.origin.y = 10;
            frame.origin.x = 16;
            frame.size.width = self.topView.bounds.size.width - 2 * 16;
            self.serverBtn.frame = frame;
            
            //        [self.serverBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            //            make.top.mas_equalTo(10);
            //        }];
            x = 16;
            CGFloat y = self.serverBtn.frame.origin.y + self.serverBtn.frame.size.height;
            width = self.serverBtn.frame.size.width;
            height = self.serverBtn.frame.size.height;
            
            self.disconnBtn.frame = CGRectMake(x, y, width, height);
            
            //            [self.topView addSubview:self.disconnBtn];
            //        [self.disconnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            //            make.leading.mas_equalTo(16);
            //            make.trailing.mas_equalTo(-16);
            //            make.height.mas_equalTo(32);
            //            make.bottom.mas_equalTo(-10);
            //        }];
            self.disconnBtn.layer.cornerRadius = 16;
            self.disconnBtn.layer.masksToBounds = YES;
            
            self.topView.layer.cornerRadius = 20;
            self.topView.layer.masksToBounds = YES;
            
            self.maskView.alpha = 0.4;
        }];
        [UIView animateWithDuration:0.3 delay:0.3 options:0 animations:^{
            self.disconnBtn.alpha = 1.0;
        } completion:nil];
    }else{
        _showDisconnect = NO;
        //            [self.disconnBtn removeFromSuperview];
        
        [UIView animateWithDuration:0.6 animations:^{
            CGRect frame = self.topView.frame;
            CGFloat height = 32;
            CGFloat width = 334/2;
            CGFloat x = (SCREEN_WIDTH - width)/2;
            frame.origin.x = x;
            frame.size.width = width;
            frame.size.height = height;
            self.topView.frame = frame;
            
            //        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            //            CGFloat height = 32;
            //            CGFloat x = 80*kWSCALE;
            //            CGFloat y = [SPDeviceUtil isiPhoneX] ? 34 + (44 - 32)/2 : 20 + (44 - 32)/2;
            //            make.top.mas_equalTo(y);
            //            make.leading.mas_equalTo(x);
            //            make.trailing.mas_equalTo(-x);
            //            make.height.mas_equalTo(height);
            //        }];
            frame = self.serverBtn.frame;
            frame.origin.y = 0;
            frame.size.width = self.topView.bounds.size.width - 2 * 16;
            self.serverBtn.frame = frame;
            //        [self.serverBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            //            make.top.mas_equalTo(0);
            //        }];
            
            frame = self.disconnBtn.frame;
            frame.origin.y = 0;
            frame.size.width = self.serverBtn.frame.size.width;
            self.disconnBtn.frame = frame;
            
            self.topView.layer.cornerRadius = 16;
            self.topView.layer.masksToBounds = YES;
            
            self.maskView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.maskView removeFromSuperview];
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.disconnBtn.alpha = 0.0;
        }];
    }
    
    //    // 告诉self.topView约束需要更新
    //    [self.topView setNeedsUpdateConstraints];
    //    // 调用此方法告诉self.topView检测是否需要更新约束，若需要则更新，下面添加动画效果才起作用
    //    [self.topView updateConstraintsIfNeeded];
    //
    //    [UIView animateWithDuration:0.6 animations:^{
    //        [self.topView layoutIfNeeded];
    //    }];
}
@end


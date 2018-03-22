//
//  SPAirScreenResultViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/21.
//

#import "SPAirScreenResultViewController.h"
#import "TGRefresh.h"
#import "SPButton.h"
#import "SPVideo.h"
#import "UIViewController+MBPHUD.h"

@interface SPAirScreenResultViewController () {
    BOOL _showDisconnect;
}

@property (nonatomic, strong) SPHighlightedButton *disconnBtn;
@property (nonatomic, strong) UIButton *serverBtn;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *maskView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@end

@implementation SPAirScreenResultViewController
@synthesize emptyView = _emptyView;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:UNITYTOUINOTIFICATIONNAME object:nil];
    }
    return self;
}
- (instancetype)initWithSomething {
    self = [self initWithType:AirScreenType displayType:TableViewType];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:UNITYTOUINOTIFICATIONNAME object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self monitorNetWorkState];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self topViewAddToKeyWindow];
    self.topView.hidden = NO;
    [KEYWINDOW bringSubviewToFront:self.topView];
    self.topView.alpha = 0.0;
    
    [UIView animateWithDuration:1.0 animations:^{
        self.topView.alpha = 1.0;
    }];
    
    [self.serverBtn setTitle:[_airscreen computerName] forState:UIControlStateNormal];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_topView removeFromSuperview];
    _topView = nil;
}

- (void)receiveMessage:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:KEYWINDOW animated:YES];
    });
    
    NSDictionary *dict = [notify userInfo];
    NSString *jsonStr = dict[@"JsonResult"];
    
    if ([dict[@"method"] hash] == [@"showResult" hash]) {
        if ([dict[@"connenct"] hash] == [@"false" hash]) {
            //连接失败,退回搜索界面
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showHUDProgressWithMessage:@"Faild connect to PC!"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self hideHUDCompletion:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self disconnection:nil];
                        });
                    }];
                });
            });
            return;
        }
        
        if (!jsonStr) {
            //     NSLog(@"mediaListResult is none....");
            self.dataArr = nil;
            [self reload];
            return;
        }
        
        SPMediaListResult *listResult = [[SPMediaListResult alloc] mj_setKeyValues:jsonStr];
        
        NSMutableArray *mediaListResult = [[NSMutableArray alloc] initWithCapacity:listResult.list.count];
        for (NSDictionary *info in listResult.list) {
            SPCmdMediaInfo *media = [[SPCmdMediaInfo alloc] mj_setKeyValues:info];
            SPVideo *video = [[SPVideo alloc] init];
            video.dataSource = AirScreenType;
            video.mid = media.mid;
            video.path = media.url;
            video.title = media.name;
            video.videoWidth = [NSString stringWithFormat:@"%d", media.width];
            video.videoHeight = [NSString stringWithFormat:@"%d", media.height];
            video.thumbnail_uri = media.thumbnail;
            video.duration = [NSString stringWithFormat:@"%f", media.duration];
            [mediaListResult addObject:video];
        }
        
        self.dataArr = [mediaListResult copy];
        [self reload];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //        _scrollView.tg_header.refreshResultStr = @"成功刷新数据";
            [self.scrollView.tg_header endRefreshing];
            [self enableNavigationItems:YES];
        });
    }else if ([dict[@"method"] hash] == [@"updateNewMediasToClients" hash]) {
        // "{\"command\":\"updateNewMediasToClients\",\"list\":[{\"defaultVRSetting\":2,\"duration\":0,\"height\":0,\"id\":\"6682fe7e28644cc6a79652bea1b943ff\",\"lastModified\":1509000978000,\"name\":\"abcd3D.mp4\",\"orientDegree\":\"0\",\"ratioTypeFor2DScreen\":\"default\",\"rotationFor2DScreen\":0,\"size\":64744560,\"subtitles\":[{\"type\":\"ass\",\"url\":\"http://192.168.14.90:6888/subtitle/6682fe7e28644cc6a79652bea1b943ff/i/0\"}],\"thumbnail\":\"\",\"thumbnailHeight\":0,\"thumbnailWidth\":0,\"url\":\"http://192.168.14.90:8001/stream/6682fe7e28644cc6a79652bea1b943ff\",\"userVRSetting\":-1,\"width\":0}]}"
        SPMediaListResult *listResult = [[SPMediaListResult alloc] mj_setKeyValues:jsonStr];
        
        NSMutableArray *mediaListResult = [[NSMutableArray alloc] initWithCapacity:listResult.list.count];
        for (NSDictionary *info in listResult.list) {
            SPCmdMediaInfo *media = [[SPCmdMediaInfo alloc] mj_setKeyValues:info];
            SPVideo *video = [[SPVideo alloc] init];
            video.dataSource = AirScreenType;
            video.mid = media.mid;
            video.path = media.url;
            video.title = media.name;
            video.videoWidth = [NSString stringWithFormat:@"%d", media.width];
            video.videoHeight = [NSString stringWithFormat:@"%d", media.height];
            video.thumbnail_uri = media.thumbnail;
            video.duration = [NSString stringWithFormat:@"%f", media.duration];
            [mediaListResult addObject:video];
        }
        
        NSMutableArray *oldArr = [NSMutableArray arrayWithArray:mediaListResult];
        [oldArr addObjectsFromArray:self.dataArr];
        
        self.dataArr = [oldArr copy];
        [self reload];
    }else if ([dict[@"method"] hash] == [@"updateReadyMediaToClients" hash]) {
        //   {"command":"updateReadyMediaToClients","media":{"defaultVRSetting":5,"duration":180000,"height":1080,"id":"6682fe7e28644cc6a79652bea1b943ff","lastModified":1509000978000,"name":"abcd3D.mp4","orientDegree":"0","ratioTypeFor2DScreen":"default","rotationFor2DScreen":0,"size":64744560,"subtitles":[{"type":"ass","url":"http://192.168.14.90:6888/subtitle/6682fe7e28644cc6a79652bea1b943ff/i/0"}],"thumbnail":"http://192.168.14.90:6888/thumbnail/6682fe7e28644cc6a79652bea1b943ff","thumbnailHeight":120,"thumbnailWidth":186,"url":"http://192.168.14.90:8001/stream/6682fe7e28644cc6a79652bea1b943ff","userVRSetting":-1,"width":1920}}
        SPCmdReadyMediaInfo *readyMedia = [[SPCmdReadyMediaInfo alloc] mj_setKeyValues:jsonStr];
        SPCmdMediaInfo *media = [[SPCmdMediaInfo alloc] mj_setKeyValues:readyMedia.media];
        NSUInteger count = self.dataArr.count;
        for (int i = 0; i < count; i++) {
            SPVideo *video = self.dataArr[i];
            if ([media.mid hash] == [video.mid hash]) {
                video.dataSource = AirScreenType;
                video.mid = media.mid;
                video.path = media.url;
                video.title = media.name;
                video.videoWidth = [NSString stringWithFormat:@"%d", media.width];
                video.videoHeight = [NSString stringWithFormat:@"%d", media.height];
                video.thumbnail_uri = media.thumbnail;
                video.duration = [NSString stringWithFormat:@"%f", media.duration];
                break;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateVisiableCell];
        }); 
    }else if ([dict[@"method"] hash] == [@"activeDisconnect" hash]) {
        [self disconnection:nil];
    }else if ([dict[@"method"] hash] == [@"deleteMedia" hash]) {
        //"{\"command\":\"deleteMedia\",\"id\":\"6682fe7e28644cc6a79652bea1b943ff\"}"
        SPCmdMediaInfo *mediaInfo = [[SPCmdMediaInfo alloc] mj_setKeyValues:jsonStr];
        NSUInteger count = self.dataArr.count;
        for (int i = 0; i < count; i++) {
            SPVideo *video = self.dataArr[i];
            if ([video.mid hash] == [mediaInfo.mid hash]) {
                video.isDelete = YES;
                break;
            }
        }
        
        [self removeItemWithAnimation];
    }else if ([dict[@"method"] hash] == [@"deleteAllMedias" hash]) {
        self.dataArr = nil;
        [self reload];
    }
}

- (void)setAirscreen:(SPAirscreen *)airscreen {
    _airscreen = airscreen;
    [SPDataManager shareSPDataManager].airscreen = _airscreen;
    
    self.topView.hidden = NO;
    [self.serverBtn setTitle:[_airscreen computerName] forState:UIControlStateNormal];
}

- (void)showOrHiddenTopView:(BOOL)show {
    self.topView.hidden = !show;
}

- (void)showTopViewAlpha:(CGFloat)alpha {
    self.topView.alpha = alpha;
}

- (void)monitorNetWorkState {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    AFNetworkReachabilityStatus status = [manager networkReachabilityStatus];
    
    __weak typeof(self) ws = self;
    self.netStateBlock = ^(AFNetworkReachabilityStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == -1 || status == 0 || status == 1) {
                [ws enableNavigationItems:NO];
                ws.topView.userInteractionEnabled = NO;
                [ws hiddenGradientLayer:YES];
                
                SPBackgrondView *backgroundView = [[SPBackgrondView alloc] initWithFrame:ws.view.bounds
                                                                          backgroundType:NoWifi];
                backgroundView.backgroundColor = SPBgColor;
                [ws.view addSubview:backgroundView];
                [ws.view bringSubviewToFront:backgroundView];
                
                ws.emptyView = backgroundView;
            }else {
                [ws enableNavigationItems:YES];
                [ws hiddenGradientLayer:NO];
                ws.topView.userInteractionEnabled = YES;
                [ws.emptyView removeFromSuperview];
            }
        });
    };
    
    self.netStateBlock(status);
}

- (void)dealloc {
    [_topView removeFromSuperview];
    [_maskView removeGestureRecognizer:_tapGesture];
    [_maskView removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UNITYTOUINOTIFICATIONNAME object:nil];
}

//- (UIWindow *)keyWindow {
//    NSArray *windows = [UIApplication sharedApplication].windows;
//    for (UIWindow *win in windows) {
//        win.windowLevel
//    }
//}
- (void)topViewAddToKeyWindow {
    CGFloat height = 27;
    CGFloat x = (SCREEN_WIDTH - 334/2)/2;
    CGFloat y = [SPDeviceUtil isiPhoneX] ? 34 + (44 - 27)/2 + 10 : 20 + (44 - 27)/2 + 10;
    CGFloat width = 334/2;
    self.topView.frame = CGRectMake(x, y, width, height);
    [KEYWINDOW addSubview:self.topView];
    
    //    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        CGFloat height = 27;
    //        CGFloat x = 80*kWSCALE;
    //        CGFloat y = [SPDeviceUtil isiPhoneX] ? 34 + (44 - 27)/2 : 20 + (44 - 27)/2;
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
        _topView.layer.cornerRadius = 13.5;
        _topView.clipsToBounds = YES;
        
        SPButton *btn = [[SPButton alloc] initWithFrame:CGRectZero];
        btn.titleLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:15.0];
        [btn setTitleColor:[SPColorUtil getHexColor:@"#4a4d55"] forState:UIControlStateNormal];
        [btn setTitleColor:[SPColorUtil getHexColor:@"#4a4d55"] forState:UIControlStateHighlighted];
        [btn setTitle:@"xiaoxiao" forState:UIControlStateNormal];
        [btn setImage:[Commons getPdfImageFromResource:@"AirScreen_titlebar_arrow"] forState:UIControlStateNormal];
        // button标题的偏移量
        //        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -btn.imageView.bounds.size.width+2, 0, btn.imageView.bounds.size.width);
        // button图片的偏移量
        //        btn.imageEdgeInsets = UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width, 0, -btn.titleLabel.bounds.size.width);
        [btn addTarget:self action:@selector(showOrHiddenOtherView) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor clearColor];
        CGFloat x = 8;
        CGFloat y = 0;
        CGFloat width = 334/2 - 8 * 2;
        CGFloat height = 27;
        btn.frame = CGRectMake(x, y, width, height);
        [_topView addSubview:btn];
        //        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.top.mas_equalTo(0);
        //            make.leading.mas_equalTo(16);
        //            make.trailing.mas_equalTo(-16);
        //            make.height.mas_equalTo(27);
        //        }];
        self.serverBtn = btn;
        
        x = 8;
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
        SPHighlightedButton *btn = [[SPHighlightedButton alloc] initWithFrame:CGRectZero];
        btn.titleLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:15.0];
        [btn setTitleColor:[SPColorUtil getHexColor:@"#ffffff"] forState:UIControlStateNormal];
        [btn setTitle:@"DISCONNECT" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(disconnection:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [SPColorUtil getHexColor:@"#4b4d56"];
        
        btn.bgNormalColor = [SPColorUtil getHexColor:@"#4b4d56"];
        btn.bgHighlightedColor = [SPColorUtil getHexColor:@"#37393f"];
        btn.titleHighlightedColor = [SPColorUtil getHexColor:@"#ffffff"];
        btn.titleNormalColor = [SPColorUtil getHexColor:@"#ffffff"];
        btn.normalAlpha = 1.0;
        btn.highlightedAlpha = 1.0;
        _disconnBtn = btn;
    }
    
    return _disconnBtn;
}

- (void)doRefreshSenior {
    //     NSLog(@"doRefreshSenior");
    [self enableNavigationItems:NO];
//    _airscreen.ip = @"asdasfsfs";
//    _airscreen.ips = @[@"asfafdsfsasda"];
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    AFNetworkReachabilityStatus status = [manager networkReachabilityStatus];
    if (status == -1 || status == 0 || status == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //        _scrollView.tg_header.refreshResultStr = @"成功刷新数据";
            [self.scrollView.tg_header endRefreshing];
            [self enableNavigationItems:YES];
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = KEYWINDOW;
        if (!keyWindow) {
            return ;
        }
        
        if (!self.scrollView.tg_header.isRefreshing) {
            [MBProgressHUD showHUDAddedTo:KEYWINDOW animated:YES];
        }
    });
    [[SPAirScreenManager shareAirScreenManager] connectServer:_airscreen complete:^(NSArray *listResult, NSString *resultStr) {
        
    }];
}

- (void)releaseAction {
    [super releaseAction];
    [_topView removeFromSuperview];
    _topView = nil;
    [_maskView removeGestureRecognizer:_tapGesture];
    [_maskView removeFromSuperview];
    _maskView = nil;
}

- (void)disconnection:(id)sender {
    if (_airscreen) {
        [[SPAirScreenManager shareAirScreenManager] disConnectServer];
    }
    [SPDataManager shareSPDataManager].airscreen = nil;
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
        
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect frame = self.topView.frame;
            CGFloat height = 27;
            CGFloat disheight = 31;
            CGFloat width = 376/2;
            CGFloat x = (SCREEN_WIDTH - width)/2;
            
            frame.size.height = height + disheight + 5 + 8;
            frame.origin.x = x;
            frame.size.width = width;
            self.topView.frame = frame;
            
            //        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            //            CGFloat height = 27;
            //            CGFloat x = 80*kWSCALE;
            //            CGFloat y = [SPDeviceUtil isiPhoneX] ? 34 + (44 - 27)/2 : 20 + (44 - 27)/2;
            //            make.top.mas_equalTo(y);
            //            make.leading.mas_equalTo(x);
            //            make.trailing.mas_equalTo(-x);
            //            make.height.mas_equalTo(height * 2 + 20);
            //        }];
            frame = self.serverBtn.frame;
            frame.origin.y = 5;
            frame.origin.x = 8;
            frame.size.width = self.topView.bounds.size.width - 2 * 8;
            self.serverBtn.frame = frame;
            
            //        [self.serverBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            //            make.top.mas_equalTo(10);
            //        }];
            x = 8;
            CGFloat y = self.serverBtn.frame.origin.y + self.serverBtn.frame.size.height;
            width = self.serverBtn.frame.size.width;
            height = disheight;
            
            self.disconnBtn.frame = CGRectMake(x, y, width, height);
            
            //            [self.topView addSubview:self.disconnBtn];
            //        [self.disconnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            //            make.leading.mas_equalTo(16);
            //            make.trailing.mas_equalTo(-16);
            //            make.height.mas_equalTo(27);
            //            make.bottom.mas_equalTo(-10);
            //        }];
            self.disconnBtn.layer.cornerRadius = 15.5;
            self.disconnBtn.layer.masksToBounds = YES;
            
            self.topView.layer.cornerRadius = 20;
            self.topView.layer.masksToBounds = YES;
            
            self.maskView.alpha = 0.4;
        }];
        [UIView animateWithDuration:0.15 delay:0.15 options:0 animations:^{
            self.disconnBtn.alpha = 1.0;
        } completion:nil];
    }else{
        _showDisconnect = NO;
        //            [self.disconnBtn removeFromSuperview];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.topView.frame;
            CGFloat height = 27;
            CGFloat width = 334/2;
            CGFloat x = (SCREEN_WIDTH - width)/2;
            frame.origin.x = x;
            frame.size.width = width;
            frame.size.height = height;
            self.topView.frame = frame;
            
            //        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            //            CGFloat height = 27;
            //            CGFloat x = 80*kWSCALE;
            //            CGFloat y = [SPDeviceUtil isiPhoneX] ? 34 + (44 - 27)/2 : 20 + (44 - 27)/2;
            //            make.top.mas_equalTo(y);
            //            make.leading.mas_equalTo(x);
            //            make.trailing.mas_equalTo(-x);
            //            make.height.mas_equalTo(height);
            //        }];
            frame = self.serverBtn.frame;
            frame.origin.y = 0;
            frame.size.width = self.topView.bounds.size.width - 2 * 8;
            self.serverBtn.frame = frame;
            //        [self.serverBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            //            make.top.mas_equalTo(0);
            //        }];
            
            frame = self.disconnBtn.frame;
            frame.origin.y = 0;
            frame.size.width = self.serverBtn.frame.size.width;
            self.disconnBtn.frame = frame;
            
            self.topView.layer.cornerRadius = 13.5;
            self.topView.layer.masksToBounds = YES;
            
            self.maskView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.maskView removeFromSuperview];
        }];
        
        [UIView animateWithDuration:0.15 animations:^{
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


//
//  SPAirScreenViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/1.
//

#import "SPAirScreenViewController.h"
#import "SPAirScreenHelpViewController.h"
#import "ServiceCall.h"
#import "SPVideo.h"
#import "UILabel+SPAttri.h"

typedef enum : NSUInteger {
    StartupStatus,
    SearchStatus,
    ResultStatus,
    ResultEmptyStatus
} AirScreenStatus;

@interface SPAirScreenViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSArray<SPAirscreen *> *_dataArr;
    BOOL _socketOpened;
}

@property (nonatomic, strong) NSArray<SPAirscreen *> *dataArr;
@property (nonatomic, strong) SPAirscreen *   airscreen;
@property (nonatomic, assign) AirScreenStatus status;
@property (nonatomic, strong) UIBarButtonItem *helpItem;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pcImgVTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pcImgVHeightConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *pcImgV;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidthConstraint;


@property (weak, nonatomic) IBOutlet UIView *refreshView;
@property (weak, nonatomic) IBOutlet UIImageView *refreshImgv;

@property (weak, nonatomic) IBOutlet UILabel *searchLabel;

@property (weak, nonatomic) IBOutlet UIImageView *num1View;
@property (weak, nonatomic) IBOutlet UIImageView *num2View;
@property (weak, nonatomic) IBOutlet UILabel *instruction1Label;
@property (weak, nonatomic) IBOutlet UILabel *instruction2Label;

@property (nonatomic, strong) UIView *resultView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *devicesLabel;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) CADisplayLink *displink;
@property (nonatomic, strong) NSTimer *sendTimer;

@end

@implementation SPAirScreenViewController
@synthesize emptyView = _emptyView;

- (instancetype)initWithSomething {
    self = [super initWithNibName:@"SPAirScreenViewController" bundle:[Commons resourceBundle]];
    if (self) {
        self.status = StartupStatus;
        [self.searchButton setTitle:@"SEARCH DEVICE" forState:UIControlStateNormal];
        CADisplayLink *displink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tickSocketIO_MainThread)];
        [displink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.displink = displink;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:UNITYTOUINOTIFICATIONNAME object:nil];
    }
    return self;
}

- (void)monitorNetWorkState {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    AFNetworkReachabilityStatus status = [manager networkReachabilityStatus];
    
    __weak typeof(self) ws = self;
    self.netStateBlock = ^(AFNetworkReachabilityStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ws.status = StartupStatus;
            
            [ws updateViewConstraints];
            if (status == -1 || status == 0 || status == 1) {
                SPBackgrondView *backgroundView = [[SPBackgrondView alloc] initWithFrame:ws.view.bounds
                                                                          backgroundType:NoWifi];
                backgroundView.backgroundColor = SPBgColor;
                [ws.view addSubview:backgroundView];
                [ws.view bringSubviewToFront:backgroundView];
                
                ws.emptyView = backgroundView;
            }else {
                [ws.emptyView removeFromSuperview];
            }
        });
    };
    
    self.netStateBlock(status);
}

- (void)receiveMessage:(NSNotification *)notify {
    NSDictionary *dict = [notify userInfo];
    
    if ([dict[@"method"] isEqualToString:@"showResult"]) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [MBProgressHUD hideHUDForView:keyWindow animated:YES];
        
        NSString *jsonStr = dict[@"mediaListResult"];
        if (!jsonStr) {
            return;
        }
        
        SPMediaListResult *listResult = [[SPMediaListResult alloc] mj_setKeyValues:jsonStr];
        
        NSMutableArray *mediaListResult = [[NSMutableArray alloc] initWithCapacity:listResult.list.count];
        for (NSDictionary *info in listResult.list) {
            SPCmdMediaInfo *media = [[SPCmdMediaInfo alloc] mj_setKeyValues:info];
            SPVideo *video = [[SPVideo alloc] init];
            video.path = media.url;
            video.title = media.name;
            video.videoWidth = [NSString stringWithFormat:@"%d", media.width];
            video.videoHeight = [NSString stringWithFormat:@"%d", media.height];
            video.thumbnail_uri = media.thumbnail;
            video.duration = [NSString stringWithFormat:@"%f", media.duration];
            [mediaListResult addObject:video];
        }
        
        NSUInteger selectedIndex = -1;
        NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:AirScreenResultMiddleVCType],
                                 kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex],
                                 kParams : @{@"dataSource": mediaListResult, @"airscreen" :_airscreen}
                                 };
        
        [self.view bubbleEventWithUserInfo:notify];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateViewConstraints];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self resetViewsAndConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pcImgVHeightConstraint.constant = 270 * kHSCALE;
    
    NSMutableAttributedString *instruction1Attr = [[NSMutableAttributedString alloc] initWithString:@"INSTALL SKYBOX FOR PC FROM SKYBOX.XYZ"];
    
    UIFont *lightFont = [UIFont fontWithName:@"Calibri-Light" size:13.0];
    UIFont *boldFont = [UIFont fontWithName:@"Calibri-Bold" size:13.0];
    [instruction1Attr addAttributes:@{NSFontAttributeName : lightFont, NSForegroundColorAttributeName:[SPColorUtil getHexColor:@"#cccccc"]} range:NSMakeRange(0, 8)];
    [instruction1Attr addAttributes:@{NSFontAttributeName : boldFont, NSForegroundColorAttributeName:[SPColorUtil getHexColor:@"#ffffff"]} range:NSMakeRange(8, 6)];
    [instruction1Attr addAttributes:@{NSFontAttributeName : lightFont, NSForegroundColorAttributeName:[SPColorUtil getHexColor:@"#cccccc"]} range:NSMakeRange(14, 13)];
    [instruction1Attr addAttributes:@{NSFontAttributeName : boldFont, NSForegroundColorAttributeName:[SPColorUtil getHexColor:@"#ffffff"]} range:NSMakeRange(27, 10)];
    
    self.instruction1Label.attributedText = [instruction1Attr copy];
    
    NSMutableAttributedString *instruction2Attr = [[NSMutableAttributedString alloc] initWithString:@"RUN SKYBOX FOR PC AND ADD VIDEOS TO IT"];
    [instruction2Attr addAttributes:@{NSFontAttributeName : lightFont, NSForegroundColorAttributeName:[SPColorUtil getHexColor:@"#cccccc"]} range:NSMakeRange(0, 4)];
    [instruction2Attr addAttributes:@{NSFontAttributeName : boldFont, NSForegroundColorAttributeName:[SPColorUtil getHexColor:@"#ffffff"]} range:NSMakeRange(4, 6)];
    [instruction2Attr addAttributes:@{NSFontAttributeName : lightFont, NSForegroundColorAttributeName:[SPColorUtil getHexColor:@"#cccccc"]} range:NSMakeRange(10, 28)];
    self.instruction2Label.attributedText = [instruction2Attr copy];
    
    self.searchLabel.text = @"SEARCHING...";
    self.searchLabel.font = [UIFont fontWithName:@"Calibri-Light" size:14.0];
    self.searchLabel.textColor = [SPColorUtil getHexColor:@"#ffffff"];
    
    self.searchButton.titleLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:15.0];
    [self.searchButton setTitleColor:[SPColorUtil getHexColor:@"#3c3f48"] forState:UIControlStateNormal];
    self.searchButton.backgroundColor = [SPColorUtil getHexColor:@"#ffde9e"];
    [self.searchButton setTitle:@"SEARCH DEVICE" forState:UIControlStateNormal];
    self.searchButton.layer.cornerRadius = 21.0;//
    self.searchButton.layer.borderWidth = 0.0f;//设置边框颜色
    self.searchButton.layer.masksToBounds = YES;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    [self monitorNetWorkState];
}

- (NSString *)titleOfLabelView {
    return @"AIRSCREEN";
}

- (NSArray *)rightNaviItem {
    return @[self.helpItem];
}

- (UIBarButtonItem *)helpItem {
    if (!_helpItem) {
        UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [helpBtn setImage:[Commons getPdfImageFromResource:@"AirScreen_titlebar_button_help"] forState:UIControlStateNormal];
        helpBtn.backgroundColor = [UIColor clearColor];
        helpBtn.frame = CGRectMake(0, 0, 20, 20);
        [helpBtn addTarget:self action:@selector(helpItemClick:) forControlEvents:UIControlEventTouchUpInside];
        _helpItem = [[UIBarButtonItem alloc] initWithCustomView:helpBtn];
    }
    return _helpItem;
}

- (void)helpItemClick:(UIButton *)sender {
    SPAirScreenHelpViewController *airScreenHelp = [[SPAirScreenHelpViewController alloc] initWithNibName:@"SPAirScreenHelpViewController" bundle:[Commons resourceBundle]];
    [self presentViewController:airScreenHelp animated:YES completion:nil];
}

- (void)showOrHiddenInstructionViews:(BOOL)hidden {
    _num1View.hidden = hidden;
    _num2View.hidden = hidden;
    
    _instruction1Label.hidden = hidden;
    _instruction2Label.hidden = hidden;
}
- (void)resetViewsAndConstraints {
    if (_status == StartupStatus) {
        self.searchButton.titleLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:15.0];
        [self.searchButton setTitleColor:[SPColorUtil getHexColor:@"#3c3f48"] forState:UIControlStateNormal];
        self.searchButton.backgroundColor = [SPColorUtil getHexColor:@"#ffde9e"];
        [self.searchButton setTitle:@"SEARCH DEVICE" forState:UIControlStateNormal];
        self.searchButton.layer.cornerRadius = 21.0;//
        self.searchButton.layer.borderWidth = 0.0f;//设置边框颜色
        self.searchButton.layer.masksToBounds = YES;
    }else{
        self.searchButton.titleLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:15.0];
        [self.searchButton setTitleColor:[SPColorUtil getHexColor:@"#ffffff"] forState:UIControlStateNormal];
        self.searchButton.backgroundColor = [UIColor clearColor];
        [self.searchButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        self.searchButton.layer.cornerRadius = 21.0;//
        self.searchButton.layer.borderColor = [UIColor whiteColor].CGColor;//设置边框颜色
        self.searchButton.layer.borderWidth = 2.0f;//设置边框颜色
        self.searchButton.layer.masksToBounds = YES;
    }
    
    switch (_status) {
        case StartupStatus:
        {
            [self.resultView removeFromSuperview];
            _pcImgVTopConstraint.constant = [SPDeviceUtil isiPhoneX] ? (160 - 34 - 44) : (160 - 64);
            _contentViewTopConstraint.constant = -50;
            
            CGFloat width1 = [self.instruction1Label labelSizeWithAttributeString].width;
            CGFloat width2 = [self.instruction2Label labelSizeWithAttributeString].width;
            _contentViewWidthConstraint.constant = MAX(width1, width2) + 6 + 18;
            _contentViewHeightConstraint.constant = 18 * 2 + 12;
            _refreshView.hidden = YES;
            [self showOrHiddenInstructionViews:NO];
        }
            break;
        case SearchStatus:
        {
            self.searchLabel.text = @"SEARCHING...";
            self.searchLabel.font = [UIFont fontWithName:@"Calibri-Light" size:14.0];
            self.searchLabel.textColor = [SPColorUtil getHexColor:@"#ffffff"];
            _pcImgVTopConstraint.constant = [SPDeviceUtil isiPhoneX] ? (160 - 34 - 44) : (160 - 64);
            CGFloat width1 = [self.instruction1Label labelSizeWithAttributeString].width;
            CGFloat width2 = [self.instruction2Label labelSizeWithAttributeString].width;
            _contentViewWidthConstraint.constant = MAX(width1, width2) + 6 + 18;
            _contentViewTopConstraint.constant = -50;
            _contentViewHeightConstraint.constant = 18 * 2 + 12;
            [self showOrHiddenInstructionViews:YES];
            _refreshView.hidden = NO;
            
            [self configRefreshImageView];
        }
            break;
        case ResultStatus:
        {
            _contentViewTopConstraint.constant = -60;
            CGFloat topH = [SPDeviceUtil isiPhoneX] ? (160 - 34 - 44) : (160 - 64);
            
            CGFloat height = 35;
            if (_dataArr.count >= 4) {
                height = height + 42 * 3 + 21;
                topH = topH -   (4 -1) * 21;
            }else{
                height = height + 42 * _dataArr.count;
                topH = topH -  (_dataArr.count -1) * 21;
            }
            
            _pcImgVTopConstraint.constant = topH;
            
            _contentViewWidthConstraint.constant = 286;
            _contentViewHeightConstraint.constant = height;
            [self showOrHiddenInstructionViews:YES];
            _refreshView.hidden = YES;
            [self.contentView addSubview:self.resultView];
            [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0 ));
            }];
        }
            break;
        case ResultEmptyStatus:
        {
            [self.resultView removeFromSuperview];
            [self.refreshImgv stopAnimating];
            self.refreshImgv.image = [Commons getImageFromResource:@"AirScreen_search_warning"];
            
            UIFont *lightFont = [UIFont fontWithName:@"Calibri-Light" size:14.0];
            self.searchLabel.text = @"CANNOT FIND ANY DEVICES, PLEASE TRY AGAIN";
            self.searchLabel.font = lightFont;
            self.searchLabel.textColor = [SPColorUtil getHexColor:@"#ffffff"];
            
            CGFloat width = [self.searchLabel labelSizeWithAttributes:@{NSFontAttributeName : lightFont, NSForegroundColorAttributeName:[SPColorUtil getHexColor:@"#ffffff"]}].width;
            
            _contentViewWidthConstraint.constant = width + 8 + 20;
            
            _pcImgVTopConstraint.constant = [SPDeviceUtil isiPhoneX] ? (160 - 34 - 44) : (160 - 64);
            _contentViewTopConstraint.constant = -50;
            _contentViewHeightConstraint.constant = 18 * 2 + 12;
            [self showOrHiddenInstructionViews:YES];
            _refreshView.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (NSArray *)initialImageArray {
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (int i = 1; i < 15; i++) {
        NSString *imageName = [NSString stringWithFormat:@"Home_videos_album_loading_000%02d", (i*2 + 1)];
        
        UIImage *image = [Commons getImageFromResource:imageName];
        if (image) {
            [imageArray addObject:image];
        }
    }
        
    return imageArray;
}

// 配置imageview的序列帧动画属性
- (void)configRefreshImageView {
    self.refreshImgv.animationImages = [self initialImageArray];// 序列帧动画的uiimage数组
    self.refreshImgv.animationDuration = 1.0f;// 序列帧全部播放完所用时间
    self.refreshImgv.animationRepeatCount = MAXFLOAT;// 序列帧动画重复次数
    [self.refreshImgv startAnimating];//开始动画
}

- (void)tickSocketIO_MainThread {
    if (_socketOpened) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"TickSocketIO"}];
    }
}

- (void)stopSearch {
    if (_socketOpened) {
        [self.sendTimer invalidate];
    }
}
- (void)closeAirscreen {
    [self.sendTimer invalidate];
    
    if (_socketOpened) {
        _socketOpened = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"DestroySKYBOX"}];
    }
}

- (void)releaseAction {
    [self closeAirscreen];
    
    [self.displink invalidate];
    self.displink = nil;
    
    [self.sendTimer invalidate];
    self.sendTimer = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UNITYTOUINOTIFICATIONNAME object:nil];
    NSLog(@"airscreen 销毁。。。。。。。");
}
- (void)startupAirscreen {
    if (!_socketOpened) {
        _socketOpened = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"StartSKYBOX"}];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.sendTimer fire];
        });
    }
}

- (NSTimer *)sendTimer {
    if (!_sendTimer) {
        if (@available(iOS 10.0, *)) {
            _sendTimer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
                if (_socketOpened) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"UdpSendTo"}];
                }
            }];
        } else {
            // Fallback on earlier versions
            _sendTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(sendUdpPackage) userInfo:nil repeats:YES];
        }
        
        [[NSRunLoop currentRunLoop] addTimer:_sendTimer forMode:NSRunLoopCommonModes];
    }
    
    return _sendTimer;
}

- (void)sendUdpPackage {
    if (_socketOpened) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"UdpSendTo"}];
    }
}

- (void)connectServer:(SPAirscreen *)airscreen {
    if (_socketOpened) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"WebSocketConnect", @"airscreen" : airscreen}];
    }
    
}

- (IBAction)searchClick:(id)sender {
    switch (_status) {
        case StartupStatus:
        {
            _status = SearchStatus;
            
            [self startupAirscreen];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (_status == StartupStatus) {
                    return;
                }
                
                [self stopSearch];
                _status = ResultStatus;
                [self showResultView];
            });
        }
            break;
        case SearchStatus:
        {
            _status = StartupStatus;
            
            [self stopSearch];
        }
            break;
        case ResultStatus:
        {
            _status = StartupStatus;
        }
            break;
        case ResultEmptyStatus:
        {
            _status = StartupStatus;
        }
            break;
        default:
            break;
    }
    
    [self updateViewConstraints];
}

- (void)showResultView {
//    _dataArr = nil;
//    _status = ResultEmptyStatus;
//    [self updateViewConstraints];
    
    __weak typeof(self) ws = self;
    self.refreshBlock = ^(NSString *dataStr){
        if (!ws) {
            return ;
        }
        
        __strong typeof(ws) strongfy = ws;
        strongfy.dataArr = [SPAirscreen mj_objectArrayWithKeyValuesArray:dataStr];
        //        strongfy.dataArr = nil;
        //        NSMutableArray *arr = [strongfy.dataArr copy];
        //        strongfy.dataArr = [arr subarrayWithRange:NSMakeRange(0, 5)];
        
        strongfy.devicesLabel.text = [NSString stringWithFormat:@"%lu DEVICES FOUND", (unsigned long)[strongfy.dataArr count]];
        if (strongfy.dataArr.count == 0) {
            _status = ResultEmptyStatus;
        }
        
        [strongfy updateViewConstraints];
        [strongfy.tableView reloadData];
    };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"GetDevices", @"resultBlock" : self.refreshBlock}];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = [UIColor darkGrayColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.layer.cornerRadius = 21;
        _tableView.layer.masksToBounds = YES;
    }
    
    return _tableView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        
        _devicesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _devicesLabel.text = @"4 DEVICES FOUND";
        _devicesLabel.font = [UIFont systemFontOfSize:13];
        _devicesLabel.textAlignment = NSTextAlignmentCenter;
        [_devicesLabel sizeToFit];
        [_topView addSubview:_devicesLabel];
        [_devicesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
        }];
        
        //line
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectZero];
        line1.backgroundColor = [UIColor whiteColor];
        [_topView addSubview:line1];
        
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(2);
            make.centerY.mas_equalTo(0);
            make.leading.mas_equalTo(5);
            make.trailing.equalTo(_devicesLabel.mas_leading).mas_equalTo(-8);
        }];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectZero];
        line2.backgroundColor = [UIColor whiteColor];
        [_topView addSubview:line2];
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(2);
            make.centerY.mas_equalTo(0);
            make.trailing.mas_equalTo(-5);
            make.leading.equalTo(_devicesLabel.mas_trailing).mas_equalTo(8);
        }];
        
    }
    
    return _topView;
}
- (UIView *)resultView {
    if (!_resultView) {
        UIView *reultV = [[UIView alloc] initWithFrame:CGRectZero];
        reultV.backgroundColor = [UIColor clearColor];
        _resultView = reultV;
        
        [_resultView addSubview:self.topView];
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30*kHSCALE);
            make.leading.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.trailing.mas_equalTo(0);
        }];
        
        [_resultView addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_bottom).mas_equalTo(5);
            make.leading.mas_equalTo(0);
            make.trailing.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
    
    return _resultView;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

static NSString *cellID = @"AIRSCREEN_CELLID";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [_dataArr[indexPath.row] computerName];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPAirscreen *air = _dataArr[indexPath.row];
    if (!air) {
        return;
    }
    
    _airscreen = air;
    [self connectServer:air];
}
@end



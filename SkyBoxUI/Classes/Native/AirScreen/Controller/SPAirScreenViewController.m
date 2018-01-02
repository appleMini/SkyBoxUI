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

typedef enum : NSUInteger {
    StartupStatus,
    SearchStatus,
    ResultStatus,
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
@property (weak, nonatomic) IBOutlet UIImageView *pcImgV;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *refreshView;
@property (weak, nonatomic) IBOutlet UIView *refreshImgv;

@property (weak, nonatomic) IBOutlet UIView *num1View;
@property (weak, nonatomic) IBOutlet UIView *num2View;
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
        
        [self closeAirscreen];
        
        NSUInteger selectedIndex = -1;
        NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:AirScreenResultMiddleVCType],
                                 kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex],
                                 kParams : @{@"dataSorece": mediaListResult, @"airscreen" :_airscreen}
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
    self.pcImgV.image = [Commons getPdfImageFromResource:@"Channels_icon_airscreen"];
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
        [helpBtn setImage:nil forState:UIControlStateNormal];
        helpBtn.backgroundColor = [UIColor blueColor];
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
    switch (_status) {
        case StartupStatus:
        {
            [self.resultView removeFromSuperview];
            _pcImgVTopConstraint.constant = 80*kHSCALE;
            _contentViewHeightConstraint.constant = 80*kHSCALE;
            _refreshView.hidden = YES;
            [self showOrHiddenInstructionViews:NO];
        }
            break;
        case SearchStatus:
        {
            _pcImgVTopConstraint.constant = 80*kHSCALE;
            _contentViewHeightConstraint.constant = 80*kHSCALE;
            [self showOrHiddenInstructionViews:YES];
            _refreshView.hidden = NO;
        }
            break;
        case ResultStatus:
        {
            _pcImgVTopConstraint.constant = [SPDeviceUtil isiPhoneX] ? 40 : 20*kHSCALE;
            _contentViewHeightConstraint.constant = 190*kHSCALE;
            [self showOrHiddenInstructionViews:YES];
            _refreshView.hidden = YES;
            [self.contentView addSubview:self.resultView];
            [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0 ));
            }];
        }
            break;
        default:
            break;
    }
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
    if (_status == StartupStatus) {
        [self.searchButton setTitle:@"CANCEL" forState:UIControlStateNormal];
    }else{
        [self.searchButton setTitle:@"SEARCH DEVICE" forState:UIControlStateNormal];
    }
    
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
        default:
            break;
    }
    
    [self updateViewConstraints];
}

- (void)showResultView {
    __weak typeof(self) ws = self;
    self.refreshBlock = ^(NSString *dataStr){
        NSLog(@"showResultView  === %@", dataStr);
        if (!ws) {
            return ;
        }
        
        __strong typeof(ws) strongfy = ws;
        strongfy.dataArr = [SPAirscreen mj_objectArrayWithKeyValuesArray:dataStr];
        strongfy.devicesLabel.text = [NSString stringWithFormat:@"%lu DEVICES FOUND", (unsigned long)[strongfy.dataArr count]];
        
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
        _tableView.layer.cornerRadius = 15;
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
        reultV.backgroundColor = [UIColor blueColor];
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
    return 40;
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



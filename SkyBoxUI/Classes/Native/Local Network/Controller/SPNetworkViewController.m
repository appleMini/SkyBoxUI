//
//  SPNetworkViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/18.
//

#import "SPNetworkViewController.h"
#import "SPHeaderView.h"
#import "SPVideo.h"
#import "SPDLANView.h"
#import "TGRefresh.h"
#import "SPDLANManager.h"
#import "SPWaterFallLayout.h"
#import "SPDataManager.h"

@interface SPNetworkViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, SPDLANManagerDelegate, SPWaterFallLayoutDelegate> {
    NSMutableArray *_dataArr;
    NSInteger _level;
}

@property (nonatomic, assign) DisplayType       showType;
@property (nonatomic, strong) UICollectionView  *collectionView;
@property (nonatomic, strong) SPHeaderView      *headerView;
@property (nonatomic, copy) NSString            *cellIditify;
@property (nonatomic, strong) UIBarButtonItem   *menuItem;
@property (nonatomic, strong) UIButton          *menuBtn;

@property (nonatomic, strong) SPDLANManager     *dlanManager;

@property (nonatomic, strong) NSString          *currentDeviceID;
@property (nonatomic, strong)  UIImageView *gradientV;
@end

@implementation SPNetworkViewController
@synthesize emptyView = _emptyView;

- (instancetype)initWithSomething {
    self = [self initWithDisplayType:CollectionViewType];
    if (self) {
    }
    return self;
}

- (instancetype)initWithDisplayType:(DisplayType)show
{
    self = [super init];
    if (self) {
        _level = -1;
        _showType = show;
        _dataArr = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithDataSource:(NSArray *)data  displayType:(DisplayType)show {
    self = [self initWithDisplayType:show];
    if (self) {
        _dataArr = [data copy];
    }
    return self;
}

- (void)viewWillToChanged {
    SPCmdAddDevice *__currentDevice = [SPDataManager shareSPDataManager].currentDevice;
    if ((!__currentDevice) || ([_currentDeviceID hash] == [__currentDevice.ObjIDStr hash])) {
        return;
    }
    
    [self reloadDevice];
}

- (void)releaseAction {
//    [_dlanManager releaseAction];
//    _dlanManager = nil;
}

- (void)dealloc {
    [_dlanManager releaseAction];
    _dlanManager = nil;
    //   NSLog(@"NetworkViewController  释放.....");
}

- (void)reloadDevice {
    self.dlanManager = [SPDLANManager shareDLANManager];
    self.dlanManager.delegate = self;
    
    NSArray *devices = [SPDataManager shareSPDataManager].devices;
    if (devices) {
        [self.headerView setDevices:[devices mutableCopy]];
    }
    [self.dlanManager showDLANDevices];
}

- (void)monitorNetWorkState {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    AFNetworkReachabilityStatus status = [manager networkReachabilityStatus];
    
    __weak typeof(self) ws = self;
    self.netStateBlock = ^(AFNetworkReachabilityStatus status) {
        if (status == -1 || status == 0 || status == 1) {
            SPBackgrondView *backgroundView = [[SPBackgrondView alloc] initWithFrame:ws.view.bounds
                                                                      backgroundType:NoWifi];
            backgroundView.backgroundColor = SPBgColor;
            [ws.view addSubview:backgroundView];
            [ws.view bringSubviewToFront:backgroundView];
            
            ws.emptyView = backgroundView;
            
            [ws.headerView cleanHeadViews];
            [ws.dlanManager releaseAction];
            ws.dlanManager = nil;
        }else {
            [ws.emptyView removeFromSuperview];
            [ws reloadDevice];
        }
    };
    
    self.netStateBlock(status);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHeaderView];
    [self setupScrollView];
    
    [self setupMaskView];
    [self setupGradientLayer];
    
    [self.view bringSubviewToFront:self.headerView];
    [self monitorNetWorkState];
    
    self.view.clipsToBounds = YES;
}

- (void)setupMaskView {
    UIView *mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 28 * kWSCALE)];
    mask.backgroundColor = SPBgColor;
    
    [self.view insertSubview:mask aboveSubview:self.collectionView];
}

- (void)setupGradientLayer {
    if (_gradientV) {
        return;
    }
    
    CGFloat H = 28 * kWSCALE + 20 - 64;
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, H, self.view.frame.size.width, 64)];
    imgv.image = [Commons getImageFromResource:@"Network_list_mask@2x"];
    [self.view addSubview:imgv];
    _gradientV = imgv;
    _gradientV.hidden = YES;
}

- (NSString *)titleOfLabelView {
    return @"Local Network";
}

- (NSString *)cellIditify {
    return @"Local_Network_CellID";
}

- (NSArray *)leftNaviItem {
    return nil;
}

- (void)reload {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!_dataArr || _dataArr.count <= 0) {
            [_emptyView removeFromSuperview];
            _emptyView = nil;
            
            SPBackgrondView *backgroundView = [[SPBackgrondView alloc] initWithFrame:self.view.bounds backgroundType:(_level == -1 ? NoLocalMediaServers : NoFiles)];
            [self.view insertSubview:backgroundView aboveSubview:self.collectionView];
            [self.view bringSubviewToFront:self.headerView];
            _emptyView = backgroundView;
        }else{
            [_emptyView removeFromSuperview];
            _emptyView = nil;
        }
        
        [self.collectionView reloadData];
    });
}

- (void)setupHeaderView {
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat left = 10;
        CGFloat top = 0;
        CGFloat right = -10;
        CGFloat height = 28 * kWSCALE;
        if (@available(iOS 11.0, *)) {
            left = left + self.view.safeAreaInsets.left;
            top = top + self.view.safeAreaInsets.top;
            right = right + self.view.safeAreaInsets.right;
        }
        
        make.left.mas_equalTo(left);
        make.right.mas_equalTo(right);
        make.top.mas_equalTo(top);
        make.height.mas_equalTo(height);
    }];
    
}

- (UIView *)headerView {
    if (!_headerView) {
        SPHeaderView *headerView = [[SPHeaderView alloc] init];
        
        _headerView = headerView;
    }
    
    return _headerView;
}

- (void)setupScrollView {
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).mas_offset(22);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        //        if (@available(iOS 11.0, *)) {
        //            make.edges.mas_equalTo(UIEdgeInsetsMake(self.view.safeAreaInsets.top + 40 + 22, self.view.safeAreaInsets.left, self.view.safeAreaInsets.bottom, self.view.safeAreaInsets.right));
        //        } else {
        //            make.edges.mas_equalTo(UIEdgeInsetsMake(40 + 22, 0, 0, 0));
        //        }
    }];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        // 创建瀑布流layout
        SPWaterFallLayout *layout = [[SPWaterFallLayout alloc] init];
        // 设置代理
        layout.delegate = self;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[SPDLANCollectionCell class] forCellWithReuseIdentifier:[self cellIditify]];
        _collectionView.backgroundColor = [UIColor clearColor];
        adjustsScrollViewInsets(_collectionView);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.clipsToBounds = NO;
    }
    
    return _collectionView;
}

#pragma -mark UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SPDLANCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self cellIditify] forIndexPath:indexPath];
    cell.dlanView.device = _dataArr[indexPath.row];
    return cell;
}

#pragma mark - <SPWaterFallLayoutDelegate>
/**
 *  返回每个item的高度
 */
static CGFloat height = 0;
- (CGFloat)waterFallLayout:(SPWaterFallLayout *)waterFallLayout heightForItemAtIndex:(NSInteger)index width:(CGFloat)width
{
    if(height == 0) {
        NSAttributedString *attriStr = [[NSAttributedString alloc] initWithString:@"labelHeight" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Calibri-Bold" size:15]}];
        CGFloat labelHeight = [attriStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine)  context:nil].size.height;
        
        NSAttributedString *attriStr1 = [[NSAttributedString alloc] initWithString:@"durationLabelHeight" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Calibri-light" size:12]}];
        CGFloat durationLabelHeight = [attriStr1 boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine)  context:nil].size.height;
        
        CGFloat imgvHeight = 208 * (SCREEN_WIDTH - 17 * 3) / 2 / 324;
        height = labelHeight + durationLabelHeight + imgvHeight + 8 + 8;
    }
    
    return height;
}

- (CGFloat)columnMarginOfWaterFallLayout:(SPWaterFallLayout *)waterFallLayout
{
    return 17;
}

- (NSUInteger)columnCountOfWaterFallLayout:(SPWaterFallLayout *)waterFallLayout
{
    return 2;
}

- (CGFloat)rowMarginOfWaterFallLayout:(SPWaterFallLayout *)waterFallLayout
{
    return 17;
}

- (UIEdgeInsets)edgeInsetsOfWaterFallLayout:(SPWaterFallLayout *)waterFallLayout
{
    return UIEdgeInsetsMake(0, 17, kWSCALE*94 - 29, 17);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SPCmdAddDevice *device = _dataArr[indexPath.row];
    if(device.deviceType && [device.deviceType containsString:@"object.item.videoItem"]){
        NSUInteger selectedIndex = -1;
        NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:NativeToUnityType],
                                 kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex],
                                 @"path" : ((SPCmdVideoDevice *)device).videoUrl
                                 };
        
        [self bubbleEventWithUserInfo:notify];
        return;
    }
    
    self.headerView.device = device;
    [_dlanManager browseDLNAFolder:device];
}
#pragma -mark SPDLANManagerDelegate
- (void)addDlanDevice:(SPCmdAddDevice *)device parentID:(NSString *)pid {
    if(!device) {
        _dataArr = nil;
        [self reload];
        return;
    }
    
    if ([[SPDLANManager shareDLANManager] status] != DLANAddDeviceStatus) {
        return;
    }
    if (_level != [pid integerValue]) {
        _dataArr = [NSMutableArray array];
        _level = [pid integerValue];
    }
    if (_dataArr) {
        for (SPCmdAddDevice *addDevice in _dataArr) {
            if ([addDevice.deviceId isEqualToString:[device deviceId]]) {
                return;
            }
        }
        
        [_dataArr addObject:device];
        [self reload];
    }
    
    _currentDeviceID = pid;
}

- (void)browseDLNAFolder:(NSArray<SPCmdAddDevice *> *)folders parentID:(NSString *)pid {
    if ([[SPDLANManager shareDLANManager] status] != DLANBrowseFolderStatus) {
        return;
    }
    
    _level = [pid integerValue];
    _dataArr = [NSMutableArray array];
    
    _dataArr = [folders copy];
    [self reload];
    _currentDeviceID = pid;
}

#pragma -mark scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_dataArr || _dataArr.count <= 0) {
        return;
    }
    
    CGFloat offsetY =  scrollView.contentOffset.y;
    _gradientV.hidden = (offsetY <= 0);
    
    CGFloat Height = 2 * offsetY;
    if (offsetY >= 32.0) {
        Height = 64.0;
    }else if(offsetY <= 0){
        Height = 0.0;
    }
    
    CGRect frame = _gradientV.frame;
    frame.origin.y = (28 * kWSCALE - 64) + Height;
    
    _gradientV.frame = frame;
    //        _gradientV.backgroundColor = [UIColor purpleColor];
//    _gradientV.image = [SPColorUtil getGradientLayerIMG:64 width:self.view.frame.size.width fromColor:RGBACOLOR(59, 63, 72, 1.0) toColor:RGBACOLOR(59, 63, 72, 0.0) startPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 1.0)];
    
    [self.view bringSubviewToFront:_gradientV];
    [self.view bringSubviewToFront:self.headerView];
}
@end


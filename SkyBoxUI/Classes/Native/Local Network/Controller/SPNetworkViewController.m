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

@interface SPNetworkViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, SPDLANManagerDelegate, SPWaterFallLayoutDelegate> {
    NSMutableArray *_dataArr;
    NSInteger _level;
}

@property (nonatomic, assign) DisplayType showType;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) SPHeaderView *headerView;
@property (nonatomic, copy) NSString *cellIditify;
@property (nonatomic, strong) UIBarButtonItem *menuItem;
@property (nonatomic, strong) UIButton *menuBtn;

@property (nonatomic, strong) SPDLANManager *dlanManager;
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

- (void)dealloc {
    [_dlanManager releaseAction];
    _dlanManager = nil;
    NSLog(@"NetworkViewController  释放.....");
}

- (void)monitorNetWorkState {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    AFNetworkReachabilityStatus status = [manager networkReachabilityStatus];
    
    __weak typeof(self) ws = self;
    self.netStateBlock = ^(AFNetworkReachabilityStatus status) {
        if (status == -1 || status == 0 || status == 1) {
            SPBackgrondView *backgroundView = [[SPBackgrondView alloc] initWithFrame:ws.view.bounds
                                                                      backgroundType:NoWifi];
            backgroundView.backgroundColor = RGBCOLOR(59, 63, 72);
            [ws.view addSubview:backgroundView];
            [ws.view bringSubviewToFront:backgroundView];
            
            ws.emptyView = backgroundView;
            [ws.dlanManager releaseAction];
            ws.dlanManager = nil;
        }else {
            [ws.emptyView removeFromSuperview];
            ws.dlanManager = [SPDLANManager shareDLANManager];
            ws.dlanManager.delegate = ws;
        }
    };
    
    self.netStateBlock(status);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupHeaderView];
    [self setupScrollView];
    
    [self monitorNetWorkState];
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
            SPBackgrondView *backgroundView = [[SPBackgrondView alloc] initWithFrame:self.view.bounds backgroundType:(_level == -1 ? NoLocalMediaServers : NoFiles)];
            [self.view insertSubview:backgroundView aboveSubview:self.collectionView];
            
            _emptyView = backgroundView;
            return;
        }else{
            [_emptyView removeFromSuperview];
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
        CGFloat height = 28;
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
    return UIEdgeInsetsMake(0, 17, 0, 17);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SPCmdAddDevice *device = _dataArr[indexPath.row];
    if(device.deviceType && [device.deviceType isEqualToString:@"object.item.videoItem"]){
        NSUInteger selectedIndex = -1;
        NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:NativeToUnityType],
                                 kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex]
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
    
    if ([[SPDLANManager shareDLANManager] status] != AddDeviceStatus) {
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
        [self.collectionView reloadData];
    }
}

- (void)browseDLNAFolder:(NSArray<SPCmdAddDevice *> *)folders parentID:(NSString *)pid {
    if ([[SPDLANManager shareDLANManager] status] != BrowseFolderStatus) {
        return;
    }
    
    _level = [pid integerValue];
    _dataArr = [NSMutableArray array];
    
    _dataArr = [folders copy];
    [self.collectionView reloadData];
}
@end


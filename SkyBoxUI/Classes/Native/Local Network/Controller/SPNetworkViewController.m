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

@interface SPNetworkViewController ()<UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource, SPDLANManagerDelegate, SPWaterFallLayoutDelegate> {
    NSMutableArray *_dataArr;
    NSInteger _level;
}

@property (nonatomic, assign) DisplayType showType;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SPHeaderView *headerView;
@property (nonatomic, copy) NSString *cellIditify;
@property (nonatomic, strong) UIBarButtonItem *menuItem;
@property (nonatomic, strong) UIButton *menuBtn;

@property (nonatomic, strong) SPDLANManager *dlanManager;
@end

@implementation SPNetworkViewController

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
        _dlanManager = [SPDLANManager shareDLANManager];
        _dlanManager.delegate = self;
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

- (NSString *)titleOfLabelView {
    return @"Local Network";
}

- (NSString *)cellIditify {
    return @"Local_Network_CellID";
}

- (void)setupMenuImage {
    switch (_showType) {
        case TableViewType:
        {
            [self.menuBtn setImage:[Commons getPdfImageFromResource:@"Home_titlebar_button_grid"] forState:UIControlStateNormal];
        }
            break;
        case CollectionViewType:
        {
            [self.menuBtn setImage:[Commons getPdfImageFromResource:@"Home_titlebar_button_list"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (UIBarButtonItem *)menuItem {
    if (!_menuItem) {
        UIButton *menuItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuItem setImage:nil forState:UIControlStateNormal];
        menuItem.backgroundColor = [UIColor clearColor];
        [menuItem addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
        _menuBtn = menuItem;
        [self setupMenuImage];
        _menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuItem];
    }
    
    return _menuItem;
}

- (void)menuClick:(UIButton *)item {
    if (self.showType == TableViewType) {
        self.showType = CollectionViewType;
    }else {
        self.showType = TableViewType;
    }
}

- (NSArray *)leftNaviItem {
    return @[self.menuItem];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHeaderView];
    [self setupScrollView];
}

- (void)setupHeaderView {
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat left = 0;
        CGFloat top = 0;
        CGFloat right = 0;
        CGFloat height = 40;
        if (@available(iOS 11.0, *)) {
            left = self.view.safeAreaInsets.left;
            top = self.view.safeAreaInsets.top;
            right = self.view.safeAreaInsets.right;
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
    [self.view addSubview:self.scrollView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(self.view.safeAreaInsets.top + 40, self.view.safeAreaInsets.left, self.view.safeAreaInsets.bottom, self.view.safeAreaInsets.right));
        } else {
            make.edges.mas_equalTo(UIEdgeInsetsMake(40, 0, 0, 0));
        }
    }];
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        switch (_showType) {
            case TableViewType:
            {
                _scrollView = [[UITableView alloc] initWithFrame:CGRectZero];
                adjustsScrollViewInsets(_scrollView);
                _scrollView.backgroundColor = [UIColor clearColor];
                ((UITableView *)_scrollView).delegate = self;
                ((UITableView *)_scrollView).dataSource = self;
                ((UITableView *)_scrollView).separatorStyle = UITableViewCellSeparatorStyleNone;
                [((UITableView *)_scrollView) registerClass:[SPDLANCell class] forCellReuseIdentifier:[self cellIditify]];
            }
                break;
            case CollectionViewType:
            {
                // 创建瀑布流layout
                SPWaterFallLayout *layout = [[SPWaterFallLayout alloc] init];
                // 设置代理
                layout.delegate = self;
                _scrollView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
                [(UICollectionView *)_scrollView registerClass:[SPDLANCollectionCell class] forCellWithReuseIdentifier:[self cellIditify]];
                ((UICollectionView *)_scrollView).backgroundColor = [UIColor clearColor];
                adjustsScrollViewInsets(_scrollView);
                ((UICollectionView *)_scrollView).delegate = self;
                ((UICollectionView *)_scrollView).dataSource = self;
            }
                break;
            default:
                break;
        }
        
        //        [self configRefresh];
    }
    
    return _scrollView;
}

- (void)setShowType:(DisplayType)showType {
    _showType = showType;
    [self setupMenuImage];
    [_scrollView removeFromSuperview];
    _scrollView = nil;
    [self setupScrollView];
}

- (void)refresh {
    [_scrollView.tg_header beginRefreshing];
}

- (void)configRefresh {
    //默认为QQ效果
    _scrollView.tg_header = [TGRefreshOC  refreshWithTarget:self action:@selector(doRefreshSenior) config:nil];
}

- (void)reload {
    switch (_showType) {
        case TableViewType:
            [((UITableView *)self.scrollView) reloadData];
            break;
        case CollectionViewType:
            [((UICollectionView *)self.scrollView) reloadData];
            break;
        default:
            break;
    }
}

- (void)didFinishRequest:(NSArray *)arr {
    _dataArr = [SPVideo mj_objectArrayWithKeyValuesArray:arr];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _scrollView.tg_header.refreshResultStr = @"成功刷新数据";
        [_scrollView.tg_header endRefreshing];
        [self reload];
    });
}


- (void)doRefreshSenior {
    __weak typeof(self) ws = self;
    self.refreshBlock = ^(NSString *dataStr){
        NSLog(@"dataStr === %@", dataStr);
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:[dataStr mj_JSONData] options:NSJSONReadingAllowFragments error:nil];
        
        [ws didFinishRequest:arr];
    };
    
    //     [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"GetLocalFiles", @"resultBlock" : self.refreshBlock}];
    
}


#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPDLANCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIditify]];
    
    if (!cell) {
        cell = [[SPDLANCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self cellIditify]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dlanView.device = _dataArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
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
- (CGFloat)waterFallLayout:(SPWaterFallLayout *)waterFallLayout heightForItemAtIndex:(NSInteger)index width:(CGFloat)width
{
    return 180 * kWSCALE;
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
    
    if (device.deviceType && ![device.deviceType containsString:@"storageFolder"]) {
        
        return ;
    }
    
    [_dlanManager browseDLNAFolder:device];
}
#pragma -mark SPDLANManagerDelegate
- (void)addDlanDevice:(SPCmdAddDevice *)device parentID:(NSString *)pid {
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
        [self reload];
    }
}

- (void)browseDLNAFolder:(NSArray<SPCmdAddDevice *> *)folders parentID:(NSString *)pid {
    if ([[SPDLANManager shareDLANManager] status] != BrowseFolderStatus) {
        return;
    }
    
    _level = [pid integerValue];
    _dataArr = [NSMutableArray array];
    
    _dataArr = [folders copy];
    [self reload];
}
@end


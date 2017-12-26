//
//  SPNetworkViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/18.
//

#import "SPNetworkViewController.h"
#import "SPHeaderView.h"
#import "SPVideo.h"
#import "SPVideoCell.h"
#import "TGRefresh.h"
#import "SPVideoCollectionCell.h"
#import "SPVideoCollectionView.h"

@interface SPNetworkViewController ()<UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource> {
    NSMutableArray *_dataArr;
}

@property (nonatomic, assign) DisplayType showType;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SPHeaderView *headerView;
@property (nonatomic, copy) NSString *cellIditify;
@property (nonatomic, strong) UIBarButtonItem *menuItem;

@end

@implementation SPNetworkViewController

- (instancetype)initWithDisplayType:(DisplayType)show
{
    self = [super init];
    if (self) {
        _showType = show;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:SCANOVERUITOUNITYNOTIFICATIONNAME object:nil];
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

- (NSString *)titleOfLabelView {
    return @"Local Network";
}

- (NSString *)cellIditify {
    return @"Local_Network_CellID";
}

- (UIBarButtonItem *)menuItem {
    if (!_menuItem) {
        UIButton *menuItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuItem setImage:nil forState:UIControlStateNormal];
        menuItem.backgroundColor = [UIColor redColor];
        menuItem.frame = CGRectMake(0, 0, 40, 40);
        [menuItem addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
        
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
                [((UITableView *)_scrollView) registerClass:[SPVideoCell class] forCellReuseIdentifier:[self cellIditify]];
            }
                break;
            case CollectionViewType:
            {
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
                layout.itemSize = CGSizeMake((self.view.frame.size.width-20)/2, 180);
                _scrollView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
                [(UICollectionView *)_scrollView registerClass:[SPVideoCollectionCell class] forCellWithReuseIdentifier:[self cellIditify]];
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

- (void)didFinishRequest:(NSArray *)arr {
    _dataArr = [SPVideo mj_objectArrayWithKeyValuesArray:arr];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _scrollView.tg_header.refreshResultStr = @"成功刷新数据";
        [_scrollView.tg_header endRefreshing];
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
    SPVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIditify]];
    
    if (!cell) {
        cell = [[SPVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self cellIditify]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.videoView.video = _dataArr[indexPath.row];
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
    SPVideoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self cellIditify] forIndexPath:indexPath];
    cell.videoView.video = _dataArr[indexPath.row];
    return cell;
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
@end

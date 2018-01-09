//
//  SPMuliteViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/15.
//

#import "SPMuliteViewController.h"
#import "SPVideo.h"
#import "SPVideoCell.h"
#import "TGRefresh.h"
#import "SPVideoCollectionCell.h"
#import "SPVideoCollectionView.h"
#import "SPWaterFallLayout.h"

@interface SPMuliteViewController ()<UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource, SPWaterFallLayoutDelegate>{
    NSMutableArray *_dataArr;
    DataSourceType _type;
}

@property (nonatomic, assign) DisplayType showType;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, copy) NSString *cellIditify;
@property (nonatomic, strong) UIBarButtonItem *menuItem;
@property (nonatomic, strong) UIButton *menuBtn;
@end

@implementation SPMuliteViewController
@synthesize emptyView = _emptyView;

- (instancetype)initWithType:(DataSourceType)type displayType:(DisplayType)show
{
    self = [super init];
    if (self) {
        _type = type;
        _showType = show;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:SCANOVERUITOUNITYNOTIFICATIONNAME object:nil];
    }
    return self;
}

- (instancetype)initWithDataSource:(NSArray *)data type:(DataSourceType)type displayType:(DisplayType)show {
    self = [self initWithType:type displayType:show];
    if (self) {
        _dataArr = [data copy];
    }
    return self;
}

- (NSString *)cellIditify {
    return @"kCellID";
}

- (UIBarButtonItem *)menuItem {
    if (!_menuItem) {
        UIButton *menuItem = [UIButton buttonWithType:UIButtonTypeCustom];
        //        menuItem.backgroundColor = [UIColor redColor];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupScrollView];
}

- (void)setupScrollView {
    [self.view addSubview:self.scrollView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.edges.mas_equalTo(self.view.safeAreaInsets);
        } else {
            make.edges.mas_equalTo(self.view);
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
                // 创建瀑布流layout
                SPWaterFallLayout *layout = [[SPWaterFallLayout alloc] init];
                // 设置代理
                layout.delegate = self;
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
        
        [self configRefresh];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!_dataArr || _dataArr.count <= 0) {
            self.menuBtn.hidden = YES;
            [_emptyView removeFromSuperview];
            _emptyView = nil;
            SPBackgrondView *backgroundView = nil;
            switch (_type) {
                case LocalFilesType:
                {
                    backgroundView = [[SPBackgrondView alloc] initWithFrame:self.view.bounds backgroundType:NoVideos];
                }
                    break;
                case VRVideosType:
                {
                    backgroundView = [[SPBackgrondView alloc] initWithFrame:self.view.bounds backgroundType:NoVideos];
                }
                    break;
                case FavoriteVideosType:
                {
                    backgroundView = [[SPBackgrondView alloc] initWithFrame:self.view.bounds backgroundType:NoFavorite];
                }
                    break;
                case HistoryVideosType:
                {
                    backgroundView = [[SPBackgrondView alloc] initWithFrame:self.view.bounds backgroundType:NoHistory];
                }
                    break;
                case AirScreenType:
                {
                    backgroundView = [[SPBackgrondView alloc] initWithFrame:self.view.bounds backgroundType:NoAirScreenResult];
                }
                    break;
                default:
                    break;
            }
            
            [self.view insertSubview:backgroundView aboveSubview:self.scrollView];
            
            _emptyView = backgroundView;
        }else{
            self.menuBtn.hidden = NO;
            [_emptyView removeFromSuperview];
            _emptyView = nil;
        }
        
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

- (void)didFinishRequest:(NSArray *)arr {
    if (arr) {
        _dataArr = [SPVideo mj_objectArrayWithKeyValuesArray:arr];
    }
    
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
    
    switch (_type) {
        case LocalFilesType:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"GetLocalFiles", @"resultBlock" : self.refreshBlock}];
        }
            break;
        case VRVideosType:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"GetVRVideos", @"resultBlock" : self.refreshBlock}];
        }
            break;
        case FavoriteVideosType:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"GetFavouriteVideos", @"resultBlock" : self.refreshBlock}];
        }
            break;
        case HistoryVideosType:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"GetHistoryVideos", @"resultBlock" : self.refreshBlock}];
        }
            break;
        case AirScreenType:
        {
            [self didFinishRequest:nil];
        }
            break;
        default:
            break;
    }
    
    //test
    NSString *jsonstr = @"[{\"videoWidth\":320,\"isFavourite\":0,\"rcg_type\":\"1\",\"title\":\"ed 1024 512kb\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/449A3F79-82ED-4648-A798-2DFB392CFBC3.png\",\"duration\":653000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/ed_1024_512kb.mp4\",\"videoHeight\":240},{\"videoWidth\":600,\"isFavourite\":0,\"rcg_type\":\"1\",\"title\":\"EasyMovieTexture\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/772239E4-98E6-4B6D-BDED-196E35A1ED95.png\",\"duration\":176000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/EasyMovieTexture.mp4\",\"videoHeight\":360},{\"videoWidth\":1920,\"isFavourite\":1,\"rcg_type\":\"2\",\"title\":\"Eagle1080 60\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/26010039-ED3A-4A43-A9D9-3BDCCC582D5E.png\",\"duration\":17000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/Eagle1080-60.mp4\",\"videoHeight\":1080},{\"videoWidth\":1280,\"isFavourite\":0,\"rcg_type\":\"2\",\"title\":\"aO3\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/83D0895F-29DD-45F4-9D6B-D1F59EEC154D.png\",\"duration\":307000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/aO3.mkv\",\"videoHeight\":720},{\"videoWidth\":1920,\"isFavourite\":1,\"rcg_type\":\"5\",\"title\":\"abcd3D\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/8E607AF6-2B7D-48B2-8985-E7244B338E8E.png\",\"duration\":180000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/abcd3D.mp4\",\"videoHeight\":1080},{\"videoWidth\":1024,\"isFavourite\":0,\"rcg_type\":\"2\",\"title\":\"abc\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/33E9B4E8-7895-4169-9D20-A1B97903E7B8.png\",\"duration\":132000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/abc.mp4\",\"videoHeight\":512},{\"videoWidth\":1920,\"isFavourite\":1,\"rcg_type\":\"1\",\"title\":\"333\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/4E3FE121-3FDA-4577-A729-F11E43E3A71C.png\",\"duration\":207000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/333.mp4\",\"videoHeight\":1080},{\"videoWidth\":320,\"isFavourite\":0,\"rcg_type\":\"2\",\"title\":\"2017\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/794A9A52-1F6F-4193-AAE6-09AFA44ACC41.png\",\"duration\":28000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/2017.mp4\",\"videoHeight\":480}]";
    
    //    NSArray *arr = [NSJSONSerialization JSONObjectWithData:[jsonstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        NSArray *arr = nil;
        [self didFinishRequest:arr];
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
    return 269;
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
    return UIEdgeInsetsMake(20, 17, 0, 17);
}
@end



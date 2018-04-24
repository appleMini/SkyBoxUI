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
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "SPVerticalScrollCollectionView.h"

#define TopInset 84.0

//UIScrollViewDelegate
@interface SPMuliteViewController ()<UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource, SPWaterFallLayoutDelegate, SPVideoViewDelegate, SPVideoCollectionViewDelegate>{
    NSArray *_dataArr;
    DataSourceType _type;
    NSIndexPath *_showIndexpath;
    
    BOOL _animation;
    
    BOOL _autoRefresh;
    BOOL _unAutoRefresh;
    
    BOOL _isRefreshing;
    BOOL _showFirstWithAnimation;
}

@property (nonatomic, strong) NSMutableArray *selectArr;
@property (nonatomic, assign) int selectCount;
@property (nonatomic, assign) SPCellStatus status;
@property (nonatomic, assign) DisplayType showType;
@property (nonatomic, copy) NSString *cellIditify;
@property (nonatomic, strong) UIBarButtonItem *menuItem;
@property (nonatomic, strong) UIBarButtonItem *deleteItem;
@property (nonatomic, strong) UIButton *menuBtn;
@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIBarButtonItem *cancleItem;
@property (nonatomic, strong) UIBarButtonItem *delItem;
@property (nonatomic, strong) UIButton *delBtn;

@property (nonatomic, strong) UIImage *snapshot;
@property (nonatomic, strong) UIImageView *bottomGradientV;
@property (nonatomic, strong) SPBackgrondView *bgview;

@end

@implementation SPMuliteViewController

@synthesize isShow = _isShow;

- (instancetype)initWithType:(DataSourceType)type displayType:(DisplayType)show
{
    self = [super init];
    if (self) {
        _status = CommomStatus;
        _type = type;
        //        DisplayType willDisplayType = [[SPDataManager shareSPDataManager] getDisplayType:type];
        //        _showType = (willDisplayType == UnknownType) ? show : willDisplayType;
        NSNumber *display = [[NSUserDefaults standardUserDefaults] objectForKey:@"DisplayType"];
        DisplayType willDisplayType = [display unsignedIntegerValue];
        _showType = willDisplayType;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:SCANOVERUITOUNITYNOTIFICATIONNAME object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateThumbnail) name:UPDATETHUMBNAIL_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasLocalVideosUpdate) name:UPDATELOCALVIDEOSNOTIFICATIONNAME object:nil];
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDispalyType:) name:CHANGEDISPALYTYPENOTIFICATIONNAME object:nil];
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
        menuItem.frame = CGRectMake(0, 0, 20, 20);
        //        menuItem.backgroundColor = [UIColor redColor];
        [menuItem addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
        menuItem.userInteractionEnabled = NO;
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
    if (_status == CommomStatus) {
        return @[self.menuItem];
    }else {
        return @[self.cancleItem];
    }
}

- (NSArray *)rightNaviItem {
    if (_status == CommomStatus && _type == HistoryVideosType) {
        return @[self.deleteItem];
    }else if (_status == DeleteStatus) {
        return @[self.delItem];
    }
    
    return nil;
}

- (NSString *)titleOfLabelView {
    if (_status == CommomStatus) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%d / %d", _selectCount, (int)_dataArr.count];
}
#pragma -mark private

- (void)hasLocalVideosUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_isRefreshing && self.isShow && self.viewLoaded && self.view.window) {
           [self refresh];
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCANOVERUITOUNITYNOTIFICATIONNAME object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATETHUMBNAIL_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATELOCALVIDEOSNOTIFICATIONNAME object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGEDISPALYTYPENOTIFICATIONNAME object:nil];
}
- (void)updateThumbnail {
    if (!_isShow || _isRefreshing || _type == HistoryVideosType || _status == DeleteStatus) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isShow || !self.isViewLoaded || !self.view.window) {
            _autoRefresh = YES;
            return ;
        }
        
        if (_unAutoRefresh || self.scrollView.tracking) {
            _autoRefresh = YES;
            return;
        }
        
        if (_type == VRVideosType) {
            [self refresh];
        }else {
            [self updateVisiableCell];
        }
    });
}

- (void)resetCollectionViewCellForIndexpath:(NSIndexPath *) indexPath {
    UICollectionView *collectionView = ((SPVerticalScrollCollectionView *)self.scrollView).collectionView;
    SPVideo *video = _dataArr[indexPath.item];
    video.dataSource = _type;
    SPVideoCollectionCell *cell = (SPVideoCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.videoView.status = _status;
    if (_status == DeleteStatus) {
        for (SPVideo *sVideo in _selectArr) {
            if ([sVideo.path hash] == [video.path hash]) {
                video.isDelete = YES;
                break;
            }
        }
        [cell enableLongPressGestureRecognizer:NO];
    }else {
        if (_type == AirScreenType) {
            [cell enableLongPressGestureRecognizer:NO];
        }else {
            [cell enableLongPressGestureRecognizer:YES];
        }
    }
    
    if(_status == CommomStatus && _type == HistoryVideosType && [video.type isEqualToString:@"Airscreen"] && ([video.remote_id hash] != [[SPDataManager shareSPDataManager].airscreen.computerId hash])) {
        cell.userInteractionEnabled = NO;
        [cell hiddenShadow:YES];
    }else {
        cell.userInteractionEnabled = YES;
        [cell hiddenShadow:NO];
    }
    
    cell.videoView.video = video;
}

- (void)updateVisiableCell {
    NSArray *visibleCells = nil;
    if (_showType == TableViewType) {
        UITableView *tableView = (UITableView *)self.scrollView;
        visibleCells = tableView.indexPathsForVisibleRows;
        
        for (NSIndexPath *indexPath in visibleCells) {
            SPVideo *video = _dataArr[indexPath.row];
            video.dataSource = _type;
            SPVideoCell *cell = (SPVideoCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.videoView.status = _status;
            
            if (_status == DeleteStatus) {
                for (SPVideo *sVideo in _selectArr) {
                    if ([sVideo.path hash] == [video.path hash]) {
                        video.isDelete = YES;
                        break;
                    }
                }
                [cell enableLongPressGestureRecognizer:NO];
            }else {
                if (_type == AirScreenType) {
                    [cell enableLongPressGestureRecognizer:NO];
                }else {
                    [cell enableLongPressGestureRecognizer:YES];
                }
            }
            
            if(_status == CommomStatus && _type == HistoryVideosType && [video.type isEqualToString:@"Airscreen"] && ([video.remote_id hash] != [[SPDataManager shareSPDataManager].airscreen.computerId hash])) {
                cell.userInteractionEnabled = NO;
                [cell hiddenShadow:YES];
            }else {
                cell.userInteractionEnabled = YES;
                [cell hiddenShadow:NO];
            }
            
            cell.videoView.video = video;
        }
    }else {
        UICollectionView *collectionView = ((SPVerticalScrollCollectionView *)self.scrollView).collectionView;
        
        visibleCells = collectionView.indexPathsForVisibleItems;
        for (NSIndexPath *indexPath in visibleCells) {
            [self resetCollectionViewCellForIndexpath:indexPath];
        }
    }
}

- (void)resetTitleView: (BOOL)isDelete  {
    _selectCount = isDelete ? (_selectCount + 1) : (_selectCount - 1);
    if (_selectCount <= 0) {
        _delBtn.enabled = NO;
        _delBtn.alpha = 0.4;
    }else {
        _delBtn.enabled = YES;
        _delBtn.alpha = 1.0;
    }
    
    [self resetNaviWithAnimation:NO];
}

- (UIBarButtonItem *)deleteItem {
    if (!_deleteItem) {
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setImage:[Commons getImageFromResource:@"History_titlebar_button_delete"] forState:UIControlStateNormal];
        deleteBtn.backgroundColor = [UIColor clearColor];
        deleteBtn.userInteractionEnabled = NO;
        deleteBtn.frame = CGRectMake(0, 0, 20, 20);
        [deleteBtn addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
        
        _deleteItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
        self.deleteBtn = deleteBtn;
    }
    
    return _deleteItem;
}

- (void)deleteItem:(UIButton *)item {
    SPAlertViewController *alterVC = [SPAlertViewController alertControllerWithTitle:NSLocalizedString(@"Notice_DeleteHistory", @"Delete history") message:NSLocalizedString(@"Notice_DeleteHistory_all_msg", @"Are you sure you want to delete all history?")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Notice_Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alterVC dismissViewControllerAnimated:YES completion:nil];
    }];

    __weak typeof(self) ws = self;
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Notice_Delete", @"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"DeleteAllHistory"}];
        [alterVC dismissViewControllerAnimated:YES completion:nil];
        
        _dataArr = nil;
        [ws reload];
    }];
    [alterVC addAction:cancelAction];
    [alterVC addAction:deleteAction];
    
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [weakSelf presentViewController:alterVC animated:YES completion:nil];
    }];
}


- (UIBarButtonItem *)cancleItem {
    if (!_cancleItem) {
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(0, 0, 20, 20);
        [cancelBtn setTitle:NSLocalizedString(@"Notice_Cancel", @"Cancel") forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont fontWithName:@"Calibri" size:19];
        [cancelBtn setTitleColor:[SPColorUtil getHexColor:@"#ffffff"] forState:UIControlStateNormal];
        cancelBtn.backgroundColor = [UIColor clearColor];
        [cancelBtn addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _cancleItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    }
    
    return _cancleItem;
}

- (void)cancelClick:(id)sender {
    _status = CommomStatus;
    for (SPVideo *video in _selectArr) {
        video.isDelete = NO;
    }
    _selectArr = nil;
    [self configRefresh];
    
    [self updateVisiableCell];
    
    NSUInteger jumpToVC = (_type == HistoryVideosType) ? CommonHistoryType : CommonLoaclVideosType;
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:jumpToVC]
                             };
    
    [self.view bubbleEventWithUserInfo:notify];
}

- (UIBarButtonItem *)delItem {
    if (!_delItem) {
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(0, 0, 20, 20);
        [deleteBtn setTitle:NSLocalizedString(@"Notice_Delete", @"Delete") forState:UIControlStateNormal];
        deleteBtn.titleLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:19];
        [deleteBtn setTitleColor:[SPColorUtil getHexColor:@"#ffffff"] forState:UIControlStateNormal];
        deleteBtn.backgroundColor = [UIColor clearColor];
        [deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _delBtn = deleteBtn;
        _delItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    }
    
    return _delItem;
}

- (void)runtime:(id)clazz {
    unsigned int count = 0;
    objc_property_t *propertys = class_copyPropertyList([clazz class], &count);
    
    for (int i=0; i< count; i++) {
        objc_property_t property = propertys[i];
        const char *name = property_getName(property);
        
        NSString *propertyName = [NSString stringWithUTF8String:name];
        
        //     NSLog(@"runtime ==  %@", propertyName);
    }
}

- (void)deleteClick:(id)sender {
    NSString *title = nil;
    NSString *msg = nil;
    if (_type == HistoryVideosType) {
        title = NSLocalizedString(@"Notice_DeleteHistory", @"Delete history");
        msg = NSLocalizedString(@"Notice_DeleteHistory_msg", @"Are you sure you want to delete selected history?");
    }else {
        title = NSLocalizedString(@"Notice_DeleteVideos", @"Delete videos");
        msg = NSLocalizedString(@"Notice_DeleteVideos_msg", @"Are you sure you want to delete selected videos?");
    }
    SPAlertViewController *alterVC = [SPAlertViewController alertControllerWithTitle:title message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Notice_Delete", @"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        _status = CommomStatus;
        NSMutableArray <NSString *>*deleteArr = [NSMutableArray array];
        for (SPVideo *video in _selectArr) {
            [deleteArr addObject:video.path];
        }
        
        [self removeItemWithAnimation];
        
        ////        //test
        //        self.view.userInteractionEnabled = YES;
        //        return ;
        __weak typeof(self) ws = self;
        self.completeBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(ws) strongfy = ws;
                
                NSUInteger jumpToVC = (_type == HistoryVideosType) ? CommonHistoryType : CommonLoaclVideosType;
                NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:jumpToVC]
                                         };
                [strongfy.view bubbleEventWithUserInfo:notify];
            });
        };
        
        NSString *method = (_type == HistoryVideosType) ? @"DeleteHistory" : @"DeleteLocalVideos";
        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : method, @"deleteArr" : [deleteArr copy], @"resultBlock" : self.completeBlock}];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Notice_Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        [self runtime:alterVC];
        [alterVC dismissViewControllerAnimated:YES completion:^{
            
        }];
        [self cancelClick:nil];
    }];
    
    [alterVC addAction:cancelAction];
    [alterVC addAction:deleteAction];
    
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [weakSelf presentViewController:alterVC animated:YES completion:nil];
    }];
}

- (void)enableNavigationItems:(BOOL)enable {
    dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *leftItems = [self leftNaviItem];
            for (UIBarButtonItem *barBtnItem in leftItems) {
                UIView *view = barBtnItem.customView;
                BOOL userInteractionEnabled = YES;
                if ([view isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)view;
                    userInteractionEnabled = btn.isEnabled;
                }
                view.alpha = (enable && userInteractionEnabled) ? 1.0 : 0.4;
                view.userInteractionEnabled = enable;
            }
        
            if (_showType == LocalFilesType && !enable) {
                return;
            }
        
            NSArray *rightItems = [self rightNaviItem];
            for (UIBarButtonItem *barBtnItem in rightItems) {
                UIView *view = barBtnItem.customView;
                BOOL userInteractionEnabled = YES;
                if ([view isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)view;
                    userInteractionEnabled = btn.isEnabled;
                }
                view.alpha = (enable && userInteractionEnabled) ? 1.0 : 0.4;
                view.userInteractionEnabled = enable;
            }
    });
}

- (void)removeItemWithAnimation {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = NO;
        [self updateVisiableCell];
        
        NSUInteger count = _dataArr.count;
        NSMutableArray *resultArr = [NSMutableArray arrayWithArray:_dataArr];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:2];
        //有 bug 最后一个删除不掉
        //        [resultArr enumerateObjectsUsingBlock:^(SPVideo *video, NSUInteger idx, BOOL * _Nonnull stop) {
        //            if (video.isDelete) {
        //                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        //                [indexPaths addObject:indexPath];
        //                [resultArr removeObject:video];
        //            }
        //        }];
        for (int index = 0; index < count; index ++) {
            SPVideo *video = _dataArr[index];
            if (video.isDelete) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [indexPaths addObject:indexPath];
                
                [resultArr removeObject:video];
            }
        }
        
        if (_showType == TableViewType) {
            UITableView *tableView = (UITableView *)self.scrollView;
            _dataArr = resultArr;
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
            [tableView  endUpdates];
        }else {
            _dataArr = resultArr;
            UICollectionView *collectionView = ((SPVerticalScrollCollectionView *)self.scrollView).collectionView;
            [collectionView deleteItemsAtIndexPaths:indexPaths];
        }
        
        _selectArr = nil;
        self.view.userInteractionEnabled = YES;
        if (_dataArr.count <= 0) {
            [self showOrHiddenBackgrondView:YES];
            
            [self enableNavigationItems:NO];
        }else {
            [self enableNavigationItems:YES];
        }
        
        [self configRefresh];
    });
}

- (void)viewWillToChanged {
    NSNumber *display = [[NSUserDefaults standardUserDefaults] objectForKey:@"DisplayType"];
    DisplayType willDisplayType = [display unsignedIntegerValue];
    if (willDisplayType == _showType) {
        return;
    }
    
    [self changeDispalyType:willDisplayType];
}

- (void)releaseAction {
    CGFloat oldOffsetY = [[SPDataManager shareSPDataManager] getContentOffsetY:_type];
    CGFloat offsetY =  self.scrollView.contentOffset.y;
    if (oldOffsetY != offsetY) {
        SPDataManager *dataManager = [SPDataManager shareSPDataManager];
        NSUInteger hash = [dataManager getHash:_type];
        CGFloat offsetY = self.scrollView.contentOffset.y;
        
        [dataManager setCache:_type displayType:[NSNumber numberWithUnsignedInteger:_showType] contentOffsetY:[NSNumber numberWithFloat:offsetY] dataSourceString:[NSNumber numberWithUnsignedInteger:hash]];
    }
}

- (void)setupMenuImage {
    switch (_showType) {
        case TableViewType:
        {
            [self.menuBtn setImage:[Commons getImageFromResource:@"Home_titlebar_button_grid"] forState:UIControlStateNormal];
        }
            break;
        case CollectionViewType:
        {
            [self.menuBtn setImage:[Commons getImageFromResource:@"Home_titlebar_button_list"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupScrollView];
    
    [self setupBottomGradientLayer];
    
    [self.view addSubview:self.bgview];
    if (_type == AirScreenType) {
        _bgview.hidden = YES;
        [_bgview showOrHidden:NO];
    }
    
    [self.view bringSubviewToFront:self.scrollView];
}

- (void)setupBottomGradientLayer {
    if (_bottomGradientV) {
        return;
    }
    
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectZero];
    //    imgv.backgroundColor = [UIColor redColor];
    UIImage *image = [Commons getImageFromResource:@"Network_list_mask@2x"];
    CGImageRef imgref = [image CGImage];
    UIImage *newImage = [UIImage imageWithCGImage:imgref scale:image.scale orientation:UIImageOrientationDown];
    
    imgv.image = newImage;
    [self.view addSubview:imgv];
    _bottomGradientV = imgv;
    _bottomGradientV.alpha = 0.5;
    _bottomGradientV.hidden = NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _bottomGradientV.frame = CGRectMake(0, SCREEN_HEIGHT - 100 * kHSCALE - 84, SCREEN_WIDTH, 100 * kHSCALE);
    
    [self.scrollView setNeedsLayout];
    //    UIView *view = [self.scrollView viewWithTag:9999];
    //    if (!view) {
    //        self.collectionView.tag = 9999;
    //        [self.scrollView addSubview:self.collectionView];
    //    }
    //
    //    CGRect frame = self.scrollView.bounds;
    //    view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    //清除缓存
    //    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    //    [[SDImageCache sharedImageCache] clearMemory];
    //    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
    //    gradient.frame = rect;
    //
    //    UIColor *bgColor = SPBgColor;
    //
    //    gradient.colors = @[(__bridge id)[bgColor colorWithAlphaComponent:0.0].CGColor, (__bridge id)[bgColor colorWithAlphaComponent:1.0].CGColor, (__bridge id)[bgColor colorWithAlphaComponent:1.0].CGColor];
    //    gradient.locations = @[@0, @(1.0 * 22 / self.view.frame.size.height), @1.0];
    //    gradient.startPoint = CGPointMake(0.5, 0);
    //    gradient.endPoint = CGPointMake(0.5, 1.0);
    //
    //    self.view.layer.mask = gradient;
}

- (void)setupScrollView {
    [self.view addSubview:self.scrollView];
    
    [self.view bringSubviewToFront:_bottomGradientV];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.edges.mas_equalTo(self.view);
        make.edges.mas_equalTo(UIEdgeInsetsMake(-TopInset, 0, 0, 0));
    }];
    
    self.scrollView.delegate = self;
}

- (SPBackgrondView *)bgview {
    if (!_bgview) {
        _bgview = [self setBackgroundView];
        [self.view addSubview:_bgview];
    }
    
    return _bgview;
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
                
                _scrollView.scrollEnabled = YES;
            }
                break;
            case CollectionViewType:
            {
                //UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc] init];
                //flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
                // 创建瀑布流layout
                SPWaterFallLayout *layout = [[SPWaterFallLayout alloc] init];
                // 设置代理
                layout.delegate = self;
                _scrollView = [[SPVerticalScrollCollectionView alloc] initWithFrame:CGRectZero];
                [((SPVerticalScrollCollectionView *)_scrollView) setCollectionViewLayout:layout];
                [((SPVerticalScrollCollectionView *)_scrollView) registerClass:[SPVideoCollectionCell class] forCellWithReuseIdentifier:[self cellIditify]];
                ((SPVerticalScrollCollectionView *)_scrollView).cDelegate = self;
                ((SPVerticalScrollCollectionView *)_scrollView).dataSource = self;
                ((SPVerticalScrollCollectionView *)_scrollView).backgroundColor = [UIColor clearColor];
                
                _scrollView.scrollEnabled = YES;
            }
                break;
            default:
                break;
        }
        
        //        SPBackgrondView *bgview = [self setBackgroundView];
        //        if (_type != AirScreenType && bgview) {
        //            [_scrollView setValue:bgview forKeyPath:@"_backgroundView"];
        //            [bgview showOrHidden:YES];
        //        }
        
        [self configRefresh];
        
        _scrollView.clipsToBounds = NO;
    }
    
    return _scrollView;
}

- (SPBackgrondView *)setBackgroundView {
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    SPBackgrondView *backgroundView = nil;
    switch (_type) {
        case LocalFilesType:
        {
            backgroundView = [[SPBackgrondView alloc] initWithFrame:frame backgroundType:NoVideos];
        }
            break;
        case VRVideosType:
        {
            backgroundView = [[SPBackgrondView alloc] initWithFrame:frame backgroundType:NoVideos];
        }
            break;
        case FavoriteVideosType:
        {
            backgroundView = [[SPBackgrondView alloc] initWithFrame:frame backgroundType:NoFavorite];
        }
            break;
        case HistoryVideosType:
        {
            backgroundView = [[SPBackgrondView alloc] initWithFrame:frame backgroundType:NoHistory];
        }
            break;
        case AirScreenType:
        {
            backgroundView = [[SPBackgrondView alloc] initWithFrame:frame backgroundType:NoAirScreenResult];
        }
            break;
        default:
            break;
    }
    
    return backgroundView;
}

- (void)handleScroll {
    switch (_showType) {
        case TableViewType:
        {
            UITableView *tableView = (UITableView *)self.scrollView;
            // 找到下一个要播放的cell(最在屏幕中心的)
            NSIndexPath *finnalIndexPath = nil;
            NSArray *visiableCells = [tableView indexPathsForVisibleRows];
            
            if (!visiableCells || visiableCells.count <= 0) {
                _showIndexpath = nil;
                return;
            }
            
            CGFloat gap = MAXFLOAT;
            for (NSIndexPath *indexPath in visiableCells) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                CGPoint coorCentre = [cell.superview convertPoint:cell.center toView:nil];
                CGFloat delta = fabs(coorCentre.y - [UIScreen mainScreen].bounds.size.height*0.5);
                if (delta < gap) {
                    gap = delta;
                    finnalIndexPath = indexPath;
                }
            }
            
            //     NSLog(@"finnalIndexPath  === %ld", (long)finnalIndexPath.row);
            //            _showIndexpath = [NSIndexPath indexPathForItem:finnalCell.indexPath.row inSection:0];
            _showIndexpath = [NSIndexPath indexPathForItem:finnalIndexPath.row inSection:0];
        }
            break;
        case CollectionViewType:
        {
            UICollectionView *collectionView = ((SPVerticalScrollCollectionView *)self.scrollView).collectionView;
            NSIndexPath *finnalIndexPath = nil;
            NSArray *visibleArr = [(SPVerticalScrollCollectionView *)self.scrollView indexPathsForVisibleItems];
            
            if (!visibleArr || visibleArr.count <= 0) {
                _showIndexpath = nil;
                return;
            }
            CGFloat gap = MAXFLOAT;
            for (NSIndexPath *indexPath in visibleArr) {
                UICollectionViewCell *item = [collectionView cellForItemAtIndexPath:indexPath];
                CGPoint coorCentre = [item.superview convertPoint:item.center toView:nil];
                CGFloat delta = fabs(coorCentre.y - [UIScreen mainScreen].bounds.size.height*0.5);
                if (delta < gap) {
                    gap = delta;
                    finnalIndexPath = indexPath;
                }
            }
            
            _showIndexpath = [NSIndexPath indexPathForRow:finnalIndexPath.item inSection:0];
        }
            break;
        default:
            break;
    }
    
}

- (void)visiableIndexPath {
    switch (_showType) {
        case TableViewType:
        {
            //            CGFloat cellHeight = 1.0 * 155 *kHSCALE + 60 + 29;
            UITableView *tableView = (UITableView *)self.scrollView;
            NSArray *visibleArr = tableView.indexPathsForVisibleRows;
            
            NSUInteger index = 0;
            for (NSIndexPath *indexPath in visibleArr) {
                index += indexPath.row;
            }
            
            index = index / visibleArr.count;
            if (index + 2 < _dataArr.count) {
                index += 2;
            }
            _showIndexpath = [NSIndexPath indexPathForItem:index inSection:0];
        }
            break;
        case CollectionViewType:
        {
            UICollectionView *collectionView = (UICollectionView *)self.scrollView;
            NSArray *visibleArr = collectionView.indexPathsForVisibleItems;
            
            NSUInteger index = 0;
            for (NSIndexPath *indexPath in visibleArr) {
                index += indexPath.row;
            }
            
            index = index / visibleArr.count;
            _showIndexpath = [NSIndexPath indexPathForRow:index inSection:0];
            
        }
            break;
        default:
            break;
    }
    
}

- (void)hiddenGradientLayer:(BOOL)isHidden {
    self.view.layer.mask.hidden = isHidden;
}

- (void)gradientLayer:(CGFloat)Height {
    //    CGRect rect = CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height + 64);
    CGRect rect = CGRectMake(0, -130, self.view.frame.size.width, self.view.frame.size.height + 180);
    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
    gradient.frame = rect;
    
    //    UIColor *bgColor = SPBgColor;
    UIColor *bgColor = [UIColor blackColor];
    
    gradient.colors = @[(__bridge id)[bgColor colorWithAlphaComponent:0.0].CGColor, (__bridge id)[bgColor colorWithAlphaComponent:1.0].CGColor, (__bridge id)[bgColor colorWithAlphaComponent:1.0].CGColor];
    gradient.locations = @[@(1.0 * Height / rect.size.height), @(1.0 * (Height + 180) / rect.size.height), @1.0];
    gradient.startPoint = CGPointMake(0.5, 0);
    gradient.endPoint = CGPointMake(0.5, 1.0);
    
    self.view.layer.mask = gradient;
}

#pragma -mark 截图
- (UIImage *)snapshotPhoto:(UIView *)view {
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//- (void)changeDispalyType:(NSNotification *)notify {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSDictionary *userInfo = notify.userInfo;
//        DisplayType showType = [userInfo[@"DisplayType"] unsignedIntegerValue];
//        //     NSLog(@"当前线程 ====  %@", [[NSThread currentThread] name]);
//        _animation = YES;
//        [self handleScroll];
//        _showType = showType;
//        [self enableNavigationItems:NO];
//
//
//        [UIView animateWithDuration:0.2 animations:^{
//            _unAutoRefresh = YES;
//            self.scrollView.alpha = 0.0;
//        } completion:^(BOOL finished) {
//            [self gradientLayer:0.0];
//            [self setupMenuImage];
//            [_scrollView removeFromSuperview];
//            _scrollView = nil;
//            [self setupScrollView];
//
//            self.scrollView.alpha = 0.0;
//            [self reload];
//            _unAutoRefresh = NO;
//        }];
//
//    });
//}

- (void)changeDispalyType:(DisplayType)showType {
    dispatch_async(dispatch_get_main_queue(), ^{
        //     NSLog(@"当前线程 ====  %@", [[NSThread currentThread] name]);
        _animation = YES;
        [self handleScroll];
        _showType = showType;
        [self enableNavigationItems:NO];
        
        
        [UIView animateWithDuration:0.2 animations:^{
            _unAutoRefresh = YES;
            self.scrollView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self gradientLayer:0.0];
            [self setupMenuImage];
            [_scrollView removeFromSuperview];
            _scrollView = nil;
            [self setupScrollView];
            
            self.scrollView.alpha = 0.0;
            [self reload];
            _unAutoRefresh = NO;
        }];
        
    });
}

- (void)setShowType:(DisplayType)showType {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithUnsignedInteger:showType] forKey:@"DisplayType"];
    [userDefaults synchronize];
    
    //    NSDictionary *userInfo = @{@"DisplayType" : [NSNumber numberWithUnsignedInteger:showType]};
    //    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGEDISPALYTYPENOTIFICATIONNAME object:nil userInfo:userInfo];
    
    [self changeDispalyType:showType];
}

- (void)setIsShow:(BOOL)isShow {
    if (isShow && _isShow != isShow) {
        _isRefreshing = NO;
    }
    
    _isShow = isShow;
}

- (void)refresh {
    if (!_isShow || _isRefreshing) {
        return;
    }
    
    [self enableNavigationItems:YES];
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [_scrollView.tg_header beginRefreshing];
    //    });
    self.refreshEnable ?  [self doRefreshSenior] : nil;
}

- (void)configRefresh {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_status == DeleteStatus) {
            _scrollView.tg_header = nil;
            return;
        }
        
        //默认为QQ效果
        _scrollView.tg_header = [TGRefreshOC  refreshWithTarget:self action:@selector(doRefreshSenior) config:^(TGRefreshOC *refresh) {
            refresh.tg_bgColor(SPBgColor);
        }];
    
        self.scrollView.userInteractionEnabled = YES;
    });
}

- (void)showScrollViewWithAnimation {
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self enableNavigationItems:YES];
    }];
}

- (void)showOrHiddenBackgrondView:(BOOL)isShow {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_type == AirScreenType && isShow && !_bgview) {
            [self.view addSubview:self.bgview];
            
        }else if(_type == AirScreenType && !isShow){
            [_bgview removeFromSuperview];
            _bgview = nil;
        }
        
        if (isShow) {
            [self.view bringSubviewToFront:self.scrollView];
            self.bgview.hidden = NO;
            [self.bgview showOrHidden:YES];
        }else {
            _bgview.hidden = YES;
            [_bgview showOrHidden:NO];
        }
    });
    
}

- (void)reload {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_scrollView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        
        __block  BOOL _isHidden = NO;
        [self enableNavigationItems:NO];
        if(!_dataArr || _dataArr.count <= 0) {
            _isHidden = NO;
            
            [UIView animateWithDuration:0.2 animations:^{
                self.menuBtn.alpha = 0.4;
                self.menuBtn.enabled = NO;
                
                self.deleteBtn.alpha = 0.4;
                self.deleteBtn.enabled = NO;
            }];
            
            switch (_type) {
                case LocalFilesType:
                {
                    NSUInteger selectedIndex = -1;
                    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:HomeHelpMiddleVCType],
                                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex],
                                             @"Done": @NO
                                             };
                    
                    [self.view bubbleEventWithUserInfo:notify];
                    
                    return;
                }
                    break;
                default: {
                    [self showOrHiddenBackgrondView:YES];
                }
                    break;
            }
            
            
        }else{
            _isHidden = YES;
            [UIView animateWithDuration:0.2 animations:^{
                self.menuBtn.alpha = 1.0;
                self.menuBtn.enabled = YES;
                
                self.deleteBtn.alpha = 1.0;
                self.deleteBtn.enabled = YES;
            }];
            
            [self showOrHiddenBackgrondView:NO];
        }
        
        [self.view bringSubviewToFront:self.scrollView];
        switch (_showType) {
            case TableViewType:
            {
                UITableView *tableView = (UITableView *)self.scrollView;
                if (_showIndexpath) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:0.02 animations:^{
                            [tableView scrollToRowAtIndexPath:_showIndexpath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                        } completion:^(BOOL finished) {
                            _showIndexpath = nil;
                            [self showScrollViewWithAnimation];
                        }];
                    });
                }else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [UIScrollView animateWithDuration:0.02 animations:^{
                            self.scrollView.contentOffset = CGPointMake(0, 0);
                            self.scrollView.alpha = 1.0;
                        } completion:^(BOOL finished) {
                            [self enableNavigationItems:YES];
                        }];
                    });
                    
                    
                    //                    CGFloat offsetY = [[SPDataManager shareSPDataManager] getContentOffsetY:_type];
                    //                    //     NSLog(@"offsetY ===== %f", offsetY);
                    //                    //                    [self.scrollView setContentOffset:CGPointMake(0, offsetY) animated:YES];
                    //                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //                        [UIScrollView animateWithDuration:0.02 animations:^{
                    //                            self.scrollView.contentOffset = (offsetY == 0) ? CGPointMake(0, 0) : CGPointMake(0, offsetY);
                    //                        } completion:^(BOOL finished) {
                    //
                    //                            [self addGradientLayer:offsetY];
                    //                             [self showScrollViewWithAnimation];
                    //                        }];
                    //                    });
                }
            }
                break;
            case CollectionViewType:
            {
                SPVerticalScrollCollectionView *scrollCollectionView = (SPVerticalScrollCollectionView *)self.scrollView;
                if (_showIndexpath) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:0.02 animations:^{
                            [scrollCollectionView.collectionView scrollToItemAtIndexPath:_showIndexpath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                        } completion:^(BOOL finished) {
                            _showIndexpath = nil;
                            [UIView animateWithDuration:0.5 animations:^{
                                self.scrollView.alpha = 1.0;
                            } completion:^(BOOL finished) {
                                [self showScrollViewWithAnimation];
                            }];
                        }];
                    });
                    
                }else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [UIScrollView animateWithDuration:0.02 animations:^{
                            self.scrollView.contentOffset = CGPointMake(0, 0);
                            self.scrollView.alpha = 1.0;
                        } completion:^(BOOL finished) {
                            [self enableNavigationItems:YES];
                        }];
                    });
                    //                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //                        CGFloat offsetY = [[SPDataManager shareSPDataManager] getContentOffsetY:_type];
                    //
                    //                        [UIView animateWithDuration:0.02 animations:^{
                    //                            offsetY == 0 ? nil : [self.scrollView setContentOffset:CGPointMake(0, offsetY)];
                    //                        } completion:^(BOOL finished) {
                    //
                    //                            [self addGradientLayer:offsetY];
                    //                             [self showScrollViewWithAnimation];
                    //                        }];
                    //                    });
                }
            }
                break;
            default:
                break;
        }
        
    });
}

- (void)didFinishRequest:(NSArray *)arr {
    BOOL refresh = NO;
    NSArray *array = nil;
    if(arr) array = [SPVideo mj_objectArrayWithKeyValuesArray:arr];
    
    if (self.isShow) {
        NSMutableArray *paths = [[NSMutableArray alloc] initWithCapacity:array.count];
        for (SPVideo *video in array) {
            [paths addObject:video.path];
        }
        
        SPDataManager *dataManager = [SPDataManager shareSPDataManager];
        
        NSUInteger dataHash = [dataManager getHash:_type];
        NSUInteger newHash = [[paths mj_JSONString] hash];
        
        if (dataHash != newHash) {
            refresh = YES;
            _showFirstWithAnimation = YES;
            [dataManager setCacheWithDataSource:_type dataSourceString:newHash];
        }else {
            _showFirstWithAnimation = NO;
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        _scrollView.tg_header.refreshResultStr = @"成功刷新数据";
        [_scrollView.tg_header endRefreshing];
//        _isRefreshing = NO;
        
        if(!self.isShow)  return;
        
        _dataArr = array;
        if (refresh || !_dataArr || _dataArr.count == 0) {
            [self reload];
        }else {
            [self updateVisiableCell];
        }
        
        _isRefreshing = NO;
    });
}

- (void)doRefreshSenior {
    _isRefreshing = YES;
    __weak typeof(self) ws = self;
    self.refreshBlock = ^(NSString *dataStr){
        //     NSLog(@"dataStr === %@", dataStr);
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
//    NSString *jsonstr = @"[{\"videoWidth\":320,\"isFavourite\":0,\"rcg_type\":\"1\",\"title\":\"ed 1024 512kb\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/449A3F79-82ED-4648-A798-2DFB392CFBC3.png\",\"duration\":653000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/ed_1024_512kb.mp4\",\"videoHeight\":240},{\"videoWidth\":600,\"isFavourite\":0,\"rcg_type\":\"1\",\"title\":\"EasyMovieTexture\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/772239E4-98E6-4B6D-BDED-196E35A1ED95.png\",\"duration\":176000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/EasyMovieTexture.mp4\",\"videoHeight\":360},{\"videoWidth\":1920,\"isFavourite\":1,\"rcg_type\":\"2\",\"title\":\"Eagle1080 60\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/26010039-ED3A-4A43-A9D9-3BDCCC582D5E.png\",\"duration\":17000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/Eagle1080-60.mp4\",\"videoHeight\":1080},{\"videoWidth\":1280,\"isFavourite\":0,\"rcg_type\":\"2\",\"title\":\"aO3\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/83D0895F-29DD-45F4-9D6B-D1F59EEC154D.png\",\"duration\":307000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/aO3.mkv\",\"videoHeight\":720},{\"videoWidth\":1920,\"isFavourite\":1,\"rcg_type\":\"5\",\"title\":\"abcd3D\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/8E607AF6-2B7D-48B2-8985-E7244B338E8E.png\",\"duration\":180000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/abcd3D.mp4\",\"videoHeight\":1080},{\"videoWidth\":1024,\"isFavourite\":0,\"rcg_type\":\"2\",\"title\":\"abc\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/33E9B4E8-7895-4169-9D20-A1B97903E7B8.png\",\"duration\":132000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/abc.mp4\",\"videoHeight\":512},{\"videoWidth\":1920,\"isFavourite\":1,\"rcg_type\":\"1\",\"title\":\"333\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/4E3FE121-3FDA-4577-A729-F11E43E3A71C.png\",\"duration\":207000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/333.mp4\",\"videoHeight\":1080},{\"videoWidth\":320,\"isFavourite\":0,\"rcg_type\":\"2\",\"title\":\"2017\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/794A9A52-1F6F-4193-AAE6-09AFA44ACC41.png\",\"duration\":28000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/2017.mp4\",\"videoHeight\":480},{\"videoWidth\":320,\"isFavourite\":0,\"rcg_type\":\"1\",\"title\":\"ed 1024 512kb2\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/449A3F79-82ED-4648-A798-2DFB392CFBC3.png\",\"duration\":653000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/ed_1024_512kb3.mp4\",\"videoHeight\":240},{\"videoWidth\":320,\"isFavourite\":0,\"rcg_type\":\"1\",\"title\":\"ed 1024 512kb\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/449A3F79-82ED-4648-A798-2DFB392CFBC3.png\",\"duration\":653000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/ed_1024_512kb.mp4\",\"videoHeight\":240},{\"videoWidth\":320,\"isFavourite\":0,\"rcg_type\":\"1\",\"title\":\"ed 1024 512kb5\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/449A3F79-82ED-4648-A798-2DFB392CFBC3.png\",\"duration\":653000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/ed_1024_512kb.mp4\",\"videoHeight\":240},{\"videoWidth\":320,\"isFavourite\":0,\"rcg_type\":\"1\",\"title\":\"ed 1024 512kb6\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/449A3F79-82ED-4648-A798-2DFB392CFBC3.png\",\"duration\":653000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/ed_1024_512kb8.mp4\",\"videoHeight\":240},{\"videoWidth\":320,\"isFavourite\":0,\"rcg_type\":\"1\",\"title\":\"ed 1024 512kb\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/449A3F79-82ED-4648-A798-2DFB392CFBC3.png\",\"duration\":653000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/ed_1024_512kb9.mp4\",\"videoHeight\":240},{\"videoWidth\":320,\"isFavourite\":0,\"rcg_type\":\"1\",\"title\":\"ed 1024 512kb\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/449A3F79-82ED-4648-A798-2DFB392CFBC3.png\",\"duration\":653000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/ed_1024_512kb.mp4\",\"videoHeight\":240},{\"videoWidth\":320,\"isFavourite\":0,\"rcg_type\":\"1\",\"title\":\"ed 1024 512kb11\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/449A3F79-82ED-4648-A798-2DFB392CFBC3.png\",\"duration\":653000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/ed_1024_512kb.mp4\",\"videoHeight\":240},{\"videoWidth\":320,\"isFavourite\":0,\"rcg_type\":\"1\",\"title\":\"ed 1024 512kb\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/449A3F79-82ED-4648-A798-2DFB392CFBC3.png\",\"duration\":653000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/ed_1024_512kb.mp4\",\"videoHeight\":240},{\"videoWidth\":320,\"isFavourite\":0,\"rcg_type\":\"1\",\"title\":\"ed 1024 512kb\",\"thumbnail_uri\":\"file:\\\/\\\/\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Library\\\/Caches\\\/Thumbnails\\\/449A3F79-82ED-4648-A798-2DFB392CFBC3.png\",\"duration\":653000,\"path\":\"file:\\\/\\\/\\\/private\\\/var\\\/mobile\\\/Containers\\\/Data\\\/Application\\\/06FB109F-800E-4588-BBB8-DE10412BFE7B\\\/Documents\\\/ed_1024_512kb.mp4\",\"videoHeight\":240}]";
//    
//    NSArray *arr = [NSJSONSerialization JSONObjectWithData:[jsonstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
//    //  [self didFinishRequest:[arr subarrayWithRange:NSMakeRange(0, 0)]];
//    [self didFinishRequest:arr];
}



#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

////设定横向滑动时是否出现删除按扭,（阻止第一行出现）
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete;
//}
//
////自定义划动时delete按钮内容
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return @"删除";
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if(editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        NSMutableArray *resultArr = [NSMutableArray arrayWithArray:_dataArr];
//        SPVideo *video = _dataArr[indexPath.row];
//        if (!video) {
//            return;
//        }
//
//        [resultArr removeObject:video];
//        _dataArr = resultArr;
//        [tableView beginUpdates];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//        [tableView  endUpdates];
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIditify]];
    
    if (!cell) {
        cell = [[SPVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self cellIditify]];
    }
    
    if (_showFirstWithAnimation && _status == CommomStatus && _type == LocalFilesType && indexPath.row == 0) {
        cell.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            cell.alpha = 1.0;
        }];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    SPVideo *video =  _dataArr[indexPath.row];
    video.dataSource = _type;
    cell.videoView.status = _status;
    //    cell.videoView.indexPath = indexPath;
    if (_status == CommomStatus) {
        video.isDelete = NO;
    }
    cell.videoView.video = video;
    cell.videoView.delegate = self;
    
    if (_status == DeleteStatus) {
        [cell enableLongPressGestureRecognizer:NO];
    }else {
        if (_type == AirScreenType) {
            [cell enableLongPressGestureRecognizer:NO];
        }else {
            [cell enableLongPressGestureRecognizer:YES];
        }
    }
    
    if(_status == CommomStatus && _type == HistoryVideosType && [video.type isEqualToString:@"Airscreen"] && ([video.remote_id hash] != [[SPDataManager shareSPDataManager].airscreen.computerId hash])) {
        cell.userInteractionEnabled = NO;
        [cell hiddenShadow:YES];
    }else {
        cell.userInteractionEnabled = YES;
        [cell hiddenShadow:NO];
    }
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TopInset;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static CGFloat cellHeight = 0;
    if (cellHeight == 0) {
        CGFloat imgvHeight = 0;
        CGFloat bottomHeight = 0;
        if ([SPDeviceUtil isiPhoneX]) {
            imgvHeight = 1.0 * 155;
            bottomHeight = 29;
        }else {
            imgvHeight = 1.0 * 155 *kHSCALE;
            bottomHeight = 29*kHSCALE;
        }
        
        cellHeight = imgvHeight + 60 + bottomHeight;
    }
    
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return  [SPDeviceUtil isiPhoneX] ?  kWSCALE*94 - 29 + 34 : kWSCALE*94 - 29;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma -mark UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArr.count;
}

//这个不是必须的方法 是Cell 将要显示
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.transform = CATransform3DMakeScale(1, 1, 1);//缩放比例
    [UIView animateWithDuration:0.01 animations:^{
        cell.layer.transform = CATransform3DMakeScale(1, 1, 1);//还原为1
    } completion:^(BOOL finished) {
        [self resetCollectionViewCellForIndexpath:indexPath];
    }];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SPVideoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self cellIditify] forIndexPath:indexPath];
    
    if (_showFirstWithAnimation && _status == CommomStatus && _type == LocalFilesType && indexPath.row == 0) {
        cell.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            cell.alpha = 1.0;
        }];
    }
    SPVideo *video =  _dataArr[indexPath.row];
    video.dataSource = _type;
    cell.videoView.status = _status;
    //    cell.videoView.indexPath = indexPath;
    if (_status == DeleteStatus) {
        [cell enableLongPressGestureRecognizer:NO];
    }else {
        if (_type == AirScreenType) {
            [cell enableLongPressGestureRecognizer:NO];
        }else {
            [cell enableLongPressGestureRecognizer:YES];
        }
    }
    
    cell.videoView.video = video;
    
    cell.videoView.delegate = self;
    
    if(_status == CommomStatus && _type == HistoryVideosType && [video.type isEqualToString:@"Airscreen"] && ([video.remote_id hash] != [[SPDataManager shareSPDataManager].airscreen.computerId hash])) {
        cell.userInteractionEnabled = NO;
        [cell hiddenShadow:YES];
    }else {
        cell.userInteractionEnabled = YES;
        [cell hiddenShadow:NO];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(height == 0) {
        NSAttributedString *attriStr = [[NSAttributedString alloc] initWithString:@"labelHeight" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Calibri-Bold" size:15]}];
        CGFloat labelHeight = [attriStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine)  context:nil].size.height;
        
        NSAttributedString *attriStr1 = [[NSAttributedString alloc] initWithString:@"durationLabelHeight" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Calibri-light" size:12]}];
        CGFloat durationLabelHeight = [attriStr1 boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine)  context:nil].size.height;
        
        CGFloat imgvHeight = 208 * (SCREEN_WIDTH - 17 * 3) / 2 / 324;
        height = labelHeight + durationLabelHeight + imgvHeight + 8 + 8;
    }
    
    return CGSizeMake((SCREEN_WIDTH / 2 - 17 * 3 / 2), height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(TopInset, 17, [SPDeviceUtil isiPhoneX] ?  kWSCALE*94 - 29 + 34 : kWSCALE*94 - 29, 17);
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
    return UIEdgeInsetsMake(TopInset, 17, [SPDeviceUtil isiPhoneX] ?  kWSCALE*94 - 29 + 34 : kWSCALE*94 - 29, 17);
}


#pragma -mark SPVideoViewDelegate
- (void)SPVideoView:(SPVideoView *)videoView favStateChanged:(BOOL)state {
    return;
    
    if (_type == FavoriteVideosType) {
        //        [_dataArr removeObject:video];
        //        [self reload];
    }
}

#pragma -mark SPVideoCollectionViewDelegate
- (void)resetNaviWithAnimation:(BOOL)anima {
    if (_status == CommomStatus) {
        return;
    }
    
    //    SystemSoundID scoreClickBtnID;
    //    NSURL *url =  [Commons getResourceFromBundleResource:@"1" extension:@"aiff"];
    //    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &scoreClickBtnID);
    //    AudioServicesPlaySystemSoundWithCompletion(scoreClickBtnID, nil);  // 震动
    //    AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil);  // 震动
    
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleLight];
        [generator prepare];
        [generator impactOccurred];
    } else {
        // Fallback on earlier versions
        //        AudioServicesPlaySystemSoundWithCompletion((1519), ^{
        //        });
    }
    
    if (anima) {
        [UIView animateWithDuration:0.15 animations:^{
            self.mainVC.navigationController.navigationBar.alpha = 0.0;
        } completion:^(BOOL finished) {
            
            self.mainVC.navigationItem.leftBarButtonItems = @[self.cancleItem];
            self.mainVC.navigationItem.rightBarButtonItems = @[self.delItem];
            
            NSString *til = [NSString stringWithFormat:@"%d / %ld", _selectCount, _dataArr.count];
            if(til) {
                self.titleLabel.text = til;
                self.mainVC.navigationItem.titleView = self.titleLabel;
            }
            [UIView animateWithDuration:0.15 animations:^{
                self.mainVC.navigationController.navigationBar.alpha = 1.0;
            }];
        }];
    }else {
        self.mainVC.navigationItem.leftBarButtonItems = @[self.cancleItem];
        self.mainVC.navigationItem.rightBarButtonItems = @[self.delItem];
        
        NSString *til = [NSString stringWithFormat:@"%d / %ld", _selectCount, _dataArr.count];
        if(til) {
            self.titleLabel.text = til;
            self.mainVC.navigationItem.titleView = self.titleLabel;
        }
        
        self.mainVC.navigationController.navigationBar.alpha = 1.0;
    }
}

- (void)SPVideoView:(SPVideoView *)videoView changeToDeleteStyle:(BOOL)state {
    SPVideo *video = videoView.video;
    video.isDelete = YES;
    if (_status == DeleteStatus) {
        for (SPVideo *_video in _selectArr) {
            if ([video.path hash] == [_video.path hash]) {
                video.isDelete = YES;
            }else {
                video.isDelete = NO;
            }
        }
        return;
    }
    
    _selectArr = [[NSMutableArray alloc] init];
    [_selectArr addObject:video];
    _status = DeleteStatus;
    _selectCount = 1;
    [self configRefresh];
    
    [self updateVisiableCell];
    
    self.delBtn.enabled = YES;
    self.delBtn.alpha = 1.0;
    
    //navigation
    [self resetNaviWithAnimation:YES];
    
    NSUInteger jumpToVC = (_type == HistoryVideosType) ? DeleteHistoryType : DeleteLoaclVideosType;
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:jumpToVC]
                             };
    [self.view bubbleEventWithUserInfo:notify];
}

- (void)SPVideoView:(SPVideoView *)videoView deleteAction:(BOOL)state {
    //    SPVideo *video = _dataArr[videoView.indexPath.row];
    SPVideo *video = videoView.video;
    state ? [_selectArr addObject:video] : [_selectArr removeObject:video];
    [self resetTitleView:state];
}

- (void)SPVideoCollectionView:(SPVideoCollectionView *)videoView changeToDeleteStyle:(BOOL)state {
    //    SPVideo *video = _dataArr[videoView.indexPath.item];
    SPVideo *video = videoView.video;
    video.isDelete = YES;
    if (_status == DeleteStatus) {
        for (SPVideo *_video in _selectArr) {
            if ([video.path hash] == [_video.path hash]) {
                video.isDelete = YES;
            }else {
                video.isDelete = NO;
            }
        }
        return;
    }
    
    _status = DeleteStatus;
    [self configRefresh];
    _selectArr = [[NSMutableArray alloc] init];
    [_selectArr addObject:video];
    _selectCount = 1;
    
    self.delBtn.enabled = YES;
    self.delBtn.alpha = 1.0;
    //navigation
    [self resetNaviWithAnimation:YES];
    
    [self updateVisiableCell];
    
    NSUInteger jumpToVC = (_type == HistoryVideosType) ? DeleteHistoryType : DeleteLoaclVideosType;
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:jumpToVC]
                             };
    [self.view bubbleEventWithUserInfo:notify];
}

- (void)SPVideoCollectionView:(SPVideoCollectionView *)videoView deleteAction:(BOOL)state {
    //    SPVideo *video = _dataArr[videoView.indexPath.item];
    SPVideo *video = videoView.video;
    state ? [_selectArr addObject:video] : [_selectArr removeObject:video];
    [self resetTitleView:state];
}

- (void)SPVideoCollectionView:(SPVideoCollectionView *)videoView favStateChanged:(BOOL)state {
    return;
    
    if (_type == FavoriteVideosType) {
        //        [_dataArr removeObject:video];
        //        [self reload];
    }
}

#pragma -mark scrollView delegate
- (void)addGradientLayer:(CGFloat)offsetY {
    CGFloat Height = 2 * offsetY;
    if (offsetY >= 27.0) {
        Height = 54;
    }else if(offsetY <= 0){
        Height = 0.0;
    }
    
    [self gradientLayer:Height];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_dataArr || _dataArr.count <= 0) {
        return;
    }
    
    CGFloat offsetY =  scrollView.contentOffset.y;
    [self addGradientLayer:offsetY];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_autoRefresh) {
        _autoRefresh = NO;
        [self updateThumbnail];
    }
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//
//    // 去除尾视图粘性的方法
//    CGFloat sectionFooterHeight = kWSCALE*94;
//
//    CGFloat size_height = scrollView.contentSize.height;
//
//    CGFloat contentOffset_y = scrollView.contentOffset.y;
//
//    CGFloat result = size_height - contentOffset_y - [UIScreen mainScreen].bounds.size.height;
//
//    if (result > sectionFooterHeight) {
//        scrollView.contentInset = UIEdgeInsetsMake(64, 0, -sectionFooterHeight, 0);
//    }else{
//        if (result>0) {
//            scrollView.contentInset = UIEdgeInsetsMake(64, 0, -result, 0);
//        }else{
//            scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
//        }
//    }
//}
@end

@implementation SPAlertViewController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //    [self alertViewSubviews:self];
}

#pragma -mark private
- (NSArray <UIView *>*)alertControllerActionView:(UIView *)view {
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    for (UIView *v in view.subviews) {
        //        //     NSLog(@"alertControllerActionView ===  %@", v);
        if ([v isKindOfClass:[UILabel class]]) {
            [labels addObject:v];
        }else{
            [labels  addObjectsFromArray:[self alertControllerActionView:v]];
        }
    }
    
    return [labels copy];
}

- (void)alertViewSubviews:(UIViewController *)vc {
    NSArray <UIView *>*labels = [self alertControllerActionView:vc.view];
    for (UILabel *label in labels) {
        if ([label.text isEqualToString:@"Delete"]) {
            label.font = [UIFont fontWithName:@"Calibri-Bold" size:20.0];
            return;
        }
    }
}
@end

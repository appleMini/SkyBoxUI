//
//  SPMainViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/14.
//

#import "SPMainViewController.h"
#import "SPSwitchBar.h"
#import "UIView+SPSwitchBar.h"
#import "SPMenuViewController.h"
#import "SPHomeViewController.h"
#import "SPHelpRootViewController.h"
#import "SPHistoryViewController.h"
#import "SPMuliteViewController.h"
#import "SPAirScreenResultViewController.h"
#import "SPAirScreenViewController.h"
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface SPMainViewController ()<UIScrollViewDelegate, SPSwitchBarProtocol, SPMenuJumpProtocol> {
    BOOL _canRefresh;
    NSInteger _selectMenuIndex;
}

@property (nonatomic, weak) UIScrollView *contentView;

@property (nonatomic, strong) SPMenuViewController *menuVC;
@property (nonatomic, strong) SPHistoryViewController *historyVC;

@property (nonatomic, strong) SPHomeViewController *homeVC;
@property (nonatomic, strong) SPVRViewController *vrVC;
@property (nonatomic, strong) SPNetworkViewController *networkVC;
@property (nonatomic, strong) SPAirScreenResultViewController *airscreenResultVC;
@property (nonatomic, strong) SPFavoriteViewController *favoriteVC;


@end

@implementation SPMainViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        _selectMenuIndex = -1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doRefresh) name:SCANOVERUITOUNITYNOTIFICATIONNAME object:nil];
    }
    return self;
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCANOVERUITOUNITYNOTIFICATIONNAME object:nil];
}

- (void)doRefresh {
    _canRefresh = YES;
    self.homeVC.refreshEnable = YES;
}

- (NSString *)titleOfLabelView {
    return @"MY VIDEOS";
}

#pragma mark----网络检测
- (void)monitorNetWorkState
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    // 提示：要监控网络连接状态，必须要先调用单例的startMonitoring方法
    [manager startMonitoring];
    
    //检测的结果
    __weak typeof(self) wself = self;
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (wself.childViewControllers.count != 3) {
            return;
        }
        SPBaseViewController *vc = wself.childViewControllers[1];
        if (vc.netStateBlock) {
            vc.netStateBlock(status);
        }
    }];
}

- (NSDictionary *)params {
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    SPAirscreen *airscreen = [SPDataManager shareSPDataManager].airscreen;
    if (airscreen) {
        [mutableDict addEntriesFromDictionary:@{@"airscreen" : [airscreen mj_JSONString]}];
    }
    
    NSArray *devices = [SPDataManager shareSPDataManager].devices;
    if (devices) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:devices.count];
        for (SPCmdAddDevice *device in devices) {
            [arr addObject:[device mj_JSONString]];
        }
        
        [mutableDict addEntriesFromDictionary:@{@"devices" : arr}];
    }
    
    return [mutableDict copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //清除缓存
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    [[SDImageCache sharedImageCache] clearMemory];
    
    // Do any additional setup after loading the view.
    //注册DLAN回调
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"RegisterDLANCallBack"}];
    
    SPMenuViewController *menuVC = [[SPMenuViewController alloc] init];
    menuVC.delegate = self;
    self.menuVC = menuVC;
    
    SPHistoryViewController *HistoryVC = [[SPHistoryViewController alloc] initWithSomething];
    HistoryVC.mainVC = self;
    HistoryVC.refreshEnable = NO;
    self.historyVC = HistoryVC;
    
    SPHomeViewController *homeVC = [[SPHomeViewController alloc] initWithSomething];
    _homeVC = homeVC;
    _homeVC.refreshEnable = YES;
    _homeVC.mainVC = self;
    _homeVC.isShow = YES;
    
    NSArray <UIViewController *>*childVCs = @[self.menuVC, homeVC, self.historyVC];
    [self setUpWithChildVCs:childVCs];
    
    [SPSwitchBar shareSPSwitchBar].delegate = self;
    [self.view addSubview:[SPSwitchBar shareSPSwitchBar]];
    
    [self monitorNetWorkState];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //设置打开抽屉模式
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar];
    [self.view bringSubviewToFront:[SPSwitchBar shareSPSwitchBar]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _selectMenuIndex = 0;
        [self.menuVC selectMenuItem:0 jump:NO];
        [[SPSwitchBar shareSPSwitchBar] showVRMode];
        [UIView animateWithDuration:0.01 animations:^{
            [self.contentView setContentOffset:CGPointMake(1 * self.contentView.width, 0) animated:NO];
        } completion:^(BOOL finished) {
            self.homeVC.isShow = YES;
        }];
    });
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat top = [SPDeviceUtil isiPhoneX] ? 34  : 20;
    
    CGRect contentFrame = CGRectMake(0, top, self.view.width, self.view.height - top);
    self.contentView.frame = contentFrame;
    self.contentView.contentSize = CGSizeMake(self.childViewControllers.count * self.view.width, 0);
    
    for (int i=0; i<self.childViewControllers.count; i++) {
        CGFloat vtop =  (i == 0) ? 0 : 64;
        UIViewController *vc = self.childViewControllers[i];
        vc.view.frame = CGRectMake(i * self.contentView.width, vtop, self.contentView.width, self.contentView.height-vtop);
    }
}

- (UIScrollView *)contentView {
    if (!_contentView) {
        
        UIScrollView *contentView = [[UIScrollView alloc] init];
        adjustsScrollViewInsets(contentView);
        contentView.delegate = self;
        contentView.pagingEnabled = YES;
        contentView.showsVerticalScrollIndicator = NO;
        contentView.showsHorizontalScrollIndicator = NO;
        contentView.bounces = NO;
        [self.view addSubview:contentView];
        contentView.backgroundColor = [UIColor clearColor];
        _contentView = contentView;
        _contentView.clipsToBounds = NO;
    }
    return _contentView;
}

- (void)changeTitleView:(SPBaseViewController *)vc {
    UIView *titleView = [vc customTitleView];
    if (titleView) {
        self.navigationItem.titleView = titleView;
    }
    
    NSString *til = [vc titleOfLabelView];
    if(til) {
        self.titleLabel.text = til;
        self.navigationItem.titleView = self.titleLabel;
    }
    
    if (!titleView && !til) {
        self.navigationItem.titleView = nil;
    }
}

- (void)setUpWithChildVCs: (NSArray <UIViewController *>*)childVCs {
    if (self.childViewControllers.count == 3) {
        SPBaseViewController *vc = self.childViewControllers[1];
        [vc releaseAction];
        [vc.view removeFromSuperview];
    }
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    
    self.contentView.contentSize = CGSizeMake(childVCs.count * self.view.width, 0);
    
    for (int i=0; i<childVCs.count; i++) {
        CGFloat top =  (i == 0) ? 0 : 64;
        UIViewController *vc = childVCs[i];
        [self addChildViewController:vc];
        vc.view.frame = CGRectMake(i * self.contentView.width, top, self.contentView.width, self.contentView.height-top);
        [self.contentView addSubview:vc.view];
    }
}

- (SPBaseViewController *)setupNaviItem:(NSInteger)index {
    if (self.childViewControllers.count == 0 || index < 0 || index > self.childViewControllers.count - 1) {
        return nil;
    }
    SPBaseViewController *vc = self.childViewControllers[index];
    
    BOOL isShow = [vc showNavigatinBar];
    
    self.navigationItem.leftBarButtonItems = [vc leftNaviItem];
    self.navigationItem.rightBarButtonItems = [vc rightNaviItem];
    
    UIView *titleView = [vc customTitleView];
    if (titleView) {
        self.navigationItem.titleView = titleView;
    }
    
    NSString *til = [vc titleOfLabelView];
    if(til) {
        self.titleLabel.text = til;
        self.navigationItem.titleView = self.titleLabel;
    }
    
    if (!titleView && !til) {
        self.navigationItem.titleView = nil;
    }
    
    self.navigationController.navigationBar.hidden = !isShow;
    [self.navigationController.navigationBar setNeedsLayout];
    return vc;
}

- (void)showLastChildVC {
    if (self.childViewControllers.count == 3) {
        SPBaseViewController *vc = self.childViewControllers[2];
        vc.refreshEnable = YES;
        (_canRefresh) ? [vc refresh] : nil;
    }
}

- (void)showChildVCAtIndex:(NSInteger)index {
    [self showChildVCViewAtIndex:index shouldRefresh:YES];
}

- (void)showChildVCViewAtIndex:(NSInteger)index shouldRefresh:(BOOL)refresh {
    if (self.childViewControllers.count == 0 || index < 0 || index > self.childViewControllers.count - 1) {
        return;
    }
    
    SPBaseViewController *vc = [self setupNaviItem:index];
    vc.refreshEnable = YES;
    vc.mainVC = self;
    
    for (int i=0; i<self.childViewControllers.count; i++) {
        SPBaseViewController *mvc = self.childViewControllers[i];
        mvc.isShow = (i == index) ? YES : NO;
    }
    
    [vc viewWillToChanged];
    
    CGFloat top =  (index == 0) ? 0 : 64;
    vc.view.frame = CGRectMake(index * self.contentView.width, top, self.contentView.width, self.contentView.height-top);
    
    // 滑动到对应位置
    [self.contentView setContentOffset:CGPointMake(index * self.contentView.width, 0) animated:YES];
    
    (_canRefresh && refresh) ? [vc refresh] : nil;
    [SPSwitchBar shareSPSwitchBar].selectIndex = index;
}

- (void)changeHistoryView:(SPBaseViewController *)vc shouldRefresh:(BOOL)refresh {
    SPBaseViewController *mvc = self.childViewControllers[1];
    NSArray <UIViewController *>*childVCs = @[self.menuVC, mvc, vc];
    [self setUpWithChildVCs:childVCs];
    
    [self showChildVCViewAtIndex:2 shouldRefresh:refresh];
    [SPSwitchBar shareSPSwitchBar].selectIndex = 2;
}

- (void)changeMiddleContentView:(SPBaseViewController *)vc shouldRefresh:(BOOL)refresh {
    NSArray <UIViewController *>*childVCs = @[self.menuVC, vc, self.historyVC];
    [self setUpWithChildVCs:childVCs];
    
    [self showChildVCViewAtIndex:1 shouldRefresh:refresh];
    [SPSwitchBar shareSPSwitchBar].selectIndex = 1;
}

- (void)jumpToAirScreenResultVC:(NSDictionary *)dict {
    NSArray *videos = dict[@"dataSource"];
    SPAirscreen *airscreen = dict[@"airscreen"];
    SPAirScreenResultViewController *airscreenResult = [[SPAirScreenResultViewController alloc] initWithDataSource:videos type:AirScreenType displayType:CollectionViewType];
    airscreenResult.airscreen = airscreen;
    [self changeMiddleContentView:airscreenResult shouldRefresh:NO];
}
#pragma -mark UIScrollViewDelegate
- (CGFloat)fixAlpha:(CGFloat)x baseWidth:(CGFloat)width {
    CGFloat alpha = 1.0 -  1.0 * (x * 2 / width);
    return alpha;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat moveDistance = scrollView.frame.size.width - scrollView.contentOffset.x;
    //moving
    [[SPSwitchBar shareSPSwitchBar] fixPosition:moveDistance baseWidth:scrollView.frame.size.width];
    CGFloat alpha = [self fixAlpha:fabs(moveDistance) baseWidth:scrollView.frame.size.width];
    
    NSInteger index = scrollView.contentOffset.x/scrollView.width;
    if (index == 0) {
        if(alpha >= 0) {
            [self setupNaviItem:1];
        }else{
            [self setupNaviItem:0];
        }
    }else if(index == 1) {
        if(alpha <= 0 && moveDistance >= 0) {
            [self setupNaviItem:0];
        }else if(alpha <= 0 && moveDistance <= 0){
            [self setupNaviItem:2];
        }else{
            [self setupNaviItem:1];
        }
    }else if(index == 2){
        if(alpha >= 0) {
            [self setupNaviItem:1];
        }else{
            [self setupNaviItem:2];
        }
    }
    
    self.navigationController.navigationBar.alpha = fabs(alpha);
    if (self.childViewControllers.count == 3) {
        SPBaseViewController *middleVC = self.childViewControllers[1];
        [middleVC showTopViewAlpha:alpha];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [[SPSwitchBar shareSPSwitchBar] resetAnimation];
    
    NSInteger index = scrollView.contentOffset.x/scrollView.width;
    SPBaseViewController *vc = self.childViewControllers[index];
    vc.refreshEnable = YES;
    
    for (int i=0; i<self.childViewControllers.count; i++) {
        SPBaseViewController *mvc = self.childViewControllers[i];
        mvc.isShow = (i == index) ? YES : NO;
    }
    
    [vc viewWillToChanged];
    
    NSInteger selectIndex = [SPSwitchBar shareSPSwitchBar].selectIndex;
    if (selectIndex == index) {
        return;
    }
    [SPSwitchBar shareSPSwitchBar].selectIndex = index;
    if (index == 2) {
        [self showLastChildVC];
    }
}
#pragma -mark SPSwitchBarDelegate
- (void)switchBar:(SPSwitchBar *)bar selectIndex:(NSInteger)index {
    // 滑动到对应位置
    [self.contentView setContentOffset:CGPointMake(index * self.contentView.width, 0) animated:YES];
}

#pragma -mark jumpToMiddleVC
- (void)jumpToMiddleVC:(SPBaseViewController *)vc menuIndex:(NSInteger)index {
    if (index < 0 || index >= self.menuVC.menuCount) {
        return;
    }
    
    [self.menuVC selectMenuItem:index jump:YES];
}
#pragma -mark SPMenuJumpProtocol
- (void)jumpViewController:(NSString *)ctrS {
    BOOL refresh = YES;
    SPBaseViewController *VC = nil;
    if ([ctrS hash] == [NSStringFromClass([SPHomeViewController class]) hash]) {
        if (!self.homeVC) {
            self.homeVC =  [[SPHomeViewController alloc] initWithSomething];
        }

        VC = self.homeVC;
    }else if ([ctrS hash] == [NSStringFromClass([SPVRViewController class]) hash]) {
        if (!self.vrVC) {
            self.vrVC =  [[SPVRViewController alloc] initWithSomething];
        }
        VC = self.vrVC;
    }else if ([ctrS hash] == [NSStringFromClass([SPNetworkViewController class]) hash]) {
        if (!self.networkVC) {
            self.networkVC =  [[SPNetworkViewController alloc] initWithSomething];
        }

        VC = self.networkVC;
    }else if ([ctrS hash] == [NSStringFromClass([SPAirScreenViewController class]) hash]) {
        SPAirscreen *airscreen = [SPDataManager shareSPDataManager].airscreen;
        
        if (!airscreen) {
            VC =  [[SPAirScreenViewController alloc] initWithSomething];
            refresh = NO;
        }else {
            if ([[self.airscreenResultVC.airscreen computerId] hash] != [airscreen.computerId hash]) {
                VC = self.airscreenResultVC = [[SPAirScreenResultViewController alloc] initWithSomething];
                self.airscreenResultVC.airscreen = airscreen;
            }else {
                VC = self.airscreenResultVC;
                self.airscreenResultVC.airscreen = airscreen;
                refresh = YES;
            }
        }
    }else if ([ctrS hash] == [NSStringFromClass([SPFavoriteViewController class]) hash]) {
        if (!self.favoriteVC) {
            self.favoriteVC =  [[SPFavoriteViewController alloc] initWithSomething];
        }
        VC = self.favoriteVC;
    }
    
    [self changeMiddleContentView:VC shouldRefresh:refresh];
}

- (void)cacheMidleVC:(SPBaseViewController *)vc {
    if ([vc isMemberOfClass:[SPHomeViewController class]]) {
        self.homeVC = (SPHomeViewController *)vc;
    }else if ([vc isMemberOfClass:[SPVRViewController class]]) {
        self.vrVC = (SPVRViewController *)vc;
    }else if ([vc isMemberOfClass:[SPNetworkViewController class]]) {
        self.networkVC = (SPNetworkViewController *)vc;
    }else if ([vc isMemberOfClass:[SPAirScreenResultViewController class]]) {
        self.airscreenResultVC = (SPAirScreenResultViewController *)vc;
    }else if ([vc isMemberOfClass:[SPFavoriteViewController class]]) {
        self.favoriteVC = (SPFavoriteViewController *)vc;
    }
}

- (void)MenuViewController:(UIViewController *)menu jumpViewController:(NSString *)ctrS menuIndex:(NSInteger)index {
    self.navigationController.navigationBar.alpha = 0.0;
    if (self.childViewControllers.count < 3) {
        return;
    }
    SPBaseViewController *vc = self.childViewControllers[1];
    
    if ((_selectMenuIndex == index) && [vc isMemberOfClass:[SPAirScreenViewController class]]) {
        SPAirscreen *airscreen = [SPDataManager shareSPDataManager].airscreen;
        if (airscreen) {
            //缓存VC
            [self cacheMidleVC:vc];
            [self jumpViewController:@"SPAirScreenViewController"];
        }else {
            [self showChildVCViewAtIndex:1 shouldRefresh:NO];
        }
        
        return;
    }
    
    _selectMenuIndex = index;
    
    if (ctrS) {
        Class cls =  NSClassFromString(ctrS);
        if (!cls) {
            return;
        }
        
        if ([NSStringFromClass([vc class]) hash] == [ctrS hash]) {
            [self showChildVCViewAtIndex:1 shouldRefresh:YES];
            return;
        }else {
            //缓存VC
            [self cacheMidleVC:vc];
        }
        
        [self jumpViewController:ctrS];
        
    }
    
}

#pragma mark UIResponder bubble
- (void)bubbleEventWithUserInfo:(NSDictionary *)userInfo {
    self.contentView.scrollEnabled = YES;
    
    NSInteger respType = (ResponderType)[[userInfo objectForKey:kEventType] unsignedIntegerValue];
    //    id target = [userInfo objectForKey:kTopViewController];
    NSString *path = [userInfo objectForKey:@"path"];
    switch (respType) {
        case NativeToUnityType:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:KEYWINDOW animated:YES];
            });
            if(self.jumpDelegate && [self.jumpDelegate respondsToSelector:@selector(nativeToUnity: intoVRMode:)]) {
                if (self.childViewControllers.count < 3) {
                    return;
                }
                SPBaseViewController *vc = self.childViewControllers[1];
                [vc releaseAction];
                vc.isShow = NO;
                
                NSMutableDictionary *params = [self NativeToUnityWithParams];
                if (path) {
                    [params addEntriesFromDictionary:@{@"path" : path}];
                }else {
                    [params addEntriesFromDictionary:@{@"path" : @"no_media_location"}];
                }
                
                NSString *mediaType = [userInfo objectForKey:@"mediaType"];
                if (mediaType) {
                    [params addEntriesFromDictionary:@{@"mediaType" : mediaType}];
                }
                
                [self.jumpDelegate nativeToUnity:[params copy] intoVRMode:nil];
            }
        }
            break;
        case AirScreenResultMiddleVCType:
        {
            SPAirscreen *airscreen = [userInfo objectForKey:@"airscreen"];
            SPAirScreenResultViewController *airscreenResult = [[SPAirScreenResultViewController alloc] initWithSomething];
            airscreenResult.airscreen = airscreen;
            [self changeMiddleContentView:airscreenResult shouldRefresh:YES];
        }
            break;
        case AirScreenMiddleVCType:
        {
            //断开airscreen
            self.airscreenResultVC = nil;
            SPBaseViewController *vc = [[SPAirScreenViewController alloc] initWithSomething];
            [self changeMiddleContentView:vc shouldRefresh:NO];
        }
            break;
        case HomeHelpMiddleVCType:
        {
            BOOL done = [[userInfo objectForKey:@"Done"] boolValue];
            SPBaseViewController *vc = done ? [[SPHelpRootViewController alloc] initWithDoneAction] : [[SPHelpRootViewController alloc] initWithSomething];
            [self changeMiddleContentView:vc shouldRefresh:NO];
        }
            break;
        case LocalFileMiddleVCType:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                SPBaseViewController *oldvc = self.childViewControllers[1];
                oldvc.view.alpha = 1.0;
                [UIView animateWithDuration:0.5 animations:^{
                    oldvc.view.alpha = 0.0;
                } completion:^(BOOL finished) {
                    SPBaseViewController *VC = nil;
                    if (!self.homeVC) {
                       self.homeVC =  [[SPHomeViewController alloc] initWithSomething];
                    }
                    VC = self.homeVC;
                 
                    [self changeMiddleContentView:VC shouldRefresh:YES];
                    VC.view.alpha = 0.0;
                    [UIView animateWithDuration:1.5 animations:^{
                        VC.view.alpha = 1.0;
                    }];
                }];
            });
        }
            break;
        case DeleteLoaclVideosType:
        {
            if (!self.contentView.scrollEnabled) {
                return;
            }
            
            [[SPSwitchBar shareSPSwitchBar] hiddenWithAnimation];
            self.contentView.scrollEnabled = NO;
        }
            break;
        case CommonLoaclVideosType:
        {
            [[SPSwitchBar shareSPSwitchBar] showWithAnimation];
            [self setupNaviItem:1];
        }
            break;
            
        case DeleteHistoryType:
        {
            if (!self.contentView.scrollEnabled) {
                return;
            }
            
            [[SPSwitchBar shareSPSwitchBar] hiddenWithAnimation];
            self.contentView.scrollEnabled = NO;
        }
            break;
            
        case CommonHistoryType:
        {
            [[SPSwitchBar shareSPSwitchBar] showWithAnimation];
            [self setupNaviItem:2];
        }
            break;
        case TestType:
        {
            NSString *mName = [userInfo objectForKey:kFunctionName];
            NSString *param =  [userInfo objectForKey:kParams];
            if(self.jumpDelegate && [self.jumpDelegate respondsToSelector:@selector(nativeToUnity: methodName: param:)]) {
                //                [self.jumpDelegate nativeToUnity:target methodName:mName param:param];
            }
        }
            break;
            
        default:
            break;
    }
}

- (NSMutableDictionary *)NativeToUnityWithParams {
    NSString *mediaTab = nil;
    if (_selectMenuIndex == 0) {
        mediaTab = @"gallery";
    }else if(_selectMenuIndex == 1) {
        mediaTab = @"my_videos";
    }else if(_selectMenuIndex == 2) {
        mediaTab = @"localNetwork";
    }else if(_selectMenuIndex == 3) {
        mediaTab = @"airscreen";
    }else if(_selectMenuIndex == 4) {
        mediaTab = @"favourite";
    }else if(_selectMenuIndex == 5) {
//        mediaTab = @"favourite";
//         mediaTab = @"onlineStream";
        mediaTab = @"gallery";
    }else {
        mediaTab = @"gallery";
    }
    
    if (self.childViewControllers.count < 3) {
        return nil;
    }
    SPBaseViewController *vc = self.childViewControllers[1];
    NSMutableDictionary *vcDict = [[NSMutableDictionary alloc] init];
    [vcDict addEntriesFromDictionary:[vc params]];
    [vcDict addEntriesFromDictionary:@{@"mediaTab" : mediaTab}];
    [vcDict addEntriesFromDictionary:[self params]];
    
    return vcDict;
}

@end



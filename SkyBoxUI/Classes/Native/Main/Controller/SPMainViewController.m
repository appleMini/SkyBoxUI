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

@interface SPMainViewController ()<UIScrollViewDelegate, SPSwitchBarProtocol, SPMenuJumpProtocol> {
    BOOL _canRefresh;
    NSInteger _selectMenuIndex;
}

@property (nonatomic, weak) UIScrollView *contentView;

@property (nonatomic, strong) SPMenuViewController *menuVC;
@property (nonatomic, strong) SPHistoryViewController *historyVC;

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
    SPAirscreen *airscreen = [SPDataManager shareDataManager].airscreen;
    if (airscreen) {
        [mutableDict addEntriesFromDictionary:@{@"airscreen" : [airscreen mj_JSONString]}];
    }
    
    NSArray *devices = [SPDataManager shareDataManager].devices;
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
    // Do any additional setup after loading the view.
    //注册DLAN回调
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"RegisterDLANCallBack"}];
    
    SPMenuViewController *menuVC = [[SPMenuViewController alloc] init];
    menuVC.delegate = self;
    self.menuVC = menuVC;
    
    SPHistoryViewController *HistoryVC = [[SPHistoryViewController alloc] initWithSomething];
    self.historyVC = HistoryVC;
    
    SPHomeViewController *homeVC = [[SPHomeViewController alloc] initWithSomething];
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
        [self.menuVC selectMenuItem:0 jump:YES];
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
        contentView.showsHorizontalScrollIndicator = YES;
        contentView.bounces = NO;
        [self.view addSubview:contentView];
        contentView.backgroundColor = [UIColor clearColor];
        _contentView = contentView;
    }
    return _contentView;
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
    return vc;
}

- (void)showLastChildVC {
    if (self.childViewControllers.count == 3) {
        SPBaseViewController *vc = self.childViewControllers[2];
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
    
    CGFloat top =  (index == 0) ? 0 : 64;
    vc.view.frame = CGRectMake(index * self.contentView.width, top, self.contentView.width, self.contentView.height-top);
    
    // 滑动到对应位置
    [self.contentView setContentOffset:CGPointMake(index * self.contentView.width, 0) animated:YES];
    
    (_canRefresh && refresh) ? [vc refresh] : nil;
    [SPSwitchBar shareSPSwitchBar].selectIndex = index;
}

- (void)changeMiddleContentView:(SPBaseViewController *)vc {
    
    NSArray <UIViewController *>*childVCs = @[self.menuVC, vc, self.historyVC];
    [self setUpWithChildVCs:childVCs];
    
    [self showChildVCAtIndex:1];
    [SPSwitchBar shareSPSwitchBar].selectIndex = 1;
}

- (void)jumpToAirScreenResultVC:(NSDictionary *)dict {
    NSArray *videos = dict[@"dataSource"];
    SPAirscreen *airscreen = dict[@"airscreen"];
    SPAirScreenResultViewController *airscreenResult = [[SPAirScreenResultViewController alloc] initWithDataSource:videos type:AirScreenType displayType:CollectionViewType];
    airscreenResult.airscreen = airscreen;
    [self changeMiddleContentView:airscreenResult];
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
        SPBaseViewController *vc = self.childViewControllers[1];
        [vc showTopViewAlpha:alpha];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [[SPSwitchBar shareSPSwitchBar] resetAnimation];
    
    NSInteger index = scrollView.contentOffset.x/scrollView.width;
    
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
    [self showChildVCAtIndex:index];
}

#pragma -mark jumpToMiddleVC
- (void)jumpToMiddleVC:(SPBaseViewController *)vc menuIndex:(NSInteger)index {
    if (index < 0) {
        return;
    }
    
    _selectMenuIndex = index;
    
    [self.menuVC selectMenuItem:index jump:NO];
    [self changeMiddleContentView:vc];
}
#pragma -mark SPMenuJumpProtocol
- (void)MenuViewController:(UIViewController *)menu jumpViewController:(NSString *)ctrS menuIndex:(NSInteger)index{
    self.navigationController.navigationBar.alpha = 0.0;
    if (_selectMenuIndex == index) {
        [self showChildVCViewAtIndex:1 shouldRefresh:NO];
        return;
    }
    
    _selectMenuIndex = index;
    if (ctrS) {
        Class cls =  NSClassFromString(ctrS);
        if (!cls) {
            return;
        }
        
        SPBaseViewController *vc = [[cls alloc] initWithSomething];
        [self changeMiddleContentView:vc];
    }
    
}

#pragma mark UIResponder bubble
- (void)bubbleEventWithUserInfo:(NSDictionary *)userInfo {
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
                
                NSMutableDictionary *params = [self NativeToUnityWithParams];
                if (path) {
                    [params addEntriesFromDictionary:@{@"path" : path}];
                }else {
                    [params addEntriesFromDictionary:@{@"path" : @"no_media_location"}];
                }
                [self.jumpDelegate nativeToUnity:[params copy] intoVRMode:nil];
            }
        }
            break;
        case AirScreenResultMiddleVCType:
        {
            NSDictionary *dict = [userInfo objectForKey:kParams];
            [self jumpToAirScreenResultVC:dict];
        }
            break;
        case AirScreenMiddleVCType:
        {
            SPBaseViewController *vc = [[SPAirScreenViewController alloc] initWithSomething];
            [self changeMiddleContentView:vc];
        }
            break;
        case HomeHelpMiddleVCType:
        {
            SPBaseViewController *vc = [[SPHelpRootViewController alloc] initWithSomething];
            [self changeMiddleContentView:vc];
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
        mediaTab = @"onlineStream";
    }else if(_selectMenuIndex == 5) {
        mediaTab = @"favourite";
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

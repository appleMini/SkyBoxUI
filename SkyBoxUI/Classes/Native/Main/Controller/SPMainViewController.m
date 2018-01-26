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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    CGFloat top = 0;
    if (@available(iOS 11.0, *)) {
        top = self.view.safeAreaInsets.top;
    } else {
        top = 64;
    }
    CGRect contentFrame = CGRectMake(0, top, self.view.width, self.view.height - top);
    self.contentView.frame = contentFrame;
    self.contentView.contentSize = CGSizeMake(self.childViewControllers.count * self.view.width, 0);
    
    for (int i=0; i<self.childViewControllers.count; i++) {
        UIViewController *vc = self.childViewControllers[i];
        vc.view.frame = CGRectMake(i * self.contentView.width, 0, self.contentView.width, self.contentView.height);
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
        contentView.backgroundColor = [UIColor blueColor];
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
        UIViewController *vc = childVCs[i];
        [self addChildViewController:vc];
        vc.view.frame = CGRectMake(i * self.contentView.width, 0, self.contentView.width, self.contentView.height);
        [self.contentView addSubview:vc.view];
    }
}

- (SPBaseViewController *)setupNaviItem:(NSInteger)index {
    if (self.childViewControllers.count == 0 || index < 0 || index > self.childViewControllers.count - 1) {
        return nil;
    }
    SPBaseViewController *vc = self.childViewControllers[index];
    
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
    return vc;
}

- (void)showChildVCViewAtIndex:(NSInteger)index {
    if (self.childViewControllers.count == 0 || index < 0 || index > self.childViewControllers.count - 1) {
        return;
    }
    
    //    SPBaseViewController *middleVC = self.childViewControllers[1];
    //    if (index != 1) {
    //        [middleVC showOrHiddenTopView:NO];
    //    }else {
    //        [middleVC showOrHiddenTopView:YES];
    //    }
    
    SPBaseViewController *vc = [self setupNaviItem:index];
    
    vc.view.frame = CGRectMake(index * self.contentView.width, 0, self.contentView.width, self.contentView.height);
    
    // 滑动到对应位置
    [self.contentView setContentOffset:CGPointMake(index * self.contentView.width, 0) animated:YES];
    
    _canRefresh ? [vc refresh] : nil;
    [SPSwitchBar shareSPSwitchBar].selectIndex = index;
}

- (void)changeMiddleContentView:(SPBaseViewController *)vc {
    
    NSArray <UIViewController *>*childVCs = @[self.menuVC, vc, self.historyVC];
    [self setUpWithChildVCs:childVCs];
    
    [self showChildVCViewAtIndex:1];
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
    
    [self showChildVCViewAtIndex:index];
}
#pragma -mark SPSwitchBarDelegate
- (void)switchBar:(SPSwitchBar *)bar selectIndex:(NSInteger)index {
    [self showChildVCViewAtIndex:index];
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
        [self showChildVCViewAtIndex:1];
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
    id target = [userInfo objectForKey:kTopViewController];
    
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
                
                [self.jumpDelegate nativeToUnity:target intoVRMode:nil];
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
@end


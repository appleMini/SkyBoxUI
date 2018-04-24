//
//  SPHomeHelpViewController1.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/29.
//

#import "SPHelpRootViewController.h"
#import "SPHomeHelpViewController.h"
#import "UIView+SPSwitchBar.h"
#import "UILabel+SPAttri.h"

@interface SPHelpRootViewController () <UIScrollViewDelegate> {
    BOOL _canDone;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;


@property (strong, nonatomic) SPHomeHelpViewController *page1VC;
@property (strong, nonatomic) SPHomeHelpViewController *page2VC;

@property (nonatomic, strong) UIBarButtonItem *doneItem;
@end

@implementation SPHelpRootViewController

- (instancetype)initWithDoneAction {
    self = [self initWithSomething];
    if (self) {
        _canDone = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_canDone) {
            self.view.alpha = 0.0;
            [UIView animateWithDuration:0.5 animations:^{
                self.view.alpha = 1.0;
            }];
        }
    });
}

- (instancetype)initWithSomething {
    self = [super initWithNibName:@"SPHelpRootViewController" bundle:[Commons resourceBundle]];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasLocalVideosUpdate) name:UPDATELOCALVIDEOSNOTIFICATIONNAME object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATELOCALVIDEOSNOTIFICATIONNAME object:nil];
}

- (void)hasLocalVideosUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_canDone && self.isShow && self.viewLoaded && self.view.window) {
                NSUInteger selectedIndex = -1;
                NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:LocalFileMiddleVCType],
                                         kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex],
                                         @"Done": @NO
                                         };
            
                [self.view bubbleEventWithUserInfo:notify];
        }
   });
}

- (NSString *)titleOfLabelView {
    return NSLocalizedString(@"Menu_AddVideos", @"ADD VIDEOS");
}

- (NSArray *)rightNaviItem {
    return _canDone ? @[self.doneItem] : nil;
}

- (UIBarButtonItem *)doneItem {
    if (!_doneItem) {
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneBtn setTitle:NSLocalizedString(@"Notice_Done", @"Done") forState:UIControlStateNormal];
        
        UIFont *boldFont = [UIFont fontWithName:@"Calibri-Bold" size:19];
        doneBtn.titleLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:19];
        
        doneBtn.titleLabel.textColor = [SPColorUtil getHexColor:@"#ffffff"];
        doneBtn.backgroundColor = [UIColor clearColor];
        
        if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
            CGSize labelSize = [doneBtn.titleLabel labelSizeWithAttributes:@{NSFontAttributeName : boldFont}];
            doneBtn.frame = CGRectMake(0, 0, labelSize.width, labelSize.height);
        }else {
            doneBtn.frame = CGRectMake(0, 0, 20, 20);
        }
        
        [doneBtn addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneBtn];
    }
    
    return _doneItem;
}

- (void)doneClick:(UIButton *)item {
    //    NSUInteger selectedIndex = -1;
    //    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:LocalFileMiddleVCType],
    //                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex]
    //                             };
    //
    //    [self.view bubbleEventWithUserInfo:notify];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController) {
        self.navigationItem.rightBarButtonItems = [self rightNaviItem];
    }
    
    adjustsScrollViewInsets(self.scrollView);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.contentSize = CGSizeMake(2 * self.view.width, 0);
    self.scrollView.delegate = self;
    [self setupViews];
    
    [self.pageControl addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)setupViews {
    SPHomeHelpViewController *page1VC = [[SPHomeHelpViewController alloc] initWithSomething];
    
    page1VC.view.frame = CGRectMake(0, 0, self.scrollView.width, self.scrollView.height);
    [self.scrollView addSubview:page1VC.view];
    page1VC.currentPage = 0;
    _page1VC = page1VC;
    
    SPHomeHelpViewController *page2VC = [[SPHomeHelpViewController alloc] initWithSomething];
    page2VC.view.frame = CGRectMake(self.scrollView.width, 0, self.scrollView.width, self.scrollView.height);
    [self.scrollView addSubview:page2VC.view];
    page2VC.currentPage = 1;
    _page2VC = page2VC;
    
    self.pageControl.numberOfPages = 2;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect frame = self.scrollView.frame;
    frame.size.width = self.view.width;
    frame.size.height = self.view.height;
    self.scrollView.frame = frame;
    self.scrollView.contentSize = CGSizeMake(2 * self.view.width, 0);
    
    _page1VC.view.frame = CGRectMake(0, 0, self.scrollView.width, self.scrollView.height);
    _page2VC.view.frame = CGRectMake(self.scrollView.width, 0, self.scrollView.width, self.scrollView.height);
}

- (void)pageChange:(UIPageControl *)pageCtrl {
    NSInteger pageIndex = pageCtrl.currentPage;
    
    [self.scrollView setContentOffset:CGPointMake(pageIndex * self.scrollView.width, 0) animated:YES];
}
#pragma -mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x/scrollView.width;
    self.pageControl.currentPage = index;
}
@end

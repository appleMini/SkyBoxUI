//
//  SPHomeHelpViewController1.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/29.
//

#import "SPHelpRootViewController.h"
#import "SPHomeHelpViewController.h"
#import "UIView+SPSwitchBar.h"

@interface SPHelpRootViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;


@property (strong, nonatomic) SPHomeHelpViewController *page1VC;
@property (strong, nonatomic) SPHomeHelpViewController *page2VC;
@end

@implementation SPHelpRootViewController

- (instancetype)initWithSomething {
    self = [super initWithNibName:@"SPHelpRootViewController" bundle:[Commons resourceBundle]];
    if (self) {
        
    }
    return self;
}

- (NSString *)titleOfLabelView {
    return @"ALL FILES";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    adjustsScrollViewInsets(self.scrollView);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = YES;
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

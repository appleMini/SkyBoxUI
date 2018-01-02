//
//  SPAirScreenHelpViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/18.
//

#import "SPAirScreenHelpViewController.h"
#import "PresentAnimationController.h"
#import "DismissAnimationController.h"
#import "SPDeviceUtil.h"

@interface SPAirScreenHelpViewController ()<UIViewControllerTransitioningDelegate>

@end

@implementation SPAirScreenHelpViewController

- (CGSize)preferredContentSize
{
    CGFloat height = [SPDeviceUtil isiPhoneX] ? (SCREEN_HEIGHT - 34 - 44 - kHSCALE*49*1.5 - 50 - 50 - 35) : (SCREEN_HEIGHT - 44 - kHSCALE*49*1.5 - 50 - 50 - 35);
    return CGSizeMake(SCREEN_WIDTH - 70, height);
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)    nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //设置弹出的样式为Custom
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmiss:)];
    [self.view addGestureRecognizer:tap];
}

- (void)dissmiss:(UIGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma -mark UIViewControllerTransitioningDelegate
- (id)animationControllerForPresentedController:(UIViewController *)presented
                           presentingController:(UIViewController *)presenting
                               sourceController:(UIViewController *)source
{
    return [[PresentAnimationController alloc] init];
}

- (id)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[DismissAnimationController alloc] init];
}
@end

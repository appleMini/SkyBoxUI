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

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *helpLabel;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

@property (weak, nonatomic) IBOutlet UILabel *help1TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *help1ContentLabel;

@property (weak, nonatomic) IBOutlet UILabel *help2TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *help2ContentLabel;

@property (weak, nonatomic) IBOutlet UILabel *help3TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *help3ContentLabel;

@property (weak, nonatomic) IBOutlet UILabel *help4TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *help4ContentLabel;

@end

@implementation SPAirScreenHelpViewController

- (CGSize)preferredContentSize
{
//    CGFloat height = [SPDeviceUtil isiPhoneX] ? (SCREEN_HEIGHT - 34 - 44 - kHSCALE*49*1.5 - 50 - 50 - 35) : (SCREEN_HEIGHT - 44 - kHSCALE*49*1.5 - 50 - 50 - 35);
    return CGSizeMake(SCREEN_WIDTH - 96 * kWSCALE, 400);
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
    
    [self configSubViewStyle];
}

- (void)configSubViewStyle {
    self.topView.backgroundColor = [SPColorUtil getHexColor:@"#838a96"];
    self.helpLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:19.0];
    self.helpLabel.textColor = [SPColorUtil getHexColor:@"#ffffff"];
    
    self.topLabel.font = [UIFont fontWithName:@"Calibri" size:13.0];
    self.topLabel.textColor = [SPColorUtil getHexColor:@"#d3d5d9"];
    
    UIFont *boldFont = [UIFont fontWithName:@"Calibri-Bold" size:13.0];
    UIFont *regularFont = [UIFont fontWithName:@"Calibri" size:11.0];
    
    UIColor *boldColor = [SPColorUtil getHexColor:@"#35373a"];
    UIColor *regularColor = [SPColorUtil getHexColor:@"#898b8f"];
    self.help1TitleLabel.font = boldFont;
    self.help1TitleLabel.textColor = boldColor;
    self.help1ContentLabel.font = regularFont;
    self.help1ContentLabel.textColor = regularColor;
    
    self.help2TitleLabel.font = boldFont;
    self.help2TitleLabel.textColor = boldColor;
    self.help2ContentLabel.font = regularFont;
    self.help2ContentLabel.textColor = regularColor;
    
    self.help3TitleLabel.font = boldFont;
    self.help3TitleLabel.textColor = boldColor;
    self.help3ContentLabel.font = regularFont;
    self.help3ContentLabel.textColor = regularColor;
    
    self.help4TitleLabel.font = boldFont;
    self.help4TitleLabel.textColor = boldColor;
    self.help4ContentLabel.font = regularFont;
    self.help4ContentLabel.textColor = regularColor;
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

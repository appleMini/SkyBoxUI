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
#import "UILabel+SPAttri.h"

@interface SPAirScreenHelpViewController ()<UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *helpLabel;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *helpLabelTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1TopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1HeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *help1TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *help1ContentLabel;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view2TopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view2HeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *help2TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *help2ContentLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view3TopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view3HeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *help3TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *help3ContentLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view4TopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view4HeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *help4TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *help4ContentLabel;

@end

@implementation SPAirScreenHelpViewController

- (CGSize)preferredContentSize
{
    CGFloat height = (self.topViewHeightConstraint.constant + self.view1HeightConstraint.constant + self.view2HeightConstraint.constant + self.view3HeightConstraint.constant + self.view4HeightConstraint.constant + 20);
    return CGSizeMake(SCREEN_WIDTH - 88 * kWSCALE, height);
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
    self.topViewHeightConstraint.constant = 100;
    
    self.topView.backgroundColor = [SPColorUtil getHexColor:@"#838a96"];
    self.helpLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:19.0];
    self.helpLabel.textColor = [SPColorUtil getHexColor:@"#ffffff"];
    
    self.topLabel.font = [UIFont fontWithName:@"Calibri" size:15.0];
    self.topLabel.textColor = [SPColorUtil getHexColor:@"#d3d5d9"];
    
    CGFloat limitHelpLabelWidth = SCREEN_WIDTH - 88 * kWSCALE - 20 - 20;
    CGFloat helpLabelHeight = [self.helpLabel labelSizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Calibri-Bold" size:19.0]} boundSize:CGSizeMake(limitHelpLabelWidth, CGFLOAT_MAX)].height;
    CGFloat topLabelHeight = [self.topLabel labelSizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Calibri" size:15.0]} boundSize:CGSizeMake(limitHelpLabelWidth, CGFLOAT_MAX)].height;
    self.helpLabelTopConstraint.constant = 100/2 - (helpLabelHeight + 5 + topLabelHeight) / 2;
    
    UIFont *boldFont = [UIFont fontWithName:@"Calibri-Bold" size:15.0];
    UIFont *regularFont = [UIFont fontWithName:@"Calibri" size:13.0];
    
    UIColor *boldColor = [SPColorUtil getHexColor:@"#35373a"];
    UIColor *regularColor = [SPColorUtil getHexColor:@"#898b8f"];
    self.help1TitleLabel.font = boldFont;
    self.help1TitleLabel.textColor = boldColor;
    self.help1ContentLabel.font = regularFont;
    self.help1ContentLabel.textColor = regularColor;
    
    self.view1TopConstraint.constant = self.topViewHeightConstraint.constant;
    
    CGFloat limitWidth = SCREEN_WIDTH - 88 * kWSCALE - 20 - 40 - 8 - 20;
    CGFloat help1TitleHeight = [self.help1TitleLabel labelSizeWithAttributes:@{NSFontAttributeName : boldFont} boundSize:CGSizeMake(limitWidth, CGFLOAT_MAX)].height;
    CGFloat help1ContentHeight = [self.help1ContentLabel labelSizeWithAttributes:@{NSFontAttributeName : regularFont} boundSize:CGSizeMake(limitWidth, CGFLOAT_MAX)].height;
    self.view1HeightConstraint.constant = 25 + help1TitleHeight + 8 + help1ContentHeight;
    
    self.view2TopConstraint.constant = self.topViewHeightConstraint.constant + self.view1HeightConstraint.constant;
    self.help2TitleLabel.font = boldFont;
    self.help2TitleLabel.textColor = boldColor;
    self.help2ContentLabel.font = regularFont;
    self.help2ContentLabel.textColor = regularColor;
    
    CGFloat help2TitleHeight = [self.help2TitleLabel labelSizeWithAttributes:@{NSFontAttributeName : boldFont} boundSize:CGSizeMake(limitWidth, CGFLOAT_MAX)].height;
    CGFloat help2ContentHeight = [self.help2ContentLabel labelSizeWithAttributes:@{NSFontAttributeName : regularFont} boundSize:CGSizeMake(limitWidth, CGFLOAT_MAX)].height;
    self.view2HeightConstraint.constant = 20 + help2TitleHeight + 8 + help2ContentHeight;
    self.view3TopConstraint.constant = self.topViewHeightConstraint.constant + self.view1HeightConstraint.constant + self.view2HeightConstraint.constant;
    
    self.help3TitleLabel.font = boldFont;
    self.help3TitleLabel.textColor = boldColor;
    self.help3ContentLabel.font = regularFont;
    self.help3ContentLabel.textColor = regularColor;
    
    CGFloat help3TitleHeight = [self.help3TitleLabel labelSizeWithAttributes:@{NSFontAttributeName : boldFont} boundSize:CGSizeMake(limitWidth, CGFLOAT_MAX)].height;
    CGFloat help3ContentHeight = [self.help3ContentLabel labelSizeWithAttributes:@{NSFontAttributeName : regularFont} boundSize:CGSizeMake(limitWidth, CGFLOAT_MAX)].height;
    self.view3HeightConstraint.constant = 20 + help3TitleHeight + 8 + help3ContentHeight;
    
    self.view4TopConstraint.constant = self.topViewHeightConstraint.constant + self.view1HeightConstraint.constant + self.view2HeightConstraint.constant + self.view3HeightConstraint.constant;
    self.help4TitleLabel.font = boldFont;
    self.help4TitleLabel.textColor = boldColor;
    self.help4ContentLabel.font = regularFont;
    self.help4ContentLabel.textColor = regularColor;
    
    CGFloat help4TitleHeight = [self.help4TitleLabel labelSizeWithAttributes:@{NSFontAttributeName : boldFont} boundSize:CGSizeMake(limitWidth, CGFLOAT_MAX)].height;
    CGFloat help4ContentHeight = [self.help4ContentLabel labelSizeWithAttributes:@{NSFontAttributeName : regularFont} boundSize:CGSizeMake(limitWidth, CGFLOAT_MAX)].height;
    self.view4HeightConstraint.constant = 20 + help4TitleHeight + 8 + help4ContentHeight;
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

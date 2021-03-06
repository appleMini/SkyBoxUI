//
//  SPOnlineViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/18.
//

#import "SPOnlineViewController.h"
#import "SPOnlineAddURLViewController.h"
#import "UILabel+SPAttri.h"

@interface SPOnlineViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyVCenterYConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noticLabel;
@property (weak, nonatomic) IBOutlet UIButton *addUrlBtn;

@end

@implementation SPOnlineViewController

- (instancetype)initWithSomething {
    self = [super initWithNibName:@"SPOnlineViewController" bundle:[Commons resourceBundle]];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.noticLabel.font = [UIFont fontWithName:@"Calibri" size:15.0];
    self.noticLabel.textColor = [SPColorUtil getHexColor:@"#e3e3e3"];
    
//    CGFloat noticLabelH = [self.noticLabel labelSizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Calibri" size:15.0]}].height;
    self.addUrlBtn.titleLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:15.0];
    [self.addUrlBtn setTitleColor:[SPColorUtil getHexColor:@"#3c3f48"] forState:UIControlStateNormal];
    self.addUrlBtn.backgroundColor = [SPColorUtil getHexColor:@"#ffde9e"];
    self.addUrlBtn.layer.cornerRadius = 18;
    self.addUrlBtn.layer.masksToBounds = YES;
//    CGFloat addUrlBtnH = [self.noticLabel labelSizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Calibri-Bold" size:15.0]}].height;
    
    
    self.emptyVCenterYConstraint.constant = [SPDeviceUtil isiPhoneX] ? -(34 + 88 + 36 + 16)/2.0 : -(84 + 36 + 16) / 2.0;
}

- (NSString *)titleOfLabelView {
    return NSLocalizedString(@"Menu_OnlineStream", @"Online Stream");
}

- (NSString *)cellIditify {
    return @"Online_Stream_CellID";
}

- (IBAction)addUrlAction:(id)sender {
    
    SPOnlineAddURLViewController *addURLVC = [[SPOnlineAddURLViewController alloc] initWithNibName:@"SPOnlineAddURLViewController" bundle:[Commons resourceBundle]];
    [self presentViewController:addURLVC animated:YES completion:nil];
}

@end

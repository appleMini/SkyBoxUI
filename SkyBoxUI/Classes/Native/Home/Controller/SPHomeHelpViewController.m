//
//  SPHomeHelpViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/22.
//

#import "SPHomeHelpViewController.h"

@interface SPHomeHelpViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *num1V;
@property (weak, nonatomic) IBOutlet UIImageView *num2V;
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgVHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgVWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgVCentYContraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewWidthConstraint;

@end

@implementation SPHomeHelpViewController

- (instancetype)initWithSomething {
    self = [super initWithNibName:@"SPHomeHelpViewController" bundle:[Commons resourceBundle]];
    if (self) {
    }
    return self;
}

- (NSString *)titleOfLabelView {
    return NSLocalizedString(@"Menu_AddVideos", @"ADD VIDEOS");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.viewWidthConstraint.constant = 275 * kWSCALE;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    self.label1.font = [UIFont fontWithName:@"Calibri" size:15];
    self.label1.textColor = [SPColorUtil getHexColor:@"#e3e3e3"];
    
    self.label2.font = [UIFont fontWithName:@"Calibri" size:15];
    self.label2.textColor = [SPColorUtil getHexColor:@"#e3e3e3"];
    
    if (currentPage == 0) {
        self.imgV.image = [Commons getImageFromResource:@"Home_help_1"];
        
        self.num1V.image = [Commons getImageFromResource:@"Home_help_number_1"];
        self.num2V.image = [Commons getImageFromResource:@"Home_help_number_2"];
        
        self.label1.text = NSLocalizedString(@"Help_num1", @"1. Connect your iPhone to  your computer using the USB cable.");
        self.label2.text = NSLocalizedString(@"Help_num2", @"2. Open iTunes and select your iPhone.");
        
        self.imgVHeightConstraint.constant = 126;
        self.imgVWidthConstraint.constant = 346;
        self.imgVCentYContraint.constant = -100;
    }else if(currentPage == 1) {
        self.imgV.image = [Commons getImageFromResource:@"Home_help_2"];
        self.num1V.image = [Commons getImageFromResource:@"Home_help_number_3"];
        self.num2V.image = [Commons getImageFromResource:@"Home_help_number_4"];
        
        self.label1.text = NSLocalizedString(@"Help_num3", @"3. In the left sidebar, click File Sharing, Select SKYBOX.");
        self.label2.text = NSLocalizedString(@"Help_num4", @"4. Click \"Add\" or drag & drop the videos to add to SKYBOX.");
        
        self.imgVHeightConstraint.constant = 242;
        self.imgVWidthConstraint.constant = 372;
        self.imgVCentYContraint.constant = -120;
    }
}
@end

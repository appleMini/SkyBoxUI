//
//  SPOnlineAddURLViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/1/9.
//

#import "SPOnlineAddURLViewController.h"
#import "SPOnlineDismissAnimationController.h"
#import "SPOnlinePresentAnimationController.h"

@interface SPOnlineAddURLViewController ()<UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewCenterYConstraint;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation SPOnlineAddURLViewController

- (CGSize)preferredContentSize
{
    CGFloat height = [SPDeviceUtil isiPhoneX] ? (SCREEN_HEIGHT -64) : (SCREEN_HEIGHT - 34 - 44);
    return CGSizeMake(SCREEN_WIDTH, height);
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
    self.view.backgroundColor = [UIColor clearColor];
    
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.clipsToBounds = YES;
    
    self.cancelBtn.layer.borderColor = [UIColor grayColor].CGColor;
    self.cancelBtn.layer.borderWidth = 0.5;
    self.addBtn.layer.borderColor = [UIColor grayColor].CGColor;
    self.addBtn.layer.borderWidth = 0.5;
    
    self.viewCenterYConstraint.constant = 0;
    //监听当键盘将要出现时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textField becomeFirstResponder];
}

//当键盘出现
- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    int height = keyboardRect.size.height;
    
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.viewCenterYConstraint.constant = self.view.frame.size.height - (height + 60 + self.contentView.frame.size.height / 2.0) - self.view.frame.size.height / 2.0;
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addURLAction:(id)sender {
    NSLog(@"self.textField.text == %@", self.textField.text);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark UIViewControllerTransitioningDelegate
- (id)animationControllerForPresentedController:(UIViewController *)presented
                           presentingController:(UIViewController *)presenting
                               sourceController:(UIViewController *)source
{
    return [[SPOnlinePresentAnimationController alloc] init];
}

- (id)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[SPOnlineDismissAnimationController alloc] init];
}
@end

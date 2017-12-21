//
//  SPBaseViewController.h
//  SkyBoxUitl
//
//  Created by Shao shuqiang on 2017/11/29.
//  Copyright © 2017年 Shao shuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define  adjustsScrollViewInsets(scrollView)\
do {\
_Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")\
if ([scrollView respondsToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {\
NSMethodSignature *signature = [UIScrollView instanceMethodSignatureForSelector:@selector(setContentInsetAdjustmentBehavior:)];\
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];\
NSInteger argument = 2;\
invocation.target = scrollView;\
invocation.selector = @selector(setContentInsetAdjustmentBehavior:);\
[invocation setArgument:&argument atIndex:2];\
[invocation retainArguments];\
[invocation invoke];\
}\
_Pragma("clang diagnostic pop")\
} while (0)


#define  UITOUNITYNOTIFICATIONNAME  @"AcrossDifferentNativeNotify_UI_UNITY"
#define  SCANOVERUITOUNITYNOTIFICATIONNAME  @"SCANOVERNativeNotify_UI_UNITY"

@interface SPBaseViewController : UIViewController

@property (nonatomic, strong) UILabel *titleLabel;

- (instancetype)initWithSomething;
- (NSString *)titleOfLabelView;
- (NSArray *)leftNaviItem;
- (NSArray *)rightNaviItem;
- (void)setupNaviView;
- (void)refresh;
@end

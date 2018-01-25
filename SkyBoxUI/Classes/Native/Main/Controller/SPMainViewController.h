//
//  SPMainViewController.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/14.
//

#import <SkyBoxUI/SkyBoxUI.h>

@protocol SPMainViewJumpDelegate;
@interface SPMainViewController : SPBaseViewController

@property (weak, nonatomic) id<SPMainViewJumpDelegate> jumpDelegate;
- (void)jumpToMiddleVC:(SPBaseViewController *)vc menuIndex:(NSInteger)index;
@end

@protocol SPMainViewJumpDelegate <NSObject>

@optional
- (void)nativeToUnity:(id)sender intoVRMode:(id)block;

@end

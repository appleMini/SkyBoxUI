//
//  MenuViewController.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import <UIKit/UIKit.h>
#import "SPBaseViewController.h"

@protocol SPMenuJumpProtocol;
@interface SPMenuViewController : SPBaseViewController

@property (weak, nonatomic) id<SPMenuJumpProtocol> delegate;
@property (assign, nonatomic) NSUInteger menuCount;

- (void)selectMenuItem:(NSInteger)index jump:(BOOL)isScroll;
@end

@protocol SPMenuJumpProtocol <NSObject>

@required
- (void)MenuViewController:(UIViewController *)menu jumpViewController:(NSString *)ctrS menuIndex:(NSInteger)index;
@end

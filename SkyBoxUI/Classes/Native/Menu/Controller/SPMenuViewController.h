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

- (void)selectMenuItem:(NSInteger)index;
@end

@protocol SPMenuJumpProtocol <NSObject>

@required
- (void)MenuViewController:(UIViewController *)menu jumpViewController:(NSString *)ctrS;
@end

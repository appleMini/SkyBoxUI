//
//  SPSwitchBar.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SPSingle.h"

@protocol SPSwitchBarProtocol;
@interface SPSwitchBar : UIView
SPSingletonH(SPSwitchBar)

@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, weak) id<SPSwitchBarProtocol> delegate;

- (void)showVRMode;
- (BOOL)isHidden;
- (void)hiddenWithAnimation;
- (void)showWithAnimation;
- (void)resetAnimation;
- (void)fixPosition:(CGFloat)x baseWidth:(CGFloat)width;
@end

@protocol SPSwitchBarProtocol <NSObject>

@required
- (void)switchBar:(SPSwitchBar *)bar selectIndex:(NSInteger)index;

@optional
- (void)switchBar:(SPSwitchBar *)bar swapGestureIndex:(NSInteger)index;
@end

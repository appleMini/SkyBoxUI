//
//  SPMainTabBarController.h
//  SkyBoxUitl
//
//  Created by Shao shuqiang on 2017/11/29.
//  Copyright © 2017年 Shao shuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SPMainJumpDelegate;

@interface SPMainTabBarController : UITabBarController

@property (weak, nonatomic) id<SPMainJumpDelegate> jumpDelegate;
@end

@protocol SPMainJumpDelegate <NSObject>

@optional
- (void)nativeToUnity:(UIViewController *)viewController selectedIndex:(NSUInteger)index;

@end

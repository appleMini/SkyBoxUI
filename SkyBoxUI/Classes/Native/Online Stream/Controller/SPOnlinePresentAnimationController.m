//
//  PresentAnimationController.m
//  UICoreLibrary
//
//  Created by 小布丁 on 2016/11/24.
//  Copyright © 2016年 小布丁. All rights reserved.
//

#import "SPOnlinePresentAnimationController.h"

@interface SPOnlinePresentAnimationController ()<UIViewControllerAnimatedTransitioning>

@end

@implementation SPOnlinePresentAnimationController

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    CGSize contentSize = toViewController.preferredContentSize;

    [containerView addSubview:toViewController.view];
    
    [toViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(contentSize.width);
        make.height.mas_equalTo(contentSize.height);
        make.center.mas_offset(0);
    }];
    
    toViewController.view.alpha = 0.0;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration animations:^{
        toViewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end

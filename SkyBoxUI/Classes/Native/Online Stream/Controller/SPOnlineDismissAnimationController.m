//
//  DismissAnimationController.m
//  UICoreLibrary
//
//  Created by 小布丁 on 2016/11/24.
//  Copyright © 2016年 小布丁. All rights reserved.
//

#import "SPOnlineDismissAnimationController.h"

@interface SPOnlineDismissAnimationController ()<UIViewControllerAnimatedTransitioning>

@end

@implementation SPOnlineDismissAnimationController

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         fromViewController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [fromViewController.view removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}

@end

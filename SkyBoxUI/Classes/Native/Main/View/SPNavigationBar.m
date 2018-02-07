//
//  SPNavigationBar.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/1/30.
//

#import "SPNavigationBar.h"

@implementation SPNavigationBar

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    frame.size.height = 64;
    self.frame = frame;
    
//    [self clear:self];
    Class navigationBarContentView = NSClassFromString(@"_UINavigationBarContentView");
    Class barBackground = NSClassFromString(@"_UIBarBackground");
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:navigationBarContentView] || [view isKindOfClass:barBackground]) {
            CGRect vframe = view.frame;
            vframe.origin.y = (self.frame.size.height - vframe.size.height) / 2;
            view.frame = vframe;
        }
    }
}

- (void)clear:(UIView *)view {
    for (UIView *v in view.subviews) {
        v.backgroundColor = [UIColor clearColor];
        v.alpha = 0.0;
        [self clear:v];
    }
}
@end

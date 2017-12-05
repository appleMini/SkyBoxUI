//
//  SPTabBar.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/5.
//

#import "SPTabBar.h"
#define WIDTH 60
#define HEIGHT 60

@interface SPTabBar()

@property (nonatomic, strong) UIButton *centerBtn;
@end

@implementation SPTabBar

- (UIButton *)centerBtn {
    if (!_centerBtn) {
        UIButton *vrBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [vrBtn setTitle:@"VR" forState:UIControlStateNormal];
        [vrBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [vrBtn setBackgroundColor:[UIColor greenColor]];
        vrBtn.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        vrBtn.layer.cornerRadius = WIDTH / 2;
        vrBtn.layer.masksToBounds = YES;
        
        [self addSubview:vrBtn];
        [self bringSubviewToFront:vrBtn];
        [self setClipsToBounds:NO];
        
        _centerBtn = vrBtn;
    }
    
    return _centerBtn;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSArray <UITabBarItem *>*items = self.items;
    if (items.count > 1) {
        
        CGFloat centerX = self.bounds.size.width / 2;
        CGFloat width = WIDTH;
        CGFloat height = HEIGHT;
        CGFloat x = centerX - WIDTH / 2;
        CGFloat y = self.bounds.size.height - height;
        
        UIButton *vrBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [vrBtn setTitle:@"VR" forState:UIControlStateNormal];
        [vrBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [vrBtn setBackgroundColor:[UIColor greenColor]];
        vrBtn.frame = CGRectMake(x, y, width, height);
        vrBtn.layer.cornerRadius = WIDTH / 2;
        vrBtn.layer.masksToBounds = YES;
        [vrBtn addTarget:self action:@selector(vrBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:vrBtn];
        [self bringSubviewToFront:vrBtn];
        [self setClipsToBounds:NO];
    }
}

//响应外部点击
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.clipsToBounds || self.hidden || (self.alpha == 0.f)) {
        return nil;
    }
    UIView *result = [super hitTest:point withEvent:event];
    // 如果事件发生在 tabbar 里面直接返回
    if (result) {
        return result;
    }
    // 这里遍历那些超出的部分就可以了，不过这么写比较通用。
    for (UIView *subview in self.subviews) {
        // 把这个坐标从tabbar的坐标系转为 subview 的坐标系
        CGPoint subPoint = [subview convertPoint:point fromView:self];
        result = [subview hitTest:subPoint withEvent:event];
        // 如果事件发生在 subView 里就返回
        if (result) {
            return result;
        }
    }
    return nil;
}

#pragma -mark VRButton
- (void)vrBtnClick:(UIButton *)sender {
    NSUInteger selectedIndex = -1;
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:nativeToUnityType],
                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex]
                             };
    
    [sender bubbleEventWithUserInfo:notify];
}

@end

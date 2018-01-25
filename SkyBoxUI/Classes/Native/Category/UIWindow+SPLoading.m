//
//  UIWindow+SPLoading.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/1/24.
//

#import "UIWindow+SPLoading.h"

@implementation UIWindow(SPLoading)

- (void)showLoading {
    UIView *view = [self viewWithTag:999999];
    if (view) {
        return;
    }
    
    CGFloat x = (self.bounds.size.width - 40) / 2;
    CGFloat y = (self.bounds.size.height - 40) / 2;
    
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
    //    imgv.backgroundColor = [UIColor redColor];
    imgv.animationImages = [self initialImageArray];
    imgv.animationDuration = 1.0f;// 序列帧全部播放完所用时间
    imgv.animationRepeatCount = MAXFLOAT;// 序列帧动画重复次数
    [imgv startAnimating];//开始动画
    
    imgv.tag = 999999;
    [self addSubview:imgv];
    [self bringSubviewToFront:imgv];
    
    self.userInteractionEnabled = NO;
}

- (void)hideLoading {
    self.userInteractionEnabled = YES;
    UIView *view = [self viewWithTag:999999];
    [view removeFromSuperview];
}

#pragma -mark private - Methods
- (NSArray *)initialImageArray {
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (int i = 1; i < 15; i++) {
        NSString *imageName = [NSString stringWithFormat:@"Home_videos_album_loading_000%02d", (i*2 + 1)];
        
        UIImage *image = [Commons getImageFromResource:imageName];
        if (image) {
            [imageArray addObject:image];
        }
    }
    
    return imageArray;
}

@end


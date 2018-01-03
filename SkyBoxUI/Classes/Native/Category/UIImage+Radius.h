//
//  UIImageView+Radius.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/14.
//

#import <UIKit/UIKit.h>

@interface UIImage(Radius)
- (UIImage *)drawRectWithRoundedCorner:(CGFloat)radius bgColor:(UIColor *)bgColor inRect:(CGRect)rect;
@end

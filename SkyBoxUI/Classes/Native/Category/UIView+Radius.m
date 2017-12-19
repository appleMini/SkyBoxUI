//
//  UIVIew+Raduis.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/11.
//

#import "UIView+Radius.h"
#import "UIImage+Radius.h"

@implementation UIView(Radius)

- (void)radius:(CGFloat)radui {
    UIImage *image = [self drawRectWithRoundedCorner:radui];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:self.bounds];
    imgV.image = image;
    [self insertSubview:imgV atIndex:0];
}

//- (UIImage *)kt_drawRectWithRoundedCorner:(CGFloat)radius borderWidth:(CGFloat)borderWidth backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor {
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, [UIScreen mainScreen].scale);
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
//    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return output;
//}

- (UIImage *)drawRectWithRoundedCorner:(CGFloat)radius {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    CGContextAddPath(ctx, path.CGPath);
    
    CGContextClip(ctx);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}
@end

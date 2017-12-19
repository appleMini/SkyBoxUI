//
//  UIImageView+Radius.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/14.
//

#import "UIImage+Radius.h"

@implementation UIImage(Radius)

- (UIImage *)drawRectWithRoundedCorner:(CGFloat)radius inRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(rect.size, false, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    CGContextAddPath(ctx, path.CGPath);
    CGContextClip(ctx);
    
    [self drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}
@end

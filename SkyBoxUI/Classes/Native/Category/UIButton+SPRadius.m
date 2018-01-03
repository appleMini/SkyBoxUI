//
//  UIButton+SPRadius.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/1/2.
//

#import "UIButton+SPRadius.h"

@implementation UIButton(SPRadius)

- (void)drawRectWithRoundedCorner:(CGFloat)radius borderWidth:(CGFloat)lineW borderColor:(UIColor *)borderColor {
    CGSize size = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, false, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    CGContextAddPath(ctx, path.CGPath);
    CGContextClip(ctx);
    
//    UIColor *bgColor = [SPColorUtil getHexColor:@"#585E69"];
//    CGContextSetFillColorWithColor(ctx, bgColor.CGColor);
    CGContextSetLineWidth(ctx, lineW);//线的宽度
    CGContextSetStrokeColorWithColor(ctx, borderColor.CGColor);
    CGContextStrokePath(ctx);
//    CGContextFillRect(ctx, rect);//绘制
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [self setImage:output forState:UIControlStateNormal];
}
@end

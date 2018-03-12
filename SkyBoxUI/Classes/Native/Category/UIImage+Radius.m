//
//  UIImageView+Radius.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/14.
//

#import "UIImage+Radius.h"

@implementation UIImage(Radius)

- (UIImage *)drawRectWithRoundedCorner:(CGFloat)radius bgColor:(UIColor *)bgColor inRect:(CGRect)rect {
    CGSize imageSize = self.size;
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetWidth(self.CGImage);
    CGFloat targetWidth = rect.size.width;
    CGFloat targetHeight = rect.size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, rect.size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        thumbnailPoint.x = (width - scaledWidth) * 0.5;
        thumbnailPoint.y = (height - scaledHeight) * 0.5;
    }
    
    CGSize scaleSize = CGSizeMake(scaledWidth, scaledHeight);
    UIGraphicsBeginImageContextWithOptions(scaleSize, false, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
//    CGRect newRect =  CGRectMake(thumbnailPoint.x, thumbnailPoint.y, width, height);
    [self drawInRect:rect];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    CGContextAddPath(ctx, path.CGPath);
    CGContextClip(ctx);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
//    UIGraphicsBeginImageContextWithOptions(rect.size, false, [UIScreen mainScreen].scale);
//    CGContextRef newCtx = UIGraphicsGetCurrentContext();
//
//    [output drawInRect:rect];
//
//    if (bgColor) {
//        CGContextSetFillColorWithColor(newCtx, bgColor.CGColor);
//        //    CGContextSetLineWidth(ctx, 3.0);//线的宽度
//        //    CGContextSetStrokeColorWithColor(ctx, bgColor.CGColor);
//        CGContextFillRect(newCtx, rect);//绘制
//    }
//
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
//    CGContextAddPath(newCtx, path.CGPath);
//    CGContextClip(newCtx);
//
//    output = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();

    return output;
}
@end

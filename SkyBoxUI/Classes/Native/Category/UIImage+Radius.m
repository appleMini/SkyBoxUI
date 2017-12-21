//
//  UIImageView+Radius.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/14.
//

#import "UIImage+Radius.h"

@implementation UIImage(Radius)

- (UIImage *)drawRectWithRoundedCorner:(CGFloat)radius inRect:(CGRect)rect {
    
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
        
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    CGContextAddPath(ctx, path.CGPath);
    CGContextClip(ctx);
    
    CGRect scaleRect = CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight);
    [self drawInRect:scaleRect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}
@end

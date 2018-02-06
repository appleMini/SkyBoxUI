//
//  UIColor+SPImage.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/2/1.
//

#import "UIColor+SPImage.h"

@implementation UIColor(SPImage)

- (UIImage*)createImageWithColor:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end

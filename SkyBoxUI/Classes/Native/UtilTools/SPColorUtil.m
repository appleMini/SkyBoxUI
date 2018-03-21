//
//  SPColorUtil.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/1.
//

#import "SPColorUtil.h"

@implementation SPColorUtil

+ (UIImage *)getHalfGradientLayerIMG:(CGFloat)height width:(CGFloat)width fromColor:(UIColor *)fromC toColor:(UIColor *)toC {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [view.layer insertSublayer:[self getHalfGradientLayer:CGRectMake(0, 0, width, height) fromColor:fromC toColor:toC] atIndex:0];
    
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//MARK: 获得渐变背景颜色
+ (UIImage *)getGradientLayerIMG:(CGFloat)height width:(CGFloat)width fromColor:(UIColor *)fromC toColor:(UIColor *)toC startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [view.layer insertSublayer:[self getGradientLayer:height width:width fromColor:fromC toColor:toC startPoint:startPoint endPoint:endPoint] atIndex:0];
    
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//MARK: 获得渐变背景颜色
+ (CAGradientLayer *)getHalfGradientLayer:(CGRect)rect fromColor:(UIColor *)fromC toColor:(UIColor *)toC {
    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
    gradient.frame = rect;
    gradient.colors = @[(__bridge id)fromC.CGColor, (__bridge id)fromC.CGColor, (__bridge id)toC.CGColor];
    gradient.locations = @[@0.0, @0.5, @1.0];
    gradient.startPoint = CGPointMake(0.0, 0.0);
    gradient.endPoint = CGPointMake(0.0, 1.0);
    
    return gradient;
}

+ (CAGradientLayer *)gradientLayer:(CGRect)rect fromColor:(UIColor *)fromC toColor:(UIColor *)toC startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
    gradient.frame = rect;
    gradient.colors = @[(__bridge id)fromC.CGColor, (__bridge id)toC.CGColor];
    gradient.startPoint = startPoint;
    gradient.endPoint = endPoint;
    
    return gradient;
}

+ (CAGradientLayer *)getGradientLayer:(CGFloat)height width:(CGFloat)width fromColor:(UIColor *)fromC toColor:(UIColor *)toC startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    CAGradientLayer *gradient = [self gradientLayer:CGRectMake(0, 0, width, height) fromColor:fromC toColor:toC startPoint:startPoint endPoint:endPoint];
    
    return gradient;
}

+ (UIColor *)getHexColor:(NSString *)hexColor {
    return [self getColor:hexColor alpha:1.0];
}

+ (UIColor *)getColor:(NSString *)hexColor alpha:(CGFloat)alpha {
        //这里是alpha传1，在colorWithHextColorString alpha 里面做了alpha修改
        return [self colorWithHextColorString:hexColor alpha:alpha];
}
    
    //支持rgb,argb
+ (UIColor *)colorWithHextColorString:(NSString *)hexColorString alpha:(CGFloat)alphaValue {
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    //排除掉 @\"
    if ([hexColorString hasPrefix:@"@\""]) {
        hexColorString = [hexColorString substringWithRange:NSMakeRange(2, hexColorString.length-3)];
    }
    
    // 如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([hexColorString hasPrefix:@"0x"] || [hexColorString hasPrefix:@"0X"]) {
        hexColorString = [hexColorString substringFromIndex:2];
    }
    
    //排除掉 #
    if ([hexColorString hasPrefix:@"#"]) {
        hexColorString = [hexColorString substringFromIndex:1];
    }
    
    if (nil != hexColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:hexColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    
    if ([hexColorString length]==8) { //如果是8位，就那其中的alpha
        alphaValue = (float)(unsigned char)(colorCode>>24)/0xff;
    }
    
//    //     NSLog(@"alpha:%f----r:%f----g:%f----b:%f",alphaValue,(float)redByte/0xff,(float)greenByte/0xff,(float)blueByte/0xff);
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:alphaValue];
    return result;
    
}

@end

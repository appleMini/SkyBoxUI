//
//  SPColorUtil.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/1.
//

#import "SPColorUtil.h"

@implementation SPColorUtil

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
    
//    NSLog(@"alpha:%f----r:%f----g:%f----b:%f",alphaValue,(float)redByte/0xff,(float)greenByte/0xff,(float)blueByte/0xff);
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:alphaValue];
    return result;
    
}

@end

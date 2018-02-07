//
//  SPColorUtil.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/1.
//

#import <Foundation/Foundation.h>

@interface SPColorUtil : NSObject

+ (UIColor *)getHexColor:(NSString *)hexColor;
+ (UIColor *)getColor:(NSString *)hexColor alpha:(CGFloat)alpha;

+ (UIImage *)getGradientLayerIMG:(CGFloat)height width:(CGFloat)width fromColor:(UIColor *)fromC toColor:(UIColor *)toC startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
+ (CAGradientLayer *)getGradientLayer:(CGFloat)height width:(CGFloat)width fromColor:(UIColor *)fromC toColor:(UIColor *)toC startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
+ (CAGradientLayer *)gradientLayer:(CGRect)rect fromColor:(UIColor *)fromC toColor:(UIColor *)toC startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
+ (UIImage *)getHalfGradientLayerIMG:(CGFloat)height width:(CGFloat)width fromColor:(UIColor *)fromC toColor:(UIColor *)toC;
@end

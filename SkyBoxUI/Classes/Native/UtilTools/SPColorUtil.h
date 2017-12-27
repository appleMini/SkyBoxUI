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
    
@end

//
//  JRTTFTool.h
//  MobileApprove
//
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface JRTTFData : NSObject

@property (nonatomic, copy) NSString * unicode;

@property (nonatomic, copy) NSString * color;

@property (nonatomic, strong) UIFont *font;

@end

@class JRTTFData;
@interface JRTTFTool : NSObject

+(BOOL)loadLocalTTF;

+(JRTTFData*)ttfAcquireData:(NSString*)ttfName;


@end

@interface UILabel(ttf)

// ttfname
+ (UILabel *)setTTfName:(NSString *)ttfname;

// 字体转成高清图片
+(UIImage*)convertViewToImageTTfName:(NSString*)ttfname;

// 字体图片颜色
+(UIImage*)convertViewToImageTTfName:(NSString*)ttfname Color:(NSString *)Color;

@end

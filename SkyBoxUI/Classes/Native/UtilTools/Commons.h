//
//  Commons.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/4.
//

#import <Foundation/Foundation.h>

//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height > [UIScreen mainScreen].bounds.size.width ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)
#define KEYWINDOW [UIApplication sharedApplication].keyWindow

#define kWSCALE 1.0*SCREEN_WIDTH/375
#define kHSCALE 1.0*SCREEN_HEIGHT/667

#pragma mark - color functions
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define randomColor RGBACOLOR(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#define SPBgColor RGBCOLOR(59, 63, 72)

//检查系统版本
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define kEventType              @"kEventTypeNotification"
#define kTopViewController      @"kTopViewControllerNotification"
#define kSelectTabBarItem       @"kSelectTabBarItemNotification"
#define kFunctionName           @"kFunctionNameNotification"
#define kParams                 @"kParamsNotification"

typedef enum : NSUInteger {
    NativeToUnityType = 1,
    AirScreenMiddleVCType,
    AirScreenResultMiddleVCType,
    HomeHelpMiddleVCType,
    LocalFileMiddleVCType,
    DeleteLoaclVideosType,
    CommonLoaclVideosType,
    DeleteHistoryType,
    CommonHistoryType,
    TestType,
} ResponderType;

@interface Commons : NSObject

+ (NSURL *)getResourceFromBundleResource:(NSString *)name extension:(NSString *)ext;
+ (NSURL *)getMovieFromResource:(NSString *)name extension:(NSString *)ext;
+ (UIImage *)getImageFromResource:(NSString *)name;
+ (UIImage *)getPdfImageFromResource:(NSString *)name;
+ (UIImage *)getPdfImageFromResource:(NSString *)name size:(CGSize)size;
+ (NSBundle *)resourceBundle;
+ (NSString *)durationText:(double)dur;
@end

//
//  JRTTFTool.m
//  MobileApprove
//
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "JRTTFTool.h"
#import <CoreText/CoreText.h>
#import "NSString+JRTTF.h"

@implementation JRTTFData




@end


@implementation JRTTFTool

+(void)load{
    [self loadLocalTTF];
}


+(BOOL)loadLocalTTF{
    NSString *ttfBundlePath = [[Commons resourceBundle] bundlePath];
    BOOL status=NO;
    
    NSURL *rootUrl = [NSURL URLWithString:ttfBundlePath];
    NSDirectoryEnumerator *itr = [[NSFileManager defaultManager] enumeratorAtURL:rootUrl
                         includingPropertiesForKeys:nil
                                            options:(NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants)
                                       errorHandler:nil];
    
    
    for (NSURL *ttfurl in itr) {
        if ([[ttfurl pathExtension] isEqualToString:@"ttf"]) {
            NSData *dynamicFontData = [NSData dataWithContentsOfURL:ttfurl];
            if (!dynamicFontData)
                return status;
            
            CFErrorRef error;
            CGDataProviderRef providerRef = CGDataProviderCreateWithCFData((CFDataRef)dynamicFontData);
            CGFontRef font = CGFontCreateWithDataProvider(providerRef);
            if (!CTFontManagerRegisterGraphicsFont(font, &error))
            {
                //如果注册失败，则不使用
                CFStringRef errorDescription = CFErrorCopyDescription(error);
                NSLog(@"Failed to load font: %@", errorDescription);
                CFRelease(errorDescription);
            }
            else
            {
                status = YES;
            }
            
            
            CFRelease(font);
            CFRelease(providerRef);
        }
    }
    
    return status;
}

+(BOOL)loadNetWorkTTF
{
    
    NSString *path = @"http://o8sz2sosj.bkt.clouddn.com//Ydsp.ttf/output.plist/output"; //下载文件地址
    NSURL *url = [NSURL URLWithString:path];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSLog(@"=====%ld",data.length);
    NSString *temp =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *filePath = [temp stringByAppendingPathComponent:@"output.plist"];
    NSLog(@"====filePath:%@",filePath);
    BOOL b = [fm createFileAtPath:filePath contents:data attributes:nil];
    
    if (b) {
        NSLog(@"====加载plist成功");
    }else{
        NSLog(@"====加载plist失败");
    }
    
    
    
    NSDictionary *fontDic=[NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:path]];
    
    
    NSLog(@"====%@",fontDic);
    BOOL status=NO;
    
    //字体文件所在路径
    NSString *URL_FONT = fontDic[@"URL_FONT"];
    
    //字体名
    NSString *fontName = fontDic[@"TTF_Name"];
    
    //下载字体
    NSData *dynamicFontData = [NSData dataWithContentsOfURL:[NSURL URLWithString:URL_FONT]];
    if (!dynamicFontData)
        return status;
    CFErrorRef error;
    CGDataProviderRef providerRef = CGDataProviderCreateWithCFData((CFDataRef)dynamicFontData);
    CGFontRef font = CGFontCreateWithDataProvider(providerRef);
    if (!CTFontManagerRegisterGraphicsFont(font, &error))
    {
        //如果注册失败，则不使用
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
    else
    {
        status=YES;
    }
    
    
    CFRelease(font);
    CFRelease(providerRef);
    return status;
}

+(JRTTFData *)ttfAcquireData:(NSString *)ttfName{
    
    JRTTFData *ttfData = [JRTTFData new];
    
    NSDictionary *fontDic=[NSDictionary dictionaryWithContentsOfFile:[[[Commons resourceBundle] bundlePath] stringByAppendingString:@"/output.plist"]];
    
    
    NSDictionary *ttfInfo = fontDic[ttfName];

    ttfData.color=ttfInfo[@"font_rgb"];
    ttfData.unicode=[ttfInfo[@"font_text"] stringByReplacingTtfCheatCodesWithUnicode];
    
    NSString *ttfFont=fontDic[@"TTF_Name"];
    NSString *ttfSize=ttfInfo[@"font_size"];
    
    ttfData.font=[UIFont fontWithName:ttfFont size:[ttfSize floatValue]];
    
    
    
    return ttfData;
}
@end



@implementation UILabel (ttf)

+(UIImage*)convertViewToImageTTfName:(NSString*)ttfname{
    
     UIView *v = [self setTTfName:ttfname];
    CGSize s = v.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v drawViewHierarchyInRect:v.bounds afterScreenUpdates:YES];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark - Private method

+(UIImage*)convertViewToImageTTfName:(NSString*)ttfname Color:(NSString *)Color{
    UIView *view = [self setTTfName:ttfname textColor:Color];
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

//+(UIImage*)convertViewToImageTTfName:(NSString*)ttfname Color:(NSString *)Color{
//    UIView *v = [self setTTfName:ttfname textColor:Color];
//    CGSize s = v.bounds.size;
//    
//      UIGraphicsBeginImageContextWithOptions(view.bounds.size,YES,0);
//    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
//    UIGraphicsBeginImageContextWithOptions(s, YES, [UIScreen mainScreen].scale);
//    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}


+ (UILabel *)setTTfName:(NSString *)ttfname
{
    JRTTFData *ttfData = [JRTTFTool ttfAcquireData:ttfname];
    UILabel *lable = [UILabel new];
    lable.text = ttfData.unicode;
    lable.textColor = [SPColorUtil getColor:ttfData.color alpha:1];
    lable.font = ttfData.font;
    [lable sizeToFit];
    return lable;
    
}

+ (UILabel *)setTTfName:(NSString *)ttfname textColor:(NSString *)textColor
{
    JRTTFData *ttfData = [JRTTFTool ttfAcquireData:ttfname];
    UILabel *lable = [UILabel new];
    lable.text = ttfData.unicode;
    lable.textColor = [SPColorUtil getColor:textColor alpha:1];
    lable.font = ttfData.font;
    [lable sizeToFit];
    return lable;
    
}

@end

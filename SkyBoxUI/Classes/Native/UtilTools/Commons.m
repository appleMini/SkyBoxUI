//
//  Commons.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "Commons.h"
#import <YHPDFImageLoader/UIImage+YHPDFIcon.h>

@implementation Commons

+ (NSURL *)getMovieFromResource:(NSString *)name extension:(NSString *)ext {
    NSURL *movieUrl = [[Commons resourceBundle] URLForResource:name withExtension:ext];
    return movieUrl;
}

+ (UIImage *)getImageFromResource:(NSString *)name {
    NSString *ext = [SPDeviceUtil isiPhoneX] ? @"@3x" : @"@2x";
    UIImage *img =  [UIImage imageWithContentsOfFile:[[Commons resourceBundle] pathForResource:[NSString stringWithFormat:@"%@%@",name, ext] ofType:@"png"]];
    return img;
}
+ (UIImage *)getPdfImageFromResource:(NSString *)name {
    NSURL *imgUrl = [[Commons resourceBundle] URLForResource:name withExtension:@"pdf"];
    return [UIImage yh_imageWithPDFFileURL:imgUrl];
}
+ (NSBundle *)resourceBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleURL = [bundle URLForResource:@"SkyBoxUI" withExtension:@"bundle"];
    NSBundle *resBundle = [NSBundle bundleWithURL: bundleURL];
    return resBundle;
}

#pragma -mark duration text
+ (NSString *)durationText:(double)dur {
    NSString *hours = @"00";
    int hour = dur / 60 / 60;
    if (hour < 10) {
        hours = [NSString stringWithFormat:@"0%d", hour];
    }else{
        hours = [NSString stringWithFormat:@"%d", hour];
    }
    
    NSString *minutes = @"00";
    int minute = (dur - hour * 3600) / 60;
    if (minute < 10) {
        minutes = [NSString stringWithFormat:@"0%d", minute];
    }else{
        minutes = [NSString stringWithFormat:@"%d", minute];
    }
    
    NSString *seconds = @"00";
    int second = dur - hour * 3600 - minute * 60;
    if (second < 10) {
        seconds = [NSString stringWithFormat:@"0%d", second];
    }else{
        seconds = [NSString stringWithFormat:@"%d", second];
    }
    return [NSString stringWithFormat:@"%@:%@:%@", hours, minutes, seconds];
}
@end

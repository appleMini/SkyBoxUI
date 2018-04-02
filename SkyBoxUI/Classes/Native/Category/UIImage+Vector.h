//
//  UIImage+Vector.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/3/26.
//

#import <UIKit/UIKit.h>

@interface UIImage(Vector)

+ (UIImage *)vectorImageWithURL:(NSURL *)fileURL size:(CGSize)size;
+ (UIImage *)vectorImageWithURL:(NSURL *)fileURL size:(CGSize)size stretch:(BOOL)stretch;
+ (UIImage *)vectorImageWithURL:(NSURL *)url size:(CGSize)size stretch:(BOOL)stretch page:(NSUInteger)page;

@end

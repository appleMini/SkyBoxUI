//
//  UIImage+Vector.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/3/26.
//

#import "UIImage+Vector.h"

@implementation UIImage(Vector)

+ (UIImage *)vectorImageWithURL:(NSURL *)fileURL size:(CGSize)size {
    // 默认保持原图宽高比
    return [self vectorImageWithURL:fileURL size:size stretch:NO];
}
+ (UIImage *)vectorImageWithURL:(NSURL *)fileURL size:(CGSize)size stretch:(BOOL)stretch {
    // PDF 文件路径
    NSAssert(fileURL, @"Vector image file path should NOT be nil");
    if (!fileURL) return nil;
    return [self vectorImageWithURL:fileURL size:size stretch:stretch page:1];
}
// url: PDF 文件 URL
// size: 所需绘制图片大小；如果需要绘制原图大小，用 CGSizeZero
// stretch: 是否拉伸；YES，拉伸图片，忽略原图宽高比；NO，保持原图宽高比
+ (UIImage *)vectorImageWithURL:(NSURL *)url size:(CGSize)size stretch:(BOOL)stretch page:(NSUInteger)page {
    
    CGFloat screenScale = UIScreen.mainScreen.scale;
    // PDF 源文件
    CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    // PDF 中的一页
    CGPDFPageRef imagePage = CGPDFDocumentGetPage(pdfRef, page);
    // PDF 这一页显示出来的 CGRect
    CGRect pdfRect = CGPDFPageGetBoxRect(imagePage, kCGPDFCropBox);
    // 传入的大小如果为零，使用 PDF 原图大小
    CGSize contextSize = (size.width <= 0 || size.height <= 0) ? pdfRect.size : size;
    // RGB 颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 位图上下文
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 contextSize.width * screenScale,
                                                 contextSize.height * screenScale,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    // 坐标缩放，增加清晰度
    CGContextScaleCTM(context, screenScale, screenScale);
    
    if (size.width > 0 && size.height > 0) {
        // 指定图片大小，需要缩放图片
        // 计算宽高缩放比
        CGFloat widthScale = size.width / pdfRect.size.width;
        CGFloat heightScale = size.height / pdfRect.size.height;
        
        if (!stretch) {
            // 保持原图宽高比，使用宽高缩放比中的最小值
            heightScale = MIN(widthScale, heightScale);
            widthScale = heightScale;
            // 坐标平移，使图片居中
            CGFloat currentRatio = size.width / size.height;
            CGFloat realRatio = pdfRect.size.width / pdfRect.size.height;
            if (currentRatio < realRatio) {
                CGContextTranslateCTM(context, 0, (size.height - size.width / realRatio) / 2);
            } else {
                CGContextTranslateCTM(context, (size.width - size.height * realRatio) / 2, 0);
            }
        }
        // 用以上宽高缩放比缩放坐标
        CGContextScaleCTM(context, widthScale, heightScale);
        
    } else {
        // 使用原图大小
        // 获取原图坐标转换矩阵，用于位图上下文
        CGAffineTransform drawingTransform = CGPDFPageGetDrawingTransform(imagePage, kCGPDFCropBox, pdfRect, 0, true);
        CGContextConcatCTM(context, drawingTransform);
    }
    // 把 PDF 中的一页绘制到位图
    CGContextDrawPDFPage(context, imagePage);
    CGPDFDocumentRelease(pdfRef);
    // 创建 UIImage
    CGImageRef image = CGBitmapContextCreateImage(context);
    UIImage *pdfImage = [[UIImage alloc] initWithCGImage:image scale:screenScale orientation:UIImageOrientationUp];
    // 释放资源
    CGImageRelease(image);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return pdfImage;
}
@end

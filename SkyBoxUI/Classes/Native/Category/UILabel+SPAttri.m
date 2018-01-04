//
//  UILabel+SPAttri.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/1/2.
//

#import "UILabel+SPAttri.h"

@implementation UILabel(SPAttri)

- (CGSize)labelSizeWithAttributeString {
    NSAttributedString *attriStr = [self attributedText];
    return [attriStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine)  context:nil].size;
}

- (CGSize)labelSizeWithAttributes:(NSDictionary<NSAttributedStringKey,id> *)attri {
    return [[self text] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine) attributes:attri context:nil].size;
    
}

- (CGSize)labelSizeWithAttributes:(NSDictionary<NSAttributedStringKey,id> *)attri boundSize:(CGSize)size {
    return [[self text] boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine) attributes:attri context:nil].size;
}
@end

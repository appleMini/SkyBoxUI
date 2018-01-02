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
@end

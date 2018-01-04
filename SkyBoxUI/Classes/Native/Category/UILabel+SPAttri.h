//
//  UILabel+SPAttri.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/1/2.
//

#import <UIKit/UIKit.h>

@interface UILabel(SPAttri)

- (CGSize)labelSizeWithAttributeString;
- (CGSize)labelSizeWithAttributes:(NSDictionary<NSAttributedStringKey,id> *)attri;
- (CGSize)labelSizeWithAttributes:(NSDictionary<NSAttributedStringKey,id> *)attri boundSize:(CGSize)size;
@end

//
//  SPButton.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/1/4.
//

#import "SPButton.h"

@interface SPButton()

//@property (nonatomic, strong) UIColor *titleNormalColor;
//@property (nonatomic, strong) UIColor *titleHighlightedColor;
//
//@property (nonatomic, strong) UIColor *bgNormalColor;
//@property (nonatomic, strong) UIColor *bgHighlightedColor;
//
//@property (nonatomic, assign) CGFloat normalAlpha;
//@property (nonatomic, assign) CGFloat highlightedAlpha;
@end

@implementation SPButton

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        _normalAlpha = 1.0;
//        _highlightedAlpha = 1.0;
//
//        _titleNormalColor = [UIColor clearColor];
//        _titleHighlightedColor = [UIColor clearColor];
//
//        _bgNormalColor = [UIColor clearColor];
//        _bgHighlightedColor = [UIColor clearColor];
//    }
//    return self;
//}
//
//- (void)setHighlighted:(BOOL)highlighted {
//    [super setHighlighted:highlighted];
//    if (highlighted) {
//        self.backgroundColor = self.bgHighlightedColor;
//    }else{
//        self.backgroundColor = self.bgNormalColor;
//    }
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -self.imageView.bounds.size.width - 2, 0, self.imageView.bounds.size.width);
    // button图片的偏移量
    self.imageEdgeInsets = UIEdgeInsetsMake(0, self.titleLabel.bounds.size.width + 2, 0, -self.titleLabel.bounds.size.width);
}
@end

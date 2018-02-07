//
//  SPHighlightedButton.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/2/6.
//

#import "SPHighlightedButton.h"

@interface SPHighlightedButton()

@end

@implementation SPHighlightedButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _normalAlpha = 1.0;
        _highlightedAlpha = 1.0;
        
        _titleNormalColor = [UIColor clearColor];
        _titleHighlightedColor = [UIColor clearColor];
        
        _bgNormalColor = [UIColor clearColor];
        _bgHighlightedColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _normalAlpha = 1.0;
        _highlightedAlpha = 1.0;
        
        _titleNormalColor = [UIColor clearColor];
        _titleHighlightedColor = [UIColor clearColor];
        
        _bgNormalColor = [UIColor clearColor];
        _bgHighlightedColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _normalAlpha = 1.0;
        _highlightedAlpha = 1.0;

        _titleNormalColor = [UIColor clearColor];
        _titleHighlightedColor = [UIColor clearColor];

        _bgNormalColor = [UIColor clearColor];
        _bgHighlightedColor = [UIColor clearColor];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.backgroundColor = self.bgHighlightedColor;
        self.titleLabel.textColor = self.titleHighlightedColor;
        self.alpha = self.highlightedAlpha;
    }else{
        self.backgroundColor = self.bgNormalColor;
        self.titleLabel.textColor = self.titleNormalColor;
        self.alpha = self.normalAlpha;
    }
}
@end

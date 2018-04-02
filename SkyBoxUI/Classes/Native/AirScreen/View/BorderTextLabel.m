//
//  BorderTextLabel.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/3/23.
//

#import "BorderTextLabel.h"

@implementation BorderTextLabel

@synthesize textBorderWidth = _textBorderWidth, textBorderColor = _textBorderColor, shadowText = _shadowText;

- (void)drawTextInRect:(CGRect)rect {
    
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, self.textBorderWidth);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = self.textBorderColor;
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 1.0);
    [super drawTextInRect:rect];
}

-(void)setShadowText:(NSString *)shadowText {
    _shadowText = shadowText;
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 1.5;
    shadow.shadowOffset = CGSizeMake(0, 0);
    shadow.shadowColor = RGBACOLOR(0, 0, 0, 0.5);
    NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithString:shadowText
                                                                        attributes:@{NSShadowAttributeName:shadow}];
    self.attributedText = attributedStr;
}

@end

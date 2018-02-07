//
//  SPHighlightedButton.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/2/6.
//

#import <Foundation/Foundation.h>

@interface SPHighlightedButton : UIButton

@property (nonatomic, strong) UIColor *titleNormalColor;
@property (nonatomic, strong) UIColor *titleHighlightedColor;

@property (nonatomic, strong) UIColor *bgNormalColor;
@property (nonatomic, strong) UIColor *bgHighlightedColor;

@property (nonatomic, assign) CGFloat normalAlpha;
@property (nonatomic, assign) CGFloat highlightedAlpha;

@end

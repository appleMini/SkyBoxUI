//
//  BorderTextLabel.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/3/23.
//

#import <UIKit/UIKit.h>

@interface BorderTextLabel : UILabel

/** 描边宽度*/

@property (nonatomic, assign) CGFloat textBorderWidth;

/** 描边颜色*/

@property (nonatomic, strong) UIColor *textBorderColor;

/** 带阴影的文字*/

@property (nonatomic, strong) NSString *shadowText;

@end

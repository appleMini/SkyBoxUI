//
//  SPButton.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/1/4.
//

#import "SPButton.h"

@interface SPButton()

@end

@implementation SPButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -self.imageView.bounds.size.width - 2, -1, self.imageView.bounds.size.width);
    // button图片的偏移量
    self.imageEdgeInsets = UIEdgeInsetsMake(0, self.titleLabel.bounds.size.width + 2, 0, -self.titleLabel.bounds.size.width);
}
@end

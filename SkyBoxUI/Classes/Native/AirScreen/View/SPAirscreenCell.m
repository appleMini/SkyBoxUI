//
//  SPAirscreenCellTableViewCell.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/2/6.
//

#import "SPAirscreenCell.h"

@implementation SPAirscreenCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    //动画高亮变色效果
    if(highlighted) {
       self.contentView.backgroundColor = [SPColorUtil getHexColor:@"#e5e5e5"];
    }else {
       self.contentView.backgroundColor = [UIColor whiteColor];
    }
}

@end

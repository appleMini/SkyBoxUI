//
//  SPVideoCell.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import <UIKit/UIKit.h>
#import "SPVideoView.h"

@interface SPVideoCell : UITableViewCell

@property (nonatomic, strong) SPVideoView *videoView;

- (void)hiddenShadow : (BOOL)isHidden;
- (void)enableLongPressGestureRecognizer:(BOOL)enable;
@end

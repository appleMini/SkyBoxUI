//
//  SPVideoView.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import <UIKit/UIKit.h>

@class SPVideo;
@protocol SPVideoViewDelegate;
@interface SPVideoView : UIView

//@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<SPVideoViewDelegate> delegate;
@property (nonatomic, assign) SPCellStatus status;
@property (nonatomic, strong) SPVideo *video;

- (void)prepareForReuse;
- (void)setHighlighted:(BOOL)highlighted;
- (void)longPressAction:(UIGestureRecognizer *)recognizer;
@end

@protocol SPVideoViewDelegate <NSObject>

@optional
- (void)SPVideoView:(SPVideoView *)videoView changeToDeleteStyle:(BOOL)state;
- (void)SPVideoView:(SPVideoView *)videoView deleteAction:(BOOL)state;
- (void)SPVideoView:(SPVideoView *)videoView favStateChanged:(BOOL)state;
@end

@interface DarkMaskButton : UIButton

@end

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

@property (nonatomic, weak) id<SPVideoViewDelegate> delegate;
@property (nonatomic, assign) SPCellStatus status;
@property (nonatomic, strong) SPVideo *video;

- (void)prepareForReuse;
- (void)setHighlighted:(BOOL)highlighted;
@end

@protocol SPVideoViewDelegate <NSObject>

@optional
- (void)SPVideoView:(SPVideo *)video changeToDeleteStyle:(BOOL)state;
- (void)SPVideoView:(SPVideo *)video deleteAction:(BOOL)state;
- (void)SPVideoView:(SPVideo *)video favStateChanged:(BOOL)state;
@end

@interface DarkMaskButton : UIButton

@end

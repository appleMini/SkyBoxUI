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
@property (nonatomic, strong) SPVideo *video;

- (void)setHighlighted:(BOOL)highlighted;
@end

@protocol SPVideoViewDelegate <NSObject>

- (void)SPVideoView:(SPVideo *)video favStateChanged:(BOOL)state;
@end

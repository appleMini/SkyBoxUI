//
//  SPVideoCollectionView.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import <UIKit/UIKit.h>

@class SPVideo;
@protocol SPVideoCollectionViewDelegate;
@interface SPVideoCollectionView : UIView

@property (nonatomic, weak) id<SPVideoCollectionViewDelegate> delegate;
@property (nonatomic, strong) SPVideo *video;

- (void)prepareForReuse;
- (void)setHighlighted:(BOOL)highlighted;
@end

@protocol SPVideoCollectionViewDelegate <NSObject>

- (void)SPVideoCollectionView:(SPVideo *)video favStateChanged:(BOOL)state;
@end

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

//@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<SPVideoCollectionViewDelegate> delegate;
@property (nonatomic, assign) SPCellStatus status;
@property (nonatomic, strong) SPVideo *video;

- (void)prepareForReuse;
- (void)setHighlighted:(BOOL)highlighted;
- (void)longPressAction:(UIGestureRecognizer *)recognizer;
@end

@protocol SPVideoCollectionViewDelegate <NSObject>

@optional
- (void)SPVideoCollectionView:(SPVideoCollectionView *)videoView changeToDeleteStyle:(BOOL)state;
- (void)SPVideoCollectionView:(SPVideoCollectionView *)videoView deleteAction:(BOOL)state;
- (void)SPVideoCollectionView:(SPVideoCollectionView *)videoView favStateChanged:(BOOL)state;
@end

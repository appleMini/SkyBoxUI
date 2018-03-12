//
//  SPVideoCollectionView.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import <UIKit/UIKit.h>

@class SPVideoCollectionView;
@interface SPVideoCollectionCell : UICollectionViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) SPVideoCollectionView *videoView;

- (void)hiddenShadow : (BOOL)isHidden;
@end

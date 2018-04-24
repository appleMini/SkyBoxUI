//
//  SPVerticalScrollCollectionView.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/4/4.
//

#import <UIKit/UIKit.h>

@interface SPVerticalScrollCollectionView : UIScrollView

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, weak, nullable) id <UICollectionViewDelegate> cDelegate;
@property (nonatomic, weak, nullable) id <UICollectionViewDataSource> dataSource;
@property (nonatomic, strong) UIView  *backgroundView;

- (NSArray<NSIndexPath *> *)indexPathsForVisibleItems;
- (void)setCollectionViewLayout:(UICollectionViewLayout *)layout;
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

- (void)reloadData;
- (void)hiddenBackgrondView:(BOOL)isHidden;
- (void)setContentOffsetZero;
@end

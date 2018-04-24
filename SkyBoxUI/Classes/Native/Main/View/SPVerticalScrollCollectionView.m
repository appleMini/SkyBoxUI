//
//  SPVerticalScrollCollectionView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/4/4.
//

#import "SPVerticalScrollCollectionView.h"
#import "TGRefresh.h"

#define TopInset 84.0
@interface SPVerticalScrollCollectionView()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewLayout *layout;
@end

@implementation SPVerticalScrollCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentSize = CGSizeMake(0, SCREEN_HEIGHT + 1.0);
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.frame = CGRectMake(0, TopInset, self.bounds.size.width, self.bounds.size.height-TopInset);
    self.collectionView.contentInset = UIEdgeInsetsMake(-TopInset, 0, 0, 0);
    CGRect frame = self.bounds;
    CGFloat y = (frame.size.height - SCREEN_HEIGHT) / 2.0;
    frame = CGRectMake(0, y, frame.size.width, frame.size.height);
    self.backgroundView.frame = frame;
    
    [self sendSubviewToBack:self.collectionView];
    UIView *refreshView = [self tgRefreshOC];
    if (refreshView) {
        [self sendSubviewToBack:refreshView];
    }
}

- (UIView *)tgRefreshOC {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[TGRefreshOC class]]) {
            return view;
        }
    }
    
    return nil;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    if ([keyPath hash] == [@"_backgroundView" hash]) {
        [self setBackgroundView:value];
    }
}

- (void)hiddenBackgrondView:(BOOL)isHidden {
    _backgroundView.hidden = isHidden;
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (!backgroundView) {
        return;
    }
    
    if (_backgroundView) {
        _backgroundView = backgroundView;
    }else {
        _backgroundView = backgroundView;
        [self insertSubview:_backgroundView atIndex:0];
    }
}

- (void)setCollectionViewLayout:(UICollectionViewLayout *)layout {
    _layout = layout;
    [self setupViews];
}

- (void)setCDelegate:(id<UICollectionViewDelegate>)cDelegate {
    self.collectionView.delegate = cDelegate;
}

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource {
    self.collectionView.dataSource = dataSource;
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)setContentOffsetZero {
}

- (NSArray<NSIndexPath *> *)indexPathsForVisibleItems {
    return self.collectionView.indexPathsForVisibleItems;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        if (!_layout) {
            return nil;
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.clipsToBounds = NO;
        _collectionView.scrollEnabled = YES;
    }
    
    return _collectionView;
}

#pragma -mark
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}
@end

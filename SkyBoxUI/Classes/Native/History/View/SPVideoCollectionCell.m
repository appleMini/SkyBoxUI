//
//  SPVideoCollectionView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "SPVideoCollectionCell.h"
#import "SPVideoCollectionView.h"

@implementation SPVideoCollectionCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupViews];
    }
    return self;
}

- (void)prepareForReuse {
    [self.videoView prepareForReuse];
}

- (void)setupViews {
    SPVideoCollectionView *itemView = (SPVideoCollectionView *)[[[UINib nibWithNibName:@"SPVideoCollectionView" bundle:[Commons resourceBundle]] instantiateWithOwner:nil options:nil] firstObject];
    itemView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:itemView];
    self.contentView.backgroundColor = [UIColor clearColor];
    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    self.videoView = itemView;
}
@end

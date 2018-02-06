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
    
    UIImageView *shadowImgV = [[UIImageView alloc] initWithFrame:CGRectZero];
    shadowImgV.contentMode = UIViewContentModeScaleAspectFill;
    shadowImgV.image = [Commons getImageFromResource:@"Home_videos_album_shadow_small@2x"];
    
//    shadowImgV.backgroundColor = [UIColor redColor];
    [self.contentView insertSubview:shadowImgV belowSubview:self.videoView];
    
    [shadowImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(-12);
        make.trailing.mas_equalTo(12);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(208 * (SCREEN_WIDTH - 17 * 3) / 2 / 324 + 14);
    }];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    //动画高亮变色效果
    [self.videoView setHighlighted:highlighted];
}
@end

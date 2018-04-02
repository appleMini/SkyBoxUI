//
//  SPVideoCollectionView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "SPVideoCollectionCell.h"
#import "SPVideoCollectionView.h"

@interface SPVideoCollectionCell()
@property (strong, nonatomic)UIImageView *shadowImgV;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;
@end

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
        
        [self.contentView addGestureRecognizer:self.longPress];
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
    shadowImgV.contentMode = UIViewContentModeScaleAspectFit;
    shadowImgV.image = [Commons getImageFromResource:@"Home_videos_album_shadow_small@2x"];
    
//    shadowImgV.backgroundColor = [UIColor redColor];
    [self.contentView insertSubview:shadowImgV belowSubview:self.videoView];
    
    _shadowImgV = shadowImgV;
    [shadowImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(-13*kWSCALE);
        make.trailing.mas_equalTo(13*kWSCALE);
        make.top.mas_equalTo(0);
        if ([SPDeviceUtil isiPhoneX]) {
            make.height.mas_equalTo(208 * (SCREEN_WIDTH - 17 * 3) / 2 / 324 + 12);
        }else {
            make.height.mas_equalTo(208 * (SCREEN_WIDTH - 17 * 3) / 2 / 324 + 12*kHSCALE);
        }
    }];
    
}

- (void)hiddenShadow : (BOOL)isHidden {
    self.shadowImgV.hidden = isHidden;
}

- (UIGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        _longPress.minimumPressDuration = 1.0;
    }
    return _longPress;
}

- (void)longPressAction:(UIGestureRecognizer *)recognizer {
    NSLog(@"longPressAction:(UIGestureRecognizer *)recognizer");
    [self.videoView longPressAction:nil];
}

- (void)enableLongPressGestureRecognizer:(BOOL)enable {
    enable ? [self.contentView addGestureRecognizer:self.longPress] : [self.contentView removeGestureRecognizer:self.longPress];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    //动画高亮变色效果
    [self.videoView setHighlighted:highlighted];
}
@end

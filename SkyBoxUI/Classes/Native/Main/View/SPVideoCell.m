//
//  SPVideoCell.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "SPVideoCell.h"

@interface SPVideoCell()

@property (nonatomic, strong) UIImageView *shadowImgV;
@end

@implementation SPVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setupViews];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupViews];
    }
    return  self;
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
    [super prepareForReuse];
    [self.videoView prepareForReuse];
}

- (void)setupViews {
    SPVideoView *videoView = (SPVideoView *)[[[UINib nibWithNibName:@"SPVideoView" bundle:[Commons resourceBundle]] instantiateWithOwner:nil options:nil] firstObject];
    
    videoView.backgroundColor = [SPColorUtil getHexColor:@"#585E69"];
    [self.contentView addSubview:videoView];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    videoView.layer.cornerRadius = 6;
    videoView.layer.masksToBounds = YES;
    
    [videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(18*kWSCALE);
        make.trailing.mas_equalTo(-18*kWSCALE);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-29);
//         make.edges.mas_equalTo(UIEdgeInsetsMake(0, 18*kWSCALE, 29, 18*kWSCALE));
    }];
    self.videoView = videoView;
    
    UIImageView *shadowImgV = [[UIImageView alloc] initWithFrame:CGRectZero];
    shadowImgV.contentMode = UIViewContentModeScaleAspectFill;
    shadowImgV.image = [Commons getImageFromResource:@"Home_videos_album_shadow@2x"];
    
    [self.contentView insertSubview:shadowImgV belowSubview:self.videoView];
    _shadowImgV = shadowImgV;
    [shadowImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-25);
//        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 16, 25, 16));
    }];
}

- (void)hiddenShadow : (BOOL)isHidden {
    self.shadowImgV.hidden = isHidden;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    //动画高亮变色效果
    [self.videoView setHighlighted:highlighted];
}

@end

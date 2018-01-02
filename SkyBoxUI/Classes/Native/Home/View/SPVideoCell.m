//
//  SPVideoCell.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "SPVideoCell.h"

@interface SPVideoCell()


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
- (void)setupViews {
    SPVideoView *videoView = (SPVideoView *)[[[UINib nibWithNibName:@"SPVideoView" bundle:[Commons resourceBundle]] instantiateWithOwner:nil options:nil] firstObject];
    
    videoView.backgroundColor = [SPColorUtil getHexColor:@"#585E69"];
    [self.contentView addSubview:videoView];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    videoView.layer.cornerRadius = 12;
    videoView.layer.masksToBounds = YES;
    
    [videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(20, 18, 20, 18));
    }];
    self.videoView = videoView;
}
@end

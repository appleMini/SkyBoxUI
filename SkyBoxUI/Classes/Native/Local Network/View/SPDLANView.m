//
//  SPDLANView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/26.
//

#import "SPDLANView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+Radius.h"
#import "UIImage+RoundedCorner.h"

@interface SPDLANView ()
@property (weak, nonatomic) IBOutlet UIImageView *iconV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconVHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *upperV;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLabelTopConstraint;

@end
@implementation SPDLANView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)prepareForReuse {
    self.upperV.image = nil;
}

- (void)setDevice:(SPCmdAddDevice *)device {
    _device = device;
    
    if (device.deviceType) {
        if([device.deviceType isEqualToString:@"Synology Inc"]){
            self.upperV.image = [Commons getImageFromResource:@"Network_folder_device_Synology"];
        }else if([device.deviceType isEqualToString:@"Sonos, Inc."]){
            self.upperV.image = [Commons getImageFromResource:@"Network_folder_device_normal"];
        }else if([device.deviceType isEqualToString:@"UMS"]){
            self.upperV.image = [Commons getImageFromResource:@"Network_folder_device_Universalmediaserver"];
        }else if([device.deviceType isEqualToString:@"Plex, Inc."]){
            self.upperV.image = [Commons getImageFromResource:@"Network_folder_device_PlexTv"];
        }else if([device.deviceType isEqualToString:@"Microsoft Corporation"]){
            self.upperV.image = [Commons getImageFromResource:@"Network_folder_device_win10"];
        }else if([device.deviceType isEqualToString:@"Emby"]){
            self.upperV.image = [Commons getImageFromResource:@"Network_folder_device_EmbyMedia"];
        }else if([device.deviceType isEqualToString:@"XBMC Foundation"]){
            self.upperV.image = [Commons getImageFromResource:@"Network_folder_device_KodiTv"];
        }else if([device.deviceType isEqualToString:@"Bubblesoft"]){
            self.upperV.image = [Commons getImageFromResource:@"Network_folder_device_BubbleUPnP"];
        }
    }else {
        
    }
    
    self.tagLabel.text = device.deviceName;
    self.tagLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:15];
    self.tagLabel.textColor = [SPColorUtil getHexColor:@"#ffffff"];
    
    CGFloat imgvHeight = 208 * (SCREEN_WIDTH - 17 * 3) / 2 / 324;
    self.iconVHeightConstraint.constant = imgvHeight;
    
    if([device.deviceType containsString:@"object.item.videoItem"]){
        self.tagLabel.textAlignment = NSTextAlignmentLeft;
        
        SPCmdVideoDevice *video = (SPCmdVideoDevice *)device;
        self.iconV.contentMode = UIViewContentModeScaleAspectFill;
        [self.iconV sd_setImageWithURL:[NSURL URLWithString:video.iconURL] placeholderImage:[Commons getImageFromResource:@"Home_videos_album_default"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image) {
                self.iconV.image = [image roundedCornerImage:5 borderSize:0];
            }
        }];

        self.durationLabelTopConstraint.constant = 8;
        self.durationLabel.hidden = NO;
        self.durationLabel.font = [UIFont fontWithName:@"Calibri-light" size:12];
        self.durationLabel.textColor = [SPColorUtil getHexColor:@"#b0b1b3"];
        self.durationLabel.textAlignment = NSTextAlignmentLeft;
        self.durationLabel.text = [Commons durationText:video.duration.doubleValue];
    }else{
        self.iconV.image = [Commons getImageFromResource:@"Network_folder"];
        self.tagLabel.textAlignment = NSTextAlignmentCenter;
        
        self.durationLabelTopConstraint.constant = 0;
        self.durationLabel.hidden = YES;
        self.durationLabel.font = [UIFont fontWithName:@"Calibri-light" size:12];
        self.durationLabel.textColor = [SPColorUtil getHexColor:@"#b0b1b3"];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    if(highlighted)
    {
        self.iconV.alpha = 0.75;
    }
    else{
        self.iconV.alpha = 1.0;
    }
}
@end

@interface SPDLANCell()

@end

@implementation SPDLANCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    //动画高亮变色效果
    //    [UIView animateWithDuration:0.3 animations:^{
    if(highlighted)
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
    else
        self.contentView.backgroundColor = [UIColor clearColor];
    //    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_dlanView prepareForReuse];
}

- (void)setupViews {
    SPDLANView *dlanView = [[[UINib nibWithNibName:@"SPDLANView" bundle:[Commons resourceBundle]] instantiateWithOwner:nil options:nil] firstObject];
    
    [self addSubview:dlanView];
    _dlanView = dlanView;
    [dlanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

@end

@interface SPDLANCollectionCell()

@end
@implementation SPDLANCollectionCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_dlanView prepareForReuse];
}

- (void)setupViews {
    SPDLANView *dlanView = [[[UINib nibWithNibName:@"SPDLANView" bundle:[Commons resourceBundle]] instantiateWithOwner:nil options:nil] firstObject];
    
    dlanView.backgroundColor = [UIColor clearColor];
    [self addSubview:dlanView];
    _dlanView = dlanView;
    [dlanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    UIImageView *shadowImgV = [[UIImageView alloc] initWithFrame:CGRectZero];
    shadowImgV.contentMode = UIViewContentModeScaleAspectFill;
    shadowImgV.image = [Commons getImageFromResource:@"Home_videos_album_shadow_small@2x"];
    
    //    shadowImgV.backgroundColor = [UIColor redColor];
    [self.contentView insertSubview:shadowImgV belowSubview:self.dlanView];
    
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
    [self.dlanView setHighlighted:highlighted];
}
@end


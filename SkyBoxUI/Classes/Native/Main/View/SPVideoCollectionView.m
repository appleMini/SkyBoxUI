//
//  SPVideoCollectionView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "SPVideoCollectionView.h"
#import "SPVideo.h"
#import "UIImage+Radius.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UILabel+SPAttri.h"

@interface SPVideoCollectionView()
@property (weak, nonatomic) IBOutlet UIImageView *imgv;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgvHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *favBtn;

@end

@implementation SPVideoCollectionView

- (void)awakeFromNib {
    [super awakeFromNib];
    
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.userInteractionEnabled = YES;//打开用户交互
        //初始化一个手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
        //为图片添加手势
        [self addGestureRecognizer:singleTap];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;//打开用户交互
        //初始化一个手势
        UIGestureRecognizer *singleTap = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
        //为图片添加手势
        [self addGestureRecognizer:singleTap];
    }
    return self;
}
- (void)prepareForReuse {
    self.durationLabel.text = nil;
    self.label.text = nil;
    self.imgv.image = nil;
}

- (void)setVideo:(SPVideo *)video {
    _video = video;
    self.imgvHeightConstraint.constant = 208 * (SCREEN_WIDTH - 17 * 3) / 2 / 324;
    if (video.thumbnail_uri && ![video.thumbnail_uri hasPrefix:@"file://"] && ![video.thumbnail_uri hasPrefix:@"http://"] && ![video.thumbnail_uri hasPrefix:@"https://"]) {
        video.thumbnail_uri = [NSString stringWithFormat:@"file://%@", video.thumbnail_uri];
    }
    [self.imgv sd_setImageWithURL:[NSURL URLWithString:video.thumbnail_uri] placeholderImage:[Commons getPdfImageFromResource:@"Home_videos_album_none_small"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            self.imgv.image = [image drawRectWithRoundedCorner:10 bgColor:[SPColorUtil getHexColor:@"#585E69"] inRect:self.imgv.bounds];
        }else{
            self.imgv.image = [[Commons getImageFromResource:@"Home_videos_album_default"] drawRectWithRoundedCorner:10 bgColor:[SPColorUtil getHexColor:@"#585E69"] inRect:self.imgv.bounds];
        }
    }];
    
    self.label.font = [UIFont fontWithName:@"Calibri-Bold" size:15];
    self.label.textColor = [SPColorUtil getHexColor:@"#ffffff"];
    self.label.text = video.title;
    
    self.durationLabel.font = [UIFont fontWithName:@"Calibri-light" size:12];
    self.durationLabel.textColor = [SPColorUtil getHexColor:@"#b0b1b3"];
    self.durationLabel.text = [Commons durationText:video.duration.doubleValue];
    
    if (video.isFavourite) {
        self.favBtn.selected = YES;
        [self.favBtn setImage:[Commons getPdfImageFromResource:@"Channels_icon_favorites_active"] forState:UIControlStateNormal];
    }else{
        self.favBtn.selected = NO;
        [self.favBtn setImage:[Commons getPdfImageFromResource:@"Channels_icon_favorites"] forState:UIControlStateNormal];
    }
}

- (void)singleTapAction:(UIGestureRecognizer *)recognizer {
    NSUInteger selectedIndex = -1;
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:NativeToUnityType],
                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex]
                             };
    
    [self bubbleEventWithUserInfo:notify];
}

- (IBAction)favAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self.favBtn setImage:[Commons getPdfImageFromResource:@"Channels_icon_favorites_active"] forState:UIControlStateNormal];
    }else{
        [self.favBtn setImage:[Commons getPdfImageFromResource:@"Channels_icon_favorites"] forState:UIControlStateNormal];
    }
    
    self.video.isFavourite = sender.selected;
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"SetFavAction", @"video" : [self.video mj_JSONString]}];
}

@end

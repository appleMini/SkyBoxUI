//
//  SPVideoView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "SPVideoView.h"
#import "SPVideo.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SPVideoView()

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imgv;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *durationLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *favButton;
@property (strong, nonatomic) UIGestureRecognizer *singleTap;

@end

@implementation SPVideoView

- (void)setVideo:(SPVideo *)video {
    _video = video;
    if (video.thumbnail_uri && ![video.thumbnail_uri hasPrefix:@"file://"] && ![video.thumbnail_uri hasPrefix:@"http://"] && ![video.thumbnail_uri hasPrefix:@"https://"]) {
        video.thumbnail_uri = [NSString stringWithFormat:@"file://%@", video.thumbnail_uri];
    }
    [self.imgv sd_setImageWithURL:[NSURL URLWithString:video.thumbnail_uri] placeholderImage:[Commons getPdfImageFromResource:@"Home_videos_album_none"] options:SDWebImageRetryFailed];
    
    self.imgv.userInteractionEnabled = YES;
    //为图片添加手势
    [self.imgv addGestureRecognizer:self.singleTap];
    
    
    self.titleLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:15];
    self.titleLabel.textColor = [SPColorUtil getHexColor:@"#262629"];
    self.titleLabel.text = video.title;
    self.durationLabel.font = [UIFont fontWithName:@"Calibri" size:12];
    self.durationLabel.textColor = [SPColorUtil getHexColor:@"#a4a4a4"];
    self.durationLabel.text = [Commons durationText:video.duration.doubleValue];
    
    if (video.isFavourite) {
        self.favButton.selected = YES;
        [self.favButton setImage:[Commons getPdfImageFromResource:@"Channels_icon_favorites_active"] forState:UIControlStateNormal];
    }else{
        self.favButton.selected = NO;
        [self.favButton setImage:[Commons getPdfImageFromResource:@"Channels_icon_favorites"] forState:UIControlStateNormal];
    }
}

-(UIGestureRecognizer *)singleTap {
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    }
    
    return _singleTap;
}
- (IBAction)favAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self.favButton setImage:[Commons getPdfImageFromResource:@"Channels_icon_favorites_active"] forState:UIControlStateNormal];
    }else{
        [self.favButton setImage:[Commons getPdfImageFromResource:@"Channels_icon_favorites"] forState:UIControlStateNormal];
    }
    
    self.video.isFavourite = sender.selected;
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"SetFavAction", @"video" : [self.video mj_JSONString]}];
}

- (void)singleTapAction:(UIGestureRecognizer *)recognizer {
    NSUInteger selectedIndex = -1;
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:NativeToUnityType],
                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex]
                             };
    
    [self.imgv bubbleEventWithUserInfo:notify];
}
@end

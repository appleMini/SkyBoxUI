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

@end

@implementation SPVideoView

- (void)setVideo:(SPVideo *)video {
    _video = video;
    if (video.thumbnail_uri && ![video.thumbnail_uri hasPrefix:@"file://"]) {
        video.thumbnail_uri = [NSString stringWithFormat:@"file://%@", video.thumbnail_uri];
    }
    [self.imgv sd_setImageWithURL:[NSURL URLWithString:video.thumbnail_uri] placeholderImage:[UIImage imageNamed:@"movie"] options:SDWebImageRetryFailed];
    self.titleLabel.text = video.title;
    self.durationLabel.text = [Commons durationText:video.duration.doubleValue];
}

@end
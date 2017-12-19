//
//  SPVideoCollectionView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "SPVideoCollectionView.h"
#import "SPVideo.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SPVideoCollectionView()
@property (weak, nonatomic) IBOutlet UIImageView *imgv;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@end

@implementation SPVideoCollectionView

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setVideo:(SPVideo *)video {
    _video = video;
    [self.imgv sd_setImageWithURL:[NSURL URLWithString:video.imgurl]];
    self.imgv.layer.cornerRadius = 10;
    self.imgv.layer.masksToBounds = YES;
    
    self.label.text = video.title;
    self.durationLabel.text = [Commons durationText:video.duration];
}
@end

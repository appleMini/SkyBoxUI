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

@interface SPVideoCollectionView()
@property (weak, nonatomic) IBOutlet UIImageView *imgv;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

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
    if (video.thumbnail_uri && ![video.thumbnail_uri hasPrefix:@"file://"]) {
        video.thumbnail_uri = [NSString stringWithFormat:@"file://%@", video.thumbnail_uri];
    }
    [self.imgv sd_setImageWithURL:[NSURL URLWithString:video.thumbnail_uri] placeholderImage:[Commons getImageFromResource:@"movie@2x"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            self.imgv.image = [image drawRectWithRoundedCorner:10 inRect:self.imgv.bounds];
        }else{
            self.imgv.image = [[Commons getImageFromResource:@"movie@2x"] drawRectWithRoundedCorner:10 inRect:self.imgv.bounds];
        }
    }];
    
    self.label.text = video.title;
    self.durationLabel.text = [Commons durationText:video.duration.doubleValue];
}

- (void)singleTapAction:(UIGestureRecognizer *)recognizer {
    NSUInteger selectedIndex = -1;
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:NativeToUnityType],
                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex]
                             };
    
    [self bubbleEventWithUserInfo:notify];
}
@end

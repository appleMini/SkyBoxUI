//
//  SPVideoCollectionView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "SPVideoCollectionView.h"
#import "SPVideo.h"
#import "UIImage+Resize.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UILabel+SPAttri.h"

@interface SPVideoCollectionView()
@property (weak, nonatomic) IBOutlet UIImageView *imgv;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgvHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *favBtn;
@property (weak, nonatomic) IBOutlet UIImageView *deleteV;

@property (strong, nonatomic) UIView *darkView;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;

@end

@implementation SPVideoCollectionView

- (void)awakeFromNib {
    [super awakeFromNib];
    _status = CommomStatus;
    _deleteV.hidden = YES;
    
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

- (void)removeDarkView {
    _darkView.hidden = YES;
}

- (UIView *)darkView {
    if (!_darkView) {
        _darkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 162.5, 104)];
        _darkView.backgroundColor = [UIColor blackColor];
        _darkView.layer.cornerRadius = 5.0;
        _darkView.layer.masksToBounds = YES;
        _darkView.clipsToBounds = YES;
        [self insertSubview:_darkView aboveSubview:self.imgv];
        [_darkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.imgv.mas_width);
            make.height.mas_equalTo(self.imgv.mas_height);
            make.top.mas_equalTo(self.imgv.mas_top);
            make.left.mas_equalTo(self.imgv.mas_left);
        }];
    }
    
    _darkView.hidden = NO;
    return _darkView;
}

- (void)setVideo:(SPVideo *)video {
    _video = video;
    
    self.imgvHeightConstraint.constant = 1.0 * 208 * (SCREEN_WIDTH - 17 * 3) / 2 / 324;
    if (video.thumbnail_uri && ![video.thumbnail_uri hasPrefix:@"file://"] && ![video.thumbnail_uri hasPrefix:@"http://"] && ![video.thumbnail_uri hasPrefix:@"https://"]) {
        video.thumbnail_uri = [NSString stringWithFormat:@"file://%@", video.thumbnail_uri];
    }
    
    self.imgv.contentMode = UIViewContentModeScaleAspectFill;
    CGFloat imgvWidth = (SCREEN_WIDTH - 17 * 3) / 2;
    CGFloat imgvHeight = self.imgvHeightConstraint.constant;
//    UIImage *cornerRadiusImage = [[Commons getImageFromResource:@"Home_videos_album_default"] thumbnailImageWithCornerRadius:imgvWidth thumbnailHeight:imgvHeight transparentBorder:0 cornerRadius:5 interpolationQuality:kCGInterpolationHigh];
    
//    [self.imgv sd_setImageWithURL:[NSURL URLWithString:video.thumbnail_uri] placeholderImage:cornerRadiusImage options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        if (image) {
//            self.imgv.image = [image thumbnailImageWithCornerRadius:imgvWidth thumbnailHeight:imgvHeight transparentBorder:0 cornerRadius:5 interpolationQuality:kCGInterpolationHigh];
//        }
//    }];
    
    [self.imgv sd_setImageWithURL:[NSURL URLWithString:video.thumbnail_uri] placeholderImage:[Commons getImageFromResource:@"Home_videos_album_default"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
    }];
    
    self.imgv.layer.cornerRadius = 5.0;
    self.imgv.layer.masksToBounds = YES;
    self.imgv.clipsToBounds = YES;
//    self.imgv.layer.shouldRasterize = YES;
//    self.imgv.layer.allowsEdgeAntialiasing = YES;

    self.label.font = [UIFont fontWithName:@"Calibri-Bold" size:15];
    self.label.textColor = [SPColorUtil getHexColor:@"#ffffff"];
    self.label.text = video.title;
    
    self.durationLabel.font = [UIFont fontWithName:@"Calibri-light" size:12];
    self.durationLabel.textColor = [SPColorUtil getHexColor:@"#b0b1b3"];
    self.durationLabel.text = [Commons durationText:video.duration.doubleValue];
    
    if (_status == CommomStatus && (video.dataSource == LocalFilesType || video.dataSource == VRVideosType || video.dataSource == FavoriteVideosType)) {
        self.favBtn.hidden = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                _deleteV.alpha = 0.0;
            } completion:^(BOOL finished) {
                _deleteV.hidden = YES;
            }];
        });
        [self removeDarkView];
        
        if (video.isFavourite) {
            self.favBtn.selected = YES;
            [self.favBtn setImage:[Commons getImageFromResource:@"Channels_icon_favorites_active"] forState:UIControlStateNormal];
        }else{
            self.favBtn.selected = NO;
            [self.favBtn setImage:[Commons getImageFromResource:@"Channels_icon_favorites"] forState:UIControlStateNormal];
        }
    }else {
        self.favBtn.hidden = YES;
        if (_status == DeleteStatus) {
            _deleteV.hidden = NO;
            _deleteV.alpha = 0.0;
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^{
                    _deleteV.alpha = 1.0;
                }];
            });
            
            [self bringSubviewToFront:_deleteV];
            
            if (_video.isDelete) {
                self.darkView.alpha = 0.4;
                _deleteV.image = [Commons getImageFromResource:@"Home_videos_selected"];
            }else {
                self.darkView.alpha = 0.2;
                _deleteV.image = [Commons getImageFromResource:@"Home_videos_unselect"];
            }
        }else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^{
                    _deleteV.alpha = 0.0;
                } completion:^(BOOL finished) {
                    _deleteV.hidden = YES;
                }];
            });
            
            [self removeDarkView];
        }
    }
    
    if ([video.type isEqualToString:@"Airscreen"] && ([video.remote_id hash] != [[SPDataManager shareSPDataManager].airscreen.computerId hash])) {
        self.alpha = 0.4;
        self.durationLabel.text = @"Disconnected";
    }else {
        self.alpha = 1.0;
    }
    
    if (_status == CommomStatus && (video.dataSource == LocalFilesType || video.dataSource == VRVideosType || video.dataSource == HistoryVideosType)) {
        self.imgv.userInteractionEnabled = YES;
//        [self.imgv addGestureRecognizer:self.longPress];
    }else {
//        [self.imgv removeGestureRecognizer:self.longPress];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    if(highlighted)
    {
        self.darkView.alpha = 0.2;
    }
    else{
        self.darkView.alpha = (_status == CommomStatus) ? 0.0 : (self.video.isDelete ? 0.4 : 0.2);
    }
}

- (void)longPressAction:(UIGestureRecognizer *)recognizer {
    //if (self.delegate && [self.delegate respondsToSelector:@selector(SPVideoCollectionView: changeToDeleteStyle:)])
    if (self.delegate) {
        self.darkView.alpha = 0.4;
        [self.delegate SPVideoCollectionView:self changeToDeleteStyle:YES];
    }
}

- (UIGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        _longPress.minimumPressDuration = 1.0;
    }
    return _longPress;
}

- (void)singleTapAction:(UIGestureRecognizer *)recognizer {
    if (_status == DeleteStatus) {
        _video.isDelete = !_video.isDelete;
        if (_video.isDelete) {
            self.darkView.alpha = 0.4;
            _deleteV.image = [Commons getImageFromResource:@"Home_videos_selected"];
        }else {
            self.darkView.alpha = 0.2;
            _deleteV.image = [Commons getImageFromResource:@"Home_videos_unselect"];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(SPVideoCollectionView: deleteAction:)]) {
            [self.delegate SPVideoCollectionView:self deleteAction:_video.isDelete];
        }
        return;
    }
    
    NSUInteger selectedIndex = -1;
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:NativeToUnityType],
                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex],
                             @"path" : self.video.path
                             };
    
    [self bubbleEventWithUserInfo:notify];
}

- (IBAction)favAction:(UIButton *)sender {
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleLight];
        [generator prepare];
        [generator impactOccurred];
    } else {
        // Fallback on earlier versions
        //        AudioServicesPlaySystemSoundWithCompletion((1519), ^{
        //        });
    }
    
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self.favBtn setImage:[Commons getImageFromResource:@"Channels_icon_favorites_active"] forState:UIControlStateNormal];
    }else{
        [self.favBtn setImage:[Commons getImageFromResource:@"Channels_icon_favorites"] forState:UIControlStateNormal];
    }
    
    self.video.isFavourite = sender.selected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(SPVideoCollectionView:favStateChanged:)]) {
        [self.delegate SPVideoCollectionView:self favStateChanged:sender.selected];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"SetFavAction", @"video" : [self.video mj_JSONString]}];
}

@end

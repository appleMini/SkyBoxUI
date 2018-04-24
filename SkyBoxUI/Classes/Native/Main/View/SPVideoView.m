//
//  SPVideoView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "SPVideoView.h"
#import "SPVideo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+Resize.h"

@interface SPVideoView()

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imgv;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelMaxWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgvHeightConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *durationLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *favButton;
@property (strong, nonatomic) UIGestureRecognizer *singleTap;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *deleteV;

@property (strong, nonatomic) UIButton *darkView;

@end

@implementation SPVideoView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _titleLabelMaxWidthConstraint.constant = 1.0 * 280 * kWSCALE;
    
    if ([SPDeviceUtil isiPhoneX]) {
        _imgvHeightConstraint.constant = 1.0 * 155;
    }else {
        _imgvHeightConstraint.constant = 1.0 * 155 *kHSCALE;
    }
    
    _status = CommomStatus;
    _deleteV.hidden = YES;
}

- (void)prepareForReuse {
    self.imgv.image = nil;
    self.favButton.hidden = YES;
    _deleteV.hidden = YES;
    self.titleLabel.text = nil;
    self.durationLabel.text = nil;
}

- (void)removeDarkView {
    _darkView.hidden = YES;
}

- (UIView *)darkView {
    if (!_darkView) {
        _darkView = [[DarkMaskButton alloc] initWithFrame:self.imgv.frame];
        _darkView.backgroundColor = [UIColor blackColor];
        _darkView.layer.cornerRadius = 5.0;
        _darkView.layer.masksToBounds = YES;
        _darkView.clipsToBounds = YES;
        [_darkView addTarget:self action:@selector(singleTapAction:) forControlEvents:UIControlEventTouchUpInside];
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
    if (video.thumbnail_uri && ![video.thumbnail_uri hasPrefix:@"file://"] && ![video.thumbnail_uri hasPrefix:@"http://"] && ![video.thumbnail_uri hasPrefix:@"https://"]) {
        video.thumbnail_uri = [NSString stringWithFormat:@"file://%@", video.thumbnail_uri];
    }
    
    self.imgv.clipsToBounds = YES;
    self.imgv.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *placeholderImage = [Commons getImageFromResource:@"Home_videos_album_list_default"];
    
    CGSize newsize = CGSizeMake(SCREEN_WIDTH - 36 * kWSCALE, _imgvHeightConstraint.constant);
    placeholderImage = [placeholderImage resizeImageWithModeCenter:newsize imageSize:CGSizeMake(43 , 48) bgFillColor:[UIColor clearColor]];
    [self.imgv sd_setImageWithURL:[NSURL URLWithString:video.thumbnail_uri] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
//    UIImage *img = [UIImage imageWithContentsOfFile:[[NSURL URLWithString:video.thumbnail_uri] path]];
//    if (img) {
//        self.imgv.image = img;
//    }else {
//        self.imgv.image = placeholderImage;
//    }
    
    
    self.imgv.userInteractionEnabled = YES;
    //为图片添加手势

    [self.imgv addGestureRecognizer:self.singleTap];

    
    self.titleLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:15];
    self.titleLabel.textColor = [SPColorUtil getHexColor:@"#262629"];
    self.titleLabel.text = video.title;
    self.durationLabel.font = [UIFont fontWithName:@"Calibri" size:12];
    self.durationLabel.textColor = [SPColorUtil getHexColor:@"#a4a4a4"];
    self.durationLabel.text = [Commons durationText:video.duration.doubleValue];
    
    if (_status == CommomStatus && (video.dataSource == LocalFilesType || video.dataSource == VRVideosType || video.dataSource == FavoriteVideosType)) {
        self.favButton.hidden = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                _deleteV.alpha = 0.0;
            } completion:^(BOOL finished) {
                _deleteV.hidden = YES;
            }];
        });
        
        [self removeDarkView];
        
        if (video.isFavourite) {
            self.favButton.selected = YES;
            [self.favButton setImage:[Commons getImageFromResource:@"Channels_icon_favorites_active"] forState:UIControlStateNormal];
        }else{
            self.favButton.selected = NO;
            [self.favButton setImage:[Commons getImageFromResource:@"Channels_icon_favorites"] forState:UIControlStateNormal];
        }
    }else {
        self.favButton.hidden = YES;
        
        if (_status == DeleteStatus) {
            _deleteV.hidden = NO;
            [self bringSubviewToFront:_deleteV];
            _deleteV.alpha = 0.0;
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^{
                    _deleteV.alpha = 1.0;
                }];
            });
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
    
    if (_video.dataSource == HistoryVideosType && [video.type isEqualToString:@"Airscreen"] && ([video.remote_id hash] != [[SPDataManager shareSPDataManager].airscreen.computerId hash])) {
        self.alpha = 0.4;
        self.durationLabel.text = @"Disconnected";
    }else {
        self.alpha = 1.0;
    }
    
    if (_status == CommomStatus && (video.dataSource == LocalFilesType || video.dataSource == VRVideosType || video.dataSource == HistoryVideosType)) {
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
        self.darkView.alpha = (_status == CommomStatus) ? 0.0 : 0.4;
    }
}

- (UIGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        _longPress.minimumPressDuration = 1.0;
    }
    
    return _longPress;
}
-(UIGestureRecognizer *)singleTap {
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    }
    
    return _singleTap;
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
        [self.favButton setImage:[Commons getImageFromResource:@"Channels_icon_favorites_active"] forState:UIControlStateNormal];
    }else{
        [self.favButton setImage:[Commons getImageFromResource:@"Channels_icon_favorites"] forState:UIControlStateNormal];
    }
    
    self.video.isFavourite = sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(SPVideoView:favStateChanged:)]) {
        [self.delegate SPVideoView:self favStateChanged:sender.selected];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"SetFavAction", @"video" : [self.video mj_JSONString]}];
}

- (void)singleTapAction:(UIGestureRecognizer *)recognizer {
    if (_status == DeleteStatus) {
        _video.isDelete = !_video.isDelete;
        if (_video.isDelete) {
            self.darkView.selected = YES;
            self.darkView.alpha = 0.4;
            _deleteV.image = [Commons getImageFromResource:@"Home_videos_selected"];
        }else {
            self.darkView.selected = NO;
            self.darkView.alpha = 0.2;
            _deleteV.image = [Commons getImageFromResource:@"Home_videos_unselect"];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(SPVideoView: deleteAction:)]) {
            [self.delegate SPVideoView:self deleteAction:_video.isDelete];
        }
        return;
    }
    
    NSUInteger selectedIndex = -1;
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:NativeToUnityType],
                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex],
                             @"path" : self.video.path,
                             @"mediaType" : self.video.type
                             };
    
    [self.imgv bubbleEventWithUserInfo:notify];
}

- (void)longPressAction:(UIGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(SPVideoView: changeToDeleteStyle:)]) {
        _video.isDelete = YES;
        self.darkView.selected = YES;
        self.darkView.alpha = 0.4;
        [self.delegate SPVideoView:self changeToDeleteStyle:YES];
    }
}
@end

@interface DarkMaskButton()
@end
@implementation DarkMaskButton

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if(highlighted)
    {
        self.alpha = 0.4;
    }
    else{
        self.alpha = self.selected ? 0.4 : 0.2;
    }
}

@end

//
//  SPBackgrondView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/1/8.
//

#import "SPBackgrondView.h"

@interface SPBackgrondView()

@property (nonatomic, assign) SPBackgroundType type;
@property (weak, nonatomic) IBOutlet UIImageView *iconV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconVHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconVWidthConstraint;

@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@end

@implementation SPBackgrondView

- (instancetype)initWithFrame:(CGRect)frame backgroundType:(SPBackgroundType)type {
    self =  [[[UINib nibWithNibName:@"SPBackgrondView" bundle:[Commons resourceBundle]] instantiateWithOwner:nil options:nil] firstObject];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        _type = type;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.noticeLabel.font = [UIFont fontWithName:@"Calibri" size:15];
    self.noticeLabel.textColor = [SPColorUtil getHexColor:@"#6a6c75"];
    switch (_type) {
        case NoVideos:
        {
            self.iconV.image = [Commons getPdfImageFromResource:@"Empty_icon_VRvideos"];
            self.iconVWidthConstraint.constant = 104;
            self.iconVHeightConstraint.constant = 78;
            self.noticeLabel.text = @"NO VR VIDEOS";
        }
            break;
        case NoWifi:
        {
            self.iconV.image = [Commons getPdfImageFromResource:@"Empty_icon_connection"];
            self.iconVWidthConstraint.constant = 158;
            self.iconVHeightConstraint.constant = 118;
            self.noticeLabel.text = @"NO CONNECTIONS";
        }
            break;
        case NoFiles:
        {
            self.iconV.image = [Commons getPdfImageFromResource:@"Empty_icon_file"];
            self.iconVWidthConstraint.constant = 170;
            self.iconVHeightConstraint.constant = 116;
            self.noticeLabel.text = @"NO FILES";
        }
            break;
        case NoHistory:
        {
            self.iconV.image = [Commons getPdfImageFromResource:@"Empty_icon_history"];
            self.iconVWidthConstraint.constant = 150;
            self.iconVHeightConstraint.constant = 150;
            self.noticeLabel.text = @"NO HISTORY";
        }
            break;
        case NoFavorite:
        {
            self.iconV.image = [Commons getPdfImageFromResource:@"Empty_icon_favorite"];
            self.iconVWidthConstraint.constant = 166;
            self.iconVHeightConstraint.constant = 139;
            self.noticeLabel.text = @"NO FAVORITES";
        }
            break;
        case NoLocalMediaServers:
        {
            self.iconV.image = [Commons getPdfImageFromResource:@"Empty_icon_server"];
            self.iconVWidthConstraint.constant = 150;
            self.iconVHeightConstraint.constant = 125;
            self.noticeLabel.text = @"NO LOCAL MEDIA SERVERS";
        }
            break;
        default:
            break;
    }
}
@end

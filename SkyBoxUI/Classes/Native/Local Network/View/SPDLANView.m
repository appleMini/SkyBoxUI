//
//  SPDLANView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/26.
//

#import "SPDLANView.h"
#import <SDWebImage/UIImageView+WebCache.h>

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

- (void)setDevice:(SPCmdAddDevice *)device {
    _device = device;
    
    if (device.deviceType) {
        NSLog(@"device.deviceType  =====  %@", device.deviceType);
    }else {
        self.upperV.image = [Commons getImageFromResource:@"Network_folder_device_Universalmediaserver"];
        self.iconV.image = [Commons getImageFromResource:@"Network_folder"];
    }
    
    self.tagLabel.text = device.deviceName;
    self.tagLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:15];
    self.tagLabel.textColor = [SPColorUtil getHexColor:@"#ffffff"];
    
    CGFloat imgvHeight = 208 * (SCREEN_WIDTH - 17 * 3) / 2 / 324;
    self.iconVHeightConstraint.constant = imgvHeight;
    self.durationLabelTopConstraint.constant = 0;
    self.durationLabel.hidden = YES;
    self.durationLabel.font = [UIFont fontWithName:@"Calibri-light" size:12];
    self.durationLabel.textColor = [SPColorUtil getHexColor:@"#b0b1b3"];
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

- (void)setupViews {
    SPDLANView *dlanView = [[[UINib nibWithNibName:@"SPDLANView" bundle:[Commons resourceBundle]] instantiateWithOwner:nil options:nil] firstObject];
    
    dlanView.backgroundColor = [UIColor clearColor];
    [self addSubview:dlanView];
    _dlanView = dlanView;
    [dlanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}
@end


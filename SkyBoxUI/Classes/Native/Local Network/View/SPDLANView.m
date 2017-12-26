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
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;

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
    [self.iconV sd_setImageWithURL:[NSURL URLWithString:device.iconURL]];
    self.tagLabel.text = device.deviceName;
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
    
    [self addSubview:dlanView];
    _dlanView = dlanView;
    [dlanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}
@end


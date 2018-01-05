//
//  SPHeaderView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/26.
//

#import "SPHeaderView.h"
#import "SPDLANManager.h"

@interface SPHeaderView()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *homeBtn;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;

@property (nonatomic, strong) NSMutableArray <SPCmdAddDevice *>*devices;

@end

@implementation SPHeaderView

- (instancetype)init
{
    self = [[[UINib nibWithNibName:@"SPHeaderView" bundle:[Commons resourceBundle]] instantiateWithOwner:nil options:nil] firstObject];
    if (self) {
        _devices = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [SPColorUtil getHexColor:@"#474a54"];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    [self.homeBtn setBackgroundImage:[Commons getPdfImageFromResource:@"Network_navigator_home_bg"] forState:UIControlStateNormal];
    [self.homeBtn setImage:[Commons getPdfImageFromResource:@"Network_navigator_home"] forState:UIControlStateNormal];
    self.homeBtn.backgroundColor = [UIColor clearColor];
    
    [self.refreshBtn setImage:[Commons getPdfImageFromResource:@"Network_navigator_refresh"] forState:UIControlStateNormal];
    self.refreshBtn.backgroundColor = [UIColor clearColor];
    
    self.layer.cornerRadius = 14;
    self.layer.masksToBounds = YES;
}

- (IBAction)homeAction:(id)sender {
    NSLog(@"go home...");
    [self.devices removeAllObjects];
    [self setupContentViews];
    [[SPDLANManager shareDLANManager] startupDLAN];
}
- (IBAction)refreshAction:(id)sender {
    NSLog(@"refresh...");
    if (_device) {
        [[SPDLANManager shareDLANManager] refreshAction:_device];
    }
}

- (void)setupContentViews {
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.devices.count > 4) {
        NSInteger count = self.devices.count;
        
        [self addDeviceLabelBtn:nil index:0 tag:0 userInteractionEnabled:NO isLast:NO];
        [self addDeviceLabelBtn:self.devices[count-3] index:1 tag:(count-3) userInteractionEnabled:YES isLast:NO];
        [self addDeviceLabelBtn:self.devices[count-2] index:2 tag:(count-2) userInteractionEnabled:YES isLast:NO];
        [self addDeviceLabelBtn:self.devices[count-1] index:3 tag:(count-1) userInteractionEnabled:YES isLast:YES];
    }else {
        for (int i=0; i<self.devices.count; i++) {
            if (i == self.devices.count-1) {
                [self addDeviceLabelBtn:self.devices[i] index:i tag:i userInteractionEnabled:YES isLast:YES];
                return ;
            }
            [self addDeviceLabelBtn:self.devices[i] index:i tag:i userInteractionEnabled:YES isLast:NO];
        }
    }
}

- (void)addDeviceLabelBtn:(SPCmdAddDevice *)device index:(NSInteger)index tag:(NSInteger)tag userInteractionEnabled:(BOOL)userInteractionEnabled isLast:(BOOL)islast {
    CGFloat width = (SCREEN_WIDTH - 20 - 28 - 50)/4;
    CGFloat x = -7 + width * index;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, width+7, 28)];
    UIImage *bgImg = [Commons getPdfImageFromResource:@"Network_navigator_path_bg"];
    
//    button.backgroundColor  = randomColor;
    button.titleLabel.font = [UIFont fontWithName:@"Calibri-Bold" size:13.0];
    button.userInteractionEnabled = userInteractionEnabled;
    [button setTitle:(userInteractionEnabled ? device.deviceName : @"... ...") forState:UIControlStateNormal];
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 15);
    if (userInteractionEnabled) {
        [button setTitleColor:[SPColorUtil getHexColor:@"#ffffff"] forState:UIControlStateNormal];
        button.alpha = 1.0;
    }else{
        [button setTitleColor:[SPColorUtil getHexColor:@"#b5b6b9"] forState:UIControlStateNormal];
        button.alpha = 0.5;
    }
    
    if (islast) {
        [button setTitleColor:[SPColorUtil getHexColor:@"#ffd570"] forState:UIControlStateNormal];
    }else {
        [button setBackgroundImage:[bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 79/2-1, 0, 79/2-1)] forState:UIControlStateNormal];
    }
    [button addTarget:self action:@selector(goDeviceAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;
    [self.contentView addSubview:button];
}

- (void)goDeviceAction:(UIButton *)btn {
    if (btn.tag > self.devices.count) {
        return;
    }
    
    NSRange range = NSMakeRange(btn.tag + 1, self.devices.count - btn.tag - 1);
    [self.devices removeObjectsInRange:range];
    [self setupContentViews];
    
    SPCmdAddDevice *device = self.devices[btn.tag];
    [[SPDLANManager shareDLANManager] browseDLNAFolder:device];
}

- (void)setDevice:(SPCmdAddDevice *)device {
    _device = device;
    int level = -1;
    for (int i=0; i<self.devices.count; i++) {
        if (device.deviceName && [device.deviceName isEqualToString:self.devices[i].deviceName]) {
            level = i;
            break;
        }
    }
    
    if (level != -1) {
        NSRange range = NSMakeRange(level, self.devices.count - level);
        [self.devices removeObjectsInRange:range];
    }
    
    [self.devices addObject:device];
    [self setupContentViews];
}

@end


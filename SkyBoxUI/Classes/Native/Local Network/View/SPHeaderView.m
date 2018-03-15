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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *homeBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *refreshBtnWidthConstraint;

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
    self.homeBtnWidthConstraint.constant = 50 * kWSCALE;
    
    [self.refreshBtn setTitle:@"" forState:UIControlStateNormal];
    [self.refreshBtn setImage:[Commons getPdfImageFromResource:@"Network_navigator_refresh"] forState:UIControlStateNormal];
    self.refreshBtn.backgroundColor = [UIColor clearColor];
    self.refreshBtnWidthConstraint.constant = 28 * kWSCALE;
    self.layer.cornerRadius = 28 * kWSCALE / 2.0;
    self.layer.masksToBounds = YES;
}

- (void)cleanHeadViews {
    [self.devices removeAllObjects];
    [self setupContentViews];
    
    _device = nil;
}

- (IBAction)homeAction:(id)sender {
    //   NSLog(@"go home...");
    _device = nil;
    [self.devices removeAllObjects];
    [self setupContentViews];
    
    SPDataManager *dataManger = [SPDataManager shareSPDataManager];
    dataManger.devices = nil;
    [[SPDLANManager shareDLANManager] showDLANDevices];
}
- (IBAction)refreshAction:(id)sender {
    //   NSLog(@"refresh...");
    
    [[SPDLANManager shareDLANManager] refreshAction:_device];
//                NSMutableArray *deviceArr = [NSMutableArray array];
//                SPCmdAddDevice *device1 = [[SPCmdAddDevice alloc] init];
//                device1.deviceId = @"uuid:00113263-934b-0011-4b93-4b9363321100";
//                device1.deviceType = @"Synology Inc";
//                device1.deviceName = @"Source-Database";
//                device1.iconURL = @"http://192.168.0.173:50001/tmp_icon/dmsicon120.jpg";
//                device1.ObjIDStr = @"0";
//                device1.showLoginCode = NO;
//                device1.parentID = @"-1";
//                [deviceArr addObject:device1];
//
//                SPCmdAddDevice *device2 = [[SPCmdAddDevice alloc] init];
//                device2.deviceId = @"uuid:00113263-934b-0011-4b93-4b9363321100";
//                device2.deviceType = @"object.container.storageFolder";
//                device2.deviceName = @"Video";
//                device2.ObjIDStr = @"33";
//                device2.showLoginCode = NO;
//                device2.parentID = @"0";
//                [deviceArr addObject:device2];
//
//                SPCmdAddDevice *device3 = [[SPCmdAddDevice alloc] init];
//                device3.deviceId = @"uuid:00113263-934b-0011-4b93-4b9363321100";
//                device3.deviceType = @"object.container.storageFolder";
//                device3.deviceName = @"TestVideo";
//                device3.ObjIDStr = @"33$99";
//                device3.showLoginCode = NO;
//                device3.parentID = @"33";
//                [deviceArr addObject:device3];
//
//                SPCmdAddDevice *device4 = [[SPCmdAddDevice alloc] init];
//                device4.deviceId = @"uuid:00113263-934b-0011-4b93-4b9363321100";
//                device4.deviceType = @"object.container.storageFolder";
//                device4.deviceName = @"9 kinds";
//                device4.ObjIDStr = @"33$104";
//                device4.showLoginCode = NO;
//                device4.parentID = @"33$99";
//                [deviceArr addObject:device4];
//
//    [self setDevices:deviceArr];
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
    CGFloat width = (SCREEN_WIDTH - 20 - 28*kWSCALE - 50*kWSCALE)/4;
    CGFloat x = -7 + width * index;
    SPDeviceButton *button = [[SPDeviceButton alloc] initWithFrame:CGRectMake(x, 0, width+7, 28*kWSCALE)];
    UIImage *bgImg = [Commons getPdfImageFromResource:@"Network_navigator_path_bg"];
    
    //    button.backgroundColor  = randomColor;
    [button setContentMode:UIViewContentModeScaleAspectFill];
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
        [button setBackgroundImage:bgImg forState:UIControlStateNormal];
//        [button setBackgroundImage:[bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 79/2-1, 0, 79/2-1)] forState:UIControlStateNormal];
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
    _device = device;
    SPDataManager *dataManger = [SPDataManager shareSPDataManager];
    dataManger.devices = [_devices copy];
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
    SPDataManager *dataManager = [SPDataManager shareSPDataManager];
    dataManager.devices = [self.devices copy];
    [self setupContentViews];
}

- (void)setDevices:(NSMutableArray<SPCmdAddDevice *> *)devices {
    _devices = devices;
    [self setupContentViews];
    
    _device = [devices lastObject];
}

- (NSArray <NSString *>*)getDevices {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.devices.count];
    for (SPCmdAddDevice *device in self.devices) {
        [arr addObject:[device mj_JSONString]];
    }
    
    return [arr copy];
}
@end

@implementation SPDeviceButton : UIButton

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
//        self.titleLabel.alpha = 0.5;
        self.alpha = 0.5;
    }else {
        self.alpha = 1.0;
    }
}
@end

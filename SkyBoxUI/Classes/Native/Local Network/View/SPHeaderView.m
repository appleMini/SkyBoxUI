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
    
    if (self.devices.count > 5) {
        NSInteger count = self.devices.count;
        
        [self addDeviceLabelBtn:self.devices[0] index:0 tag:0 userInteractionEnabled:YES];
        [self addDeviceLabelBtn:self.devices[1] index:1 tag:1 userInteractionEnabled:YES];
        [self addDeviceLabelBtn:nil index:2 tag:2 userInteractionEnabled:NO];
        [self addDeviceLabelBtn:self.devices[count-2] index:3 tag:(count-2) userInteractionEnabled:YES];
        [self addDeviceLabelBtn:self.devices[count-1] index:4 tag:(count-1) userInteractionEnabled:YES];
    }else {
        for (int i=0; i<self.devices.count; i++) {
            [self addDeviceLabelBtn:self.devices[i] index:i tag:i userInteractionEnabled:YES];
        }
    }
}

- (void)addDeviceLabelBtn:(SPCmdAddDevice *)device index:(NSInteger)index tag:(NSInteger)tag userInteractionEnabled:(BOOL)userInteractionEnabled {
    CGFloat x = 5 + 55 * index;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, 50, 40)];
    button.backgroundColor = randomColor;
    button.userInteractionEnabled = userInteractionEnabled;
    [button setTitle:(userInteractionEnabled ? device.deviceName : @"...") forState:UIControlStateNormal];
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


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
    [[SPDLANManager shareDLANManager] startupDLAN];
}
- (IBAction)refreshAction:(id)sender {
    NSLog(@"refresh...");
    [[SPDLANManager shareDLANManager] refreshAction:nil];
}

- (void)setupContentViews {
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.devices.count > 5) {
        
    }else{
        
    }
}

- (void)setDevice:(SPCmdAddDevice *)device {
    _device = device;
    int level = -1;
    for (int i=0; i<self.devices.count; i++) {
        if (device.deviceId && [device.deviceId isEqualToString:self.devices[i].deviceId]) {
            level = i;
            break;
        }
    }
    
    if (level != -1) {
        NSRange range = NSMakeRange(level, self.devices.count - level);
        [self.devices removeObjectsInRange:range];
    }
    
    [self setupContentViews];
}
@end

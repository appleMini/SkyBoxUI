//
//  SPDLANManager.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/26.
//

#import "SPDLANManager.h"
#import <GDataXMLNode2/GDataXMLNode.h>

@interface SPDLANManager()
@property (nonatomic, strong) CADisplayLink *displink;

@end

@implementation SPDLANManager

static SPDLANManager *_manager = nil;

+ (instancetype)shareDLANManager {
    if (!_manager) {
        _manager = [[SPDLANManager alloc] init];
    }
    
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CADisplayLink *displink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tickSocketIO_MainThread)];
        [displink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.displink = displink;
        
        [self startupDLAN];
    }
    return self;
}

- (void)startupDLAN {
    SPCmdEvent *addDLNADeviceCallback = [[SPCmdEvent alloc] initWithEventName:@"AddDLNADeviceCallback" callBack:(void *)AddDLNADeviceCallback];
    SPCmdEvent *removeDLNADeviceCallback = [[SPCmdEvent alloc] initWithEventName:@"RemoveDLNADeviceCallback" callBack:(void *)RemoveDLNADeviceCallback];
    SPCmdEvent *browseDLNAFolderCallback = [[SPCmdEvent alloc] initWithEventName:@"BrowseDLNAFolderCallback" callBack:(void *)BrowseDLNAFolderCallback];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"StartDLAN", @"AddDLNADeviceCallback" : addDLNADeviceCallback, @"RemoveDLNADeviceCallback" : removeDLNADeviceCallback, @"BrowseDLNAFolderCallback" : browseDLNAFolderCallback}];
}
- (void)closeDLAN {
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"DestroyDLAN"}];
    
}

- (void)releaseAction {
    [self closeDLAN];
    [self.displink invalidate];
    self.displink = nil;
    
    _manager.delegate = nil;
    _manager = nil;
}

- (void)dealloc {
    NSLog(@"Local Network 销毁。。。。。。。");
}

- (void)tickSocketIO_MainThread {
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"UpdateDLNA"}];
}

- (void)browseDLNAFolder:(SPCmdAddDevice *)device {
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"BrowseDLNAFolder", @"device" : device}];
}

void AddDLNADeviceCallback(const char *UUID, int UUIDLength, const char *DeviceTitle, int DeviceTitleLength,
                           const char *iconURL, int iconURLLength) {
    NSString *uuid = [NSString stringWithUTF8String:UUID];
    NSString *deviceTitle = [NSString stringWithUTF8String:DeviceTitle];
    NSString *iconUrl = [NSString stringWithUTF8String:iconURL];
    
    SPCmdAddDevice *device = [[SPCmdAddDevice alloc] init];
    device.deviceId = uuid;
    device.deviceName = deviceTitle;
    device.iconURL = iconUrl;
    SPDLANManager *dlan = [SPDLANManager shareDLANManager];
    if (dlan.delegate && [dlan.delegate respondsToSelector:@selector(addDlanDevice:)]) {
        [dlan.delegate addDlanDevice:device];
    }
}

void RemoveDLNADeviceCallback(const char *UUID, int UUIDLength) {
    NSLog(@"RemoveDLNADeviceCallback UUID == %@", [NSString stringWithUTF8String:UUID]);
}

void BrowseDLNAFolderCallback(const char *BrowseFolderXML, int xmlLength, const char *UUIDStr, int UUIDLength, const char *ObjIDStr, int ObjIDLength) {
    if (xmlLength <= 0) {
        return;
    }
    
    SPCmdAddDevice *device = [[SPCmdAddDevice alloc] init];
    device.ObjIDStr = [NSString stringWithUTF8String:ObjIDStr];
    device.deviceId = [NSString stringWithUTF8String:UUIDStr];
    
    NSString *xmlstr = [NSString stringWithUTF8String:BrowseFolderXML];
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:xmlstr options:0 error:nil];
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
    
    NSArray *array = [xmlEle children];
    NSLog(@"count : %lu", (unsigned long)[array count]);
    
    for (int i = 0; i < [array count]; i++) {
        GDataXMLElement *ele = [array objectAtIndex:i];
        
        NSLog(@"GDataXMLElement  name == %@", [ele name]);
        //        // 根据标签名判断
        //        if ([[ele name] isEqualToString:@"name"]) {
        //            // 读标签里面的属性
        //            NSLog(@"name --> %@", [[ele attributeForName:@"value"] stringValue]);
        //        } else {
        //            // 直接读标签间的String
        //            NSLog(@"age --> %@", [ele stringValue]);
        //        }
        
    }
}
@end


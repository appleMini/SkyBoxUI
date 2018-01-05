//
//  SPDLANManager.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/26.
//

#import "SPDLANManager.h"
#import <KissXML/KissXML.h>


@interface SPDLANManager() <NSXMLParserDelegate>
@property (nonatomic, strong) CADisplayLink *displink;
@property (nonatomic, strong) NSTimer *timeoutTimer;

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

- (void)emptyServers {
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
    
    [self closeDLAN];
    if (self.delegate && [self.delegate respondsToSelector:@selector(addDlanDevice: parentID:)]) {
        [self.delegate addDlanDevice:nil parentID:@"-1"];
    }
}

- (void)startupDLAN {
    [self closeDLAN];
    
    SPCmdEvent *addDLNADeviceCallback = [[SPCmdEvent alloc] initWithEventName:@"AddDLNADeviceCallback" callBack:(void *)AddDLNADeviceCallback];
    SPCmdEvent *removeDLNADeviceCallback = [[SPCmdEvent alloc] initWithEventName:@"RemoveDLNADeviceCallback" callBack:(void *)RemoveDLNADeviceCallback];
    SPCmdEvent *browseDLNAFolderCallback = [[SPCmdEvent alloc] initWithEventName:@"BrowseDLNAFolderCallback" callBack:(void *)BrowseDLNAFolderCallback];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"StartDLAN", @"AddDLNADeviceCallback" : addDLNADeviceCallback, @"RemoveDLNADeviceCallback" : removeDLNADeviceCallback, @"BrowseDLNAFolderCallback" : browseDLNAFolderCallback}];
    
    self.status = AddDeviceStatus;
    _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(emptyServers) userInfo:nil repeats:NO];
}
- (void)closeDLAN {
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"DestroyDLAN"}];
    
    self.status = ShutdownStatus;
}

- (void)refreshAction:(SPCmdAddDevice *)device {
    [self browseDLNAFolder:device];
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
    self.status = BrowseFolderStatus;
}

void AddDLNADeviceCallback(const char* UUID, int uuidLength, const char* title, int titleLength, const char* iconurl, int iconLength, const char* Manufacturer, int manufacturerLength) {
    
    NSString *uuid = [[NSString alloc] initWithData:[NSData dataWithBytes:UUID length:uuidLength] encoding:NSUTF8StringEncoding];
    NSString *deviceTitle = [[NSString alloc] initWithData:[NSData dataWithBytes:title length:titleLength] encoding:NSUTF8StringEncoding];
    NSString *iconUrl = [[NSString alloc] initWithData:[NSData dataWithBytes:iconurl length:iconLength] encoding:NSUTF8StringEncoding];
    NSString *manufacturer = [[NSString alloc] initWithData:[NSData dataWithBytes:Manufacturer length:manufacturerLength] encoding:NSUTF8StringEncoding];
    
    SPCmdAddDevice *device = [[SPCmdAddDevice alloc] init];
    device.deviceId = uuid;
    device.deviceName = deviceTitle;
    device.iconURL = iconUrl;
    device.deviceType = manufacturer;
    SPDLANManager *dlan = [SPDLANManager shareDLANManager];
    
    [dlan.timeoutTimer invalidate];
    dlan.timeoutTimer = nil;
    if (dlan.delegate && [dlan.delegate respondsToSelector:@selector(addDlanDevice: parentID:)]) {
        [dlan.delegate addDlanDevice:device parentID:@"-1"];
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
    device.ObjIDStr = [[NSString alloc] initWithData:[NSData dataWithBytes:ObjIDStr length:ObjIDLength] encoding:NSUTF8StringEncoding];
    device.deviceId = [[NSString alloc] initWithData:[NSData dataWithBytes:UUIDStr length:UUIDLength] encoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithBytes:BrowseFolderXML length:xmlLength];
    
    NSLog(@"BrowseFolderXML == \n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    DDXMLDocument  *doc = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
    //开始解析
    NSArray *results = [doc nodesForXPath:@"//Result" error:nil];
    
    NSMutableArray *arr = [NSMutableArray array];
    //遍历每个元素
    for (DDXMLElement *obj in results) {
        NSArray *Lites = [obj elementsForName:@"DIDL-Lite"];
        for (DDXMLElement *didl in Lites) {
            NSArray *containerNodeList = [didl elementsForName:@"container"];
            for (DDXMLElement *container in containerNodeList) {
                SPCmdFolderDevice *folderDevice = [[SPCmdFolderDevice alloc] init];
                folderDevice.deviceId = device.deviceId;
                
                NSString *parentId =[[container attributeForName:@"parentID"] stringValue];
                NSString *cid =[[container attributeForName:@"id"] stringValue];
                
                folderDevice.parentID = parentId;
                folderDevice.ObjIDStr = cid;
                
                DDXMLElement *titleElement = [container elementForName:@"dc:title"];
                folderDevice.deviceName = [titleElement stringValue];
                
                DDXMLElement *typeElement = [container elementForName:@"upnp:class"];
                folderDevice.deviceType = [typeElement stringValue];
                
                DDXMLElement *storageUsedElement = [container elementForName:@"upnp:storageUsed"];
                folderDevice.storageUsed = [storageUsedElement stringValue];
                
                [arr addObject:folderDevice];
            }
            
            //items
            NSArray *itemNodeList = [didl elementsForName:@"item"];
            for (DDXMLElement *item in itemNodeList) {
                NSString *parentId =[[item attributeForName:@"parentID"] stringValue];
                NSString *cid =[[item attributeForName:@"id"] stringValue];
                DDXMLElement *titleElement = [item elementForName:@"dc:title"];
                DDXMLElement *resElement = [item elementForName:@"res"];
                
                DDXMLElement *typeElement = [item elementForName:@"upnp:class"];
                device.deviceType = [typeElement stringValue];
                if (device.deviceType && [device.deviceType isEqualToString:@"object.item.imageItem.photo"]) {
                    
                    continue;
                    
                    SPCmdAlbumDevice *albumDevice = [[SPCmdAlbumDevice alloc] init];
                    albumDevice.deviceId = device.deviceId;
                    
                    albumDevice.parentID = parentId;
                    albumDevice.ObjIDStr = cid;
                    
                    DDXMLElement *albumElement = [item elementForName:@"upnp:album"];
                    albumDevice.album = [albumElement stringValue];
                    
                    
                    albumDevice.deviceName = [titleElement stringValue];
                    
                    albumDevice.deviceType = device.deviceType;
                    
                    
                    albumDevice.protocolInfo = [[resElement attributeForName:@"protocolInfo"] stringValue];
                    albumDevice.resolution = [[resElement attributeForName:@"resolution"] stringValue];
                    albumDevice.iconURL = [resElement stringValue];
                    
                    [arr addObject:albumDevice];
                }else if(device.deviceType && [device.deviceType isEqualToString:@"object.item.videoItem"]) {
                    SPCmdVideoDevice *videoDevice = [[SPCmdVideoDevice alloc] init];
                    videoDevice.deviceId = device.deviceId;
                    videoDevice.parentID = parentId;
                    videoDevice.ObjIDStr = cid;
                    videoDevice.deviceName = [titleElement stringValue];
                    videoDevice.deviceType = device.deviceType;
                    videoDevice.protocolInfo = [[resElement attributeForName:@"protocolInfo"] stringValue];
                    videoDevice.resolution = [[resElement attributeForName:@"resolution"] stringValue];
                    videoDevice.size = [[resElement attributeForName:@"size"] stringValue];
                    videoDevice.bitrate = [[resElement attributeForName:@"bitrate"] stringValue];
                    videoDevice.duration = [[resElement attributeForName:@"duration"] stringValue];
                    videoDevice.nrAudioChannels = [[resElement attributeForName:@"nrAudioChannels"] stringValue];
                    videoDevice.sampleFrequency = [[resElement attributeForName:@"sampleFrequency"] stringValue];
                    videoDevice.videoUrl = [resElement stringValue];
                    
                    [arr addObject:videoDevice];
                }
                
                
            }
        }
    }
    
    SPDLANManager *dlan = [SPDLANManager shareDLANManager];
    if (dlan.delegate && [dlan.delegate respondsToSelector:@selector(browseDLNAFolder:parentID:)]) {
        [dlan.delegate browseDLNAFolder:arr parentID:device.ObjIDStr];
    }
    
    //    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[xmlstr dataUsingEncoding:NSUTF8StringEncoding]];
    //    xmlParser.delegate = [SPDLANManager shareDLANManager];
}

#pragma -mark NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
}
@end


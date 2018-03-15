//
//  SPDLANManager.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/26.
//

#import "SPDLANManager.h"
#import <KissXML/KissXML.h>
#import "UIView+SPLoading.h"
#import "SPDataManager.h"

@interface SPDLANManager() <NSXMLParserDelegate>
@property (nonatomic, strong) CADisplayLink *displink;
@property (nonatomic, strong) NSTimer *timeoutTimer;
@property (nonatomic, strong) SPCmdEvent *addDLNADeviceCallback;
@property (nonatomic, strong) SPCmdEvent *removeDLNADeviceCallback;
@property (nonatomic, strong) SPCmdEvent *browseDLNAFolderCallback;

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
        [self.displink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (CADisplayLink *)displink {
    if (!_displink) {
        CADisplayLink *displink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tickSocketIO_MainThread)];
        self.displink = displink;
    }
    
    return _displink;
}

- (void)emptyServers {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow hideLoading];
    });
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
    
    [self closeDLAN];
    if (self.delegate && [self.delegate respondsToSelector:@selector(addDlanDevice: parentID:)]) {
        [self.delegate addDlanDevice:nil parentID:@"-1"];
    }
}

- (SPCmdEvent *)addDLNADeviceCallback {
    if (!_addDLNADeviceCallback) {
        SPCmdEvent *addDLNADeviceCallback = [[SPCmdEvent alloc] initWithEventName:@"AddDLNADeviceCallback" callBack:(void *)DAddDLNADeviceCallback];
        _addDLNADeviceCallback = addDLNADeviceCallback;
    }
    
    return _addDLNADeviceCallback;
}
- (SPCmdEvent *)removeDLNADeviceCallback {
    if (!_removeDLNADeviceCallback) {
        SPCmdEvent *removeDLNADeviceCallback = [[SPCmdEvent alloc] initWithEventName:@"RemoveDLNADeviceCallback" callBack:(void *)DRemoveDLNADeviceCallback];
        
        _removeDLNADeviceCallback = removeDLNADeviceCallback;
    }
    
    return _removeDLNADeviceCallback;
}
- (SPCmdEvent *)browseDLNAFolderCallback {
    if (!_browseDLNAFolderCallback) {
        SPCmdEvent *browseDLNAFolderCallback = [[SPCmdEvent alloc] initWithEventName:@"BrowseDLNAFolderCallback" callBack:(void *)DBrowseDLNAFolderCallback];
        
        _browseDLNAFolderCallback = browseDLNAFolderCallback;
    }
    
    return _browseDLNAFolderCallback;
}

- (void)openDLAN {
    [self closeDLAN];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"StartDLAN", @"AddDLNADeviceCallback" : self.addDLNADeviceCallback, @"RemoveDLNADeviceCallback" : self.removeDLNADeviceCallback, @"BrowseDLNAFolderCallback" : self.browseDLNAFolderCallback}];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"StartDLAN"}];
    
    self.status = DLANStartupStatus;
}

- (void)showDLANDevices {
    SPDataManager *dataManager = [SPDataManager shareSPDataManager];
    
    NSArray *servers = dataManager.servers;
    if (dataManager && servers) {
        if (servers.count > 0) {
            if (dataManager.devices && dataManager.devices.count > 0) {
                [self browseDLNAFolder:[dataManager.devices lastObject]];
            }else {
                dataManager.devices = nil;
                self.status = DLANBrowseFolderStatus;
                if (self.delegate && [self.delegate respondsToSelector:@selector(browseDLNAFolder:parentID:)]) {
                    // parentID 一定不能传 -1 , 会出现 addDlanDevice 回调 _dataArr 不会清空
                    [self.delegate browseDLNAFolder:servers parentID:@"0"];
                }
            }
        }else {
            [self startupDLAN];
        }
    }
}

- (void)startupDLANWithOutUI {
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"StartDLAN"}];
}

- (void)startupDLAN {
    [self openDLAN];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow showLoadingAndUserInteractionEnabled:NO];
    });
    
    self.status = DLANAddDeviceStatus;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(emptyServers) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] run];
        
    });
}
- (void)closeDLAN {
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"DestroyDLAN"}];
    
    self.status = DLANShutdownStatus;
}

- (void)addDLNADevice:(SPCmdAddDevice *)device {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow hideLoading];
    });
    
    SPDataManager *dataManager = [SPDataManager shareSPDataManager];
    [dataManager addServer:device];
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(addDlanDevice: parentID:)]) {
        [self.delegate addDlanDevice:device parentID:@"-1"];
    }
}

- (void)removeDLNADevice:(SPCmdAddDevice *)device {
    
}

- (void)browseDLNAFolderCall:(SPCmdAddDevice *)pDevice browseFolderXML:(NSData *)xmldata {
    DDXMLDocument  *doc = [[DDXMLDocument alloc] initWithData:xmldata options:0 error:nil];
    
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
                folderDevice.deviceId = pDevice.deviceId;
                
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
                pDevice.deviceType = [typeElement stringValue];
                if (pDevice.deviceType && [pDevice.deviceType isEqualToString:@"object.item.imageItem.photo"]) {
                    
                    continue;
                    
                    SPCmdAlbumDevice *albumDevice = [[SPCmdAlbumDevice alloc] init];
                    albumDevice.deviceId = pDevice.deviceId;
                    
                    albumDevice.parentID = parentId;
                    albumDevice.ObjIDStr = cid;
                    
                    DDXMLElement *albumElement = [item elementForName:@"upnp:album"];
                    albumDevice.album = [albumElement stringValue];
                    
                    
                    albumDevice.deviceName = [titleElement stringValue];
                    
                    albumDevice.deviceType = pDevice.deviceType;
                    
                    
                    albumDevice.protocolInfo = [[resElement attributeForName:@"protocolInfo"] stringValue];
                    albumDevice.resolution = [[resElement attributeForName:@"resolution"] stringValue];
                    albumDevice.iconURL = [resElement stringValue];
                    
                    [arr addObject:albumDevice];
                }else if(pDevice.deviceType && [pDevice.deviceType containsString:@"object.item.videoItem"]) {
                    SPCmdVideoDevice *videoDevice = [[SPCmdVideoDevice alloc] init];
                    videoDevice.deviceId = pDevice.deviceId;
                    videoDevice.parentID = parentId;
                    videoDevice.ObjIDStr = cid;
                    videoDevice.deviceName = [titleElement stringValue];
                    videoDevice.deviceType = pDevice.deviceType;
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
        [dlan.delegate browseDLNAFolder:arr parentID:pDevice.ObjIDStr];
    }
    
    //    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[xmlstr dataUsingEncoding:NSUTF8StringEncoding]];
    //    xmlParser.delegate = [SPDLANManager shareDLANManager];
}

- (void)refreshAction:(SPCmdAddDevice *)device {
    if (device) {
        [self browseDLNAFolder:device];
    }else {
//        SPDataManager *dataManager = [SPDataManager shareSPDataManager];
//        [dataManager removeAllServers];
//        
//        [self startupDLAN];
    }
}

- (void)releaseAction {
    _manager.delegate = nil;
}

- (void)dealloc {
    //   NSLog(@"Local Network 销毁。。。。。。。");
}

- (void)tickSocketIO_MainThread {
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"UpdateDLNA"}];
}

- (void)browseDLNAFolder:(SPCmdAddDevice *)device {
    if (!device) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"BrowseDLNAFolder", @"device" : device}];
    self.status = DLANBrowseFolderStatus;
}

static void DAddDLNADeviceCallback(const char* UUID, int uuidLength, const char* title, int titleLength, const char* iconurl, int iconLength, const char* Manufacturer, int manufacturerLength) {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow hideLoading];
    });
    
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

static void DRemoveDLNADeviceCallback(const char *UUID, int UUIDLength) {
    //   NSLog(@"RemoveDLNADeviceCallback UUID == %@", [NSString stringWithUTF8String:UUID]);
}

static void DBrowseDLNAFolderCallback(const char *BrowseFolderXML, int xmlLength, const char *UUIDStr, int UUIDLength, const char *ObjIDStr, int ObjIDLength) {
    if (xmlLength <= 0) {
        return;
    }
    
    SPCmdAddDevice *device = [[SPCmdAddDevice alloc] init];
    device.ObjIDStr = [[NSString alloc] initWithData:[NSData dataWithBytes:ObjIDStr length:ObjIDLength] encoding:NSUTF8StringEncoding];
    device.deviceId = [[NSString alloc] initWithData:[NSData dataWithBytes:UUIDStr length:UUIDLength] encoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithBytes:BrowseFolderXML length:xmlLength];
    
    //   NSLog(@"BrowseFolderXML == \n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
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
                }else if(device.deviceType && [device.deviceType containsString:@"object.item.videoItem"]) {
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


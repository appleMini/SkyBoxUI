//
//  SPDLANManager.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/26.
//

#import <Foundation/Foundation.h>
#import "SPBaseViewController.h"

typedef enum : NSUInteger {
    DLANStartupStatus = 0,
    DLANAddDeviceStatus,
    DLANBrowseFolderStatus,
    DLANShutdownStatus
} DLANManagerStatus;

@protocol SPDLANManagerDelegate;
@interface SPDLANManager : NSObject
@property (nonatomic, weak) id<SPDLANManagerDelegate> delegate;
@property (nonatomic, assign) DLANManagerStatus status;

+ (instancetype)shareDLANManager;

- (void)startupDLANWithOutUI;
- (void)closeDLAN;
- (void)openDLAN;
- (void)startupDLAN;
- (void)showDLANDevices;
- (void)addDLNADevice:(SPCmdAddDevice *)device;
- (void)removeDLNADevice:(SPCmdAddDevice *)device;
- (void)browseDLNAFolder:(SPCmdAddDevice *)device;
- (void)refreshAction:(SPCmdAddDevice *)device;
- (void)browseDLNAFolderCall:(SPCmdAddDevice *)folderDevice browseFolderXML:(NSData *)xmldata;
- (void)releaseAction;
@end

@protocol SPDLANManagerDelegate <NSObject>

@optional
- (void)addDlanDevice:(SPCmdAddDevice *)device parentID:(NSString *)pid;
- (void)browseDLNAFolder:(NSArray<SPCmdAddDevice *> *)folders parentID:(NSString *)pid;
@end


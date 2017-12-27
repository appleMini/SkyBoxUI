//
//  SPDLANManager.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/26.
//

#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    AddDeviceStatus = 0,
    BrowseFolderStatus,
    ShutdownStatus
} DLANManagerStatus;

@protocol SPDLANManagerDelegate;
@interface SPDLANManager : NSObject
@property (nonatomic, weak) id<SPDLANManagerDelegate> delegate;
@property (nonatomic, assign) DLANManagerStatus status;

+ (instancetype)shareDLANManager;

- (void)startupDLAN;
- (void)refreshAction:(SPCmdAddDevice *)device;
- (void)browseDLNAFolder:(SPCmdAddDevice *)device;
- (void)releaseAction;
@end

@protocol SPDLANManagerDelegate <NSObject>

@optional
- (void)addDlanDevice:(SPCmdAddDevice *)device parentID:(NSString *)pid;
- (void)browseDLNAFolder:(NSArray<SPCmdAddDevice *> *)folders parentID:(NSString *)pid;
@end


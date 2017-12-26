//
//  SPDLANManager.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/26.
//

#import <Foundation/Foundation.h>

@protocol SPDLANManagerDelegate;
@interface SPDLANManager : NSObject
@property (nonatomic, weak) id<SPDLANManagerDelegate> delegate;

+ (instancetype)shareDLANManager;

- (void)releaseAction;
@end

@protocol SPDLANManagerDelegate <NSObject>

@optional
- (void)addDlanDevice:(SPCmdAddDevice *)device;
@end

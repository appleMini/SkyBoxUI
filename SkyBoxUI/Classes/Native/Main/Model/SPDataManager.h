//
//  SPDataManager.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/2/5.
//

#import <Foundation/Foundation.h>
#import "SPBaseViewController.h"

@interface SPDataManager : NSObject

@property (nonatomic, strong) SPAirscreen                       *airscreen;
@property (nonatomic, strong) NSArray<SPCmdAddDevice *>         *devices;
@property (nonatomic, strong) NSMutableArray<SPCmdAddDevice *>  *servers;


+ (instancetype)shareDataManager;

- (void)addServer:(SPCmdAddDevice *)device;
- (void)removeAllServers;
@end

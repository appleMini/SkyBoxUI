//
//  SPDataManager.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/2/5.
//

#import "SPDataManager.h"

@interface SPDataManager()

@property (strong, nonatomic) dispatch_queue_t concurrentQueue;
@end

@implementation SPDataManager
static SPDataManager *_manager = nil;

+ (instancetype)shareDataManager {
    if (!_manager) {
        _manager = [[SPDataManager alloc] init];
    }
    
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _servers = [NSMutableArray array];
        _concurrentQueue = dispatch_queue_create("com.skyboxUI.SPDataManagerQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSArray<SPCmdAddDevice *> *)servers {
    __block NSArray *arrCopy = nil;
    dispatch_sync(_concurrentQueue, ^{
        arrCopy = [_servers copy];
    });
    return arrCopy;
}

- (void)addServer:(SPCmdAddDevice *)server {
    if (server) {
        dispatch_barrier_async(_concurrentQueue, ^{
            for(SPCmdAddDevice *device in _servers) {
                if ([device.deviceId isEqualToString:server.deviceId]) {
                    return ;
                }
            }
            
            [_servers addObject:server];
        });
    }
}

- (void)removeAllServers {
    dispatch_barrier_async(_concurrentQueue, ^{
        [_servers removeAllObjects];
    });
}
@end

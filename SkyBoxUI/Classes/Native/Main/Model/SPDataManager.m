//
//  SPDataManager.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/2/5.
//

#import "SPDataManager.h"

@interface SPDataManager()

@property (strong, nonatomic) dispatch_queue_t concurrentQueue;
@property (strong, nonatomic) dispatch_queue_t concurrentCacheQueue;
@end

@implementation SPDataManager
SPSingletonM(SPDataManager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cacheModel = [[NSMutableDictionary alloc] initWithCapacity:6];
        
        _servers = [NSMutableArray array];
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INTERACTIVE, -1);
        _concurrentQueue = dispatch_queue_create("com.skyboxUI.SPDataManagerQueue.Servers", attr);
        _concurrentCacheQueue = dispatch_queue_create("com.skyboxUI.SPDataManagerQueue.Cache", attr);
    }
    return self;
}
/**
 
 cache  Model @{DataSourceType0 : @{showType: contentOffsetY: hash:} }
 */
- (NSDictionary *)getCacheDict:(DataSourceType)datasource {
    __block NSDictionary *modelCopy = nil;
    dispatch_sync(_concurrentCacheQueue, ^{
        modelCopy = [_cacheModel copy];
    });
    
    NSString *key = [NSString stringWithFormat:@"DataSourceType%lud", (unsigned long)datasource];
    NSDictionary *model = [modelCopy objectForKey:key];
    
    return model;
}

- (DisplayType)getDisplayType:(DataSourceType)datasource {
    NSDictionary *model = [self getCacheDict:datasource];
    
    if (!model) {
        return UnknownType;
    }
    
    DisplayType showtype = [[model objectForKey:@"showtype"] integerValue];
    return showtype;
}

- (CGFloat)getContentOffsetY:(DataSourceType)datasource {
    NSDictionary *model = [self getCacheDict:datasource];
    
    if (!model) {
        return -1;
    }
    
    CGFloat offsetY = [[model objectForKey:@"contentOffsetY"] floatValue];
    return offsetY;
}

- (NSUInteger)getHash:(DataSourceType)datasource {
    NSDictionary *model = [self getCacheDict:datasource];
    
    if (!model) {
        return 0;
    }
    
    NSUInteger hash = [[model objectForKey:@"hash"] unsignedIntegerValue];
    return hash;
}

- (BOOL)hasUpdate:(NSUInteger)hash dataSource:(DataSourceType)datasource {
    NSDictionary *model = [self getCacheDict:datasource];
    
    if (!model) {
        return YES;
    }
    
    NSUInteger oldHash = [[model objectForKey:@"hash"] unsignedIntegerValue];
    return hash != oldHash;
}

- (void)setCacheWithShowtype:(DataSourceType)datasource displayType:(DisplayType)showtype {
    NSDictionary *model = [self getCacheDict:datasource];
    
    [self setCache:datasource displayType:[NSNumber numberWithUnsignedInteger:showtype] contentOffsetY:(model[@"contentOffsetY"] ? model[@"contentOffsetY"] : [NSNumber numberWithFloat:(0.0)]) dataSourceString:model[@"hash"] ? model[@"hash"] : [NSNumber numberWithUnsignedInteger:0]];
}

- (void)setCacheWithOffsetY:(DataSourceType)datasource contentOffsetY:(CGFloat)Offsety {
    NSDictionary *model = [self getCacheDict:datasource];
    
    [self setCache:datasource displayType:(model[@"showtype"] ? model[@"showtype"] : [NSNumber numberWithUnsignedInteger:0]) contentOffsetY:[NSNumber numberWithFloat:(Offsety)] dataSourceString:model[@"hash"] ? model[@"hash"] : [NSNumber numberWithUnsignedInteger:0]];
}

- (void)setCacheWithDataSource:(DataSourceType)datasource dataSourceString:(NSUInteger)hash {
    NSDictionary *model = [self getCacheDict:datasource];
    
    BOOL update = [self hasUpdate:hash dataSource:datasource];
    if (!update) {
        return;
    }
    
    NSNumber *contentOffset = model[@"contentOffsetY"] ? model[@"contentOffsetY"] : [NSNumber numberWithFloat:(0.0)];
    if (update) {
        contentOffset = [NSNumber numberWithFloat:(0.0)];
    }
    
    [self setCache:datasource displayType:(model[@"showtype"] ? model[@"showtype"] : [NSNumber numberWithUnsignedInteger:0]) contentOffsetY:contentOffset dataSourceString:[NSNumber numberWithUnsignedInteger:hash]];
}

- (void)setCache:(DataSourceType)datasource displayType:(NSNumber *)showtype contentOffsetY:(NSNumber *)Offsety dataSourceString:(NSNumber *)hash {
    
    NSString *key = [NSString stringWithFormat:@"DataSourceType%lud", (unsigned long)datasource];
    
    NSDictionary *model = @{@"showtype" : showtype, @"contentOffsetY" : Offsety, @"hash" : hash
                            };
    
    dispatch_barrier_async(_concurrentCacheQueue, ^{
        [_cacheModel setObject:model forKey:key];
    });
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
                if ([device.deviceId hash] == [server.deviceId hash]) {
                    return ;
                }
            }
            
            [_servers addObject:server];
        });
    }
}

- (void)removeServer:(SPCmdAddDevice *)server {
    if (server) {
        dispatch_barrier_async(_concurrentQueue, ^{
            for(SPCmdAddDevice *device in _servers) {
                if ([device.deviceId hash] == [server.deviceId hash]) {
                    [_servers removeObject:device];
                    return ;
                }
            }
        });
    }
}

- (void)removeAllServers {
    dispatch_barrier_async(_concurrentQueue, ^{
        [_servers removeAllObjects];
    });
}
@end


//
//  SPDataManager.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/2/5.
//

#import <Foundation/Foundation.h>
#import "SPBaseViewController.h"
#import "SPSingle.h"

@interface SPDataManager : NSObject
SPSingletonH(SPDataManager)

@property (nonatomic, strong) SPAirscreen                       *airscreen;
@property (nonatomic, strong) NSArray<SPCmdAddDevice *>         *devices;
@property (nonatomic, strong) NSMutableArray<SPCmdAddDevice *>  *servers;
@property (nonatomic, strong) NSMutableDictionary               *cacheModel;

- (void)addServer:(SPCmdAddDevice *)device;
- (void)removeServer:(SPCmdAddDevice *)server;
- (void)removeAllServers;

- (void)setCacheWithShowtype:(DataSourceType)datasource displayType:(DisplayType)showtype;
- (void)setCacheWithOffsetY:(DataSourceType)datasource contentOffsetY:(CGFloat)Offsety;
- (void)setCacheWithDataSource:(DataSourceType)datasource dataSourceString:(NSUInteger)hash;

- (void)setCache:(DataSourceType)datasource displayType:(NSNumber *)showtype contentOffsetY:(NSNumber *)Offsety dataSourceString:(NSNumber *)hash;
- (DisplayType)getDisplayType:(DataSourceType)datasource;
- (CGFloat)getContentOffsetY:(DataSourceType)datasource;
- (NSUInteger)getHash:(DataSourceType)datasource;
- (NSDictionary *)getCacheDict:(DataSourceType)datasource;

@end


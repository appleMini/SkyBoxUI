//
//  SPAirScreenManager.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/2/5.
//

#import <Foundation/Foundation.h>
#import "SPBaseViewController.h"
typedef void (^ResultBlock) (NSArray *listResult, NSString *resultStr);
@interface SPAirScreenManager : NSObject

+ (instancetype)shareAirScreenManager;

- (void)closeAirscreen;
- (void)startupAirscreen;
- (void)startupAndSendPackage;
- (void)stopSearch;
- (void)connectServer:(SPAirscreen *)airscreen  complete:(ResultBlock)block;
- (void)disConnectServer;
- (void)releaseAction;

- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
@end

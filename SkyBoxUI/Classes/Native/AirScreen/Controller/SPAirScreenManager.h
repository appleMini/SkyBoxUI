//
//  SPAirScreenManager.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/2/5.
//

#import <Foundation/Foundation.h>
#import "SPBaseViewController.h"
typedef void (^ResultBlock) (NSArray *listResult);
@interface SPAirScreenManager : NSObject

+ (instancetype)shareAirScreenManager;

- (void)startupAirscreen;
- (void)startupAndSendPackage;
- (void)stopSearch;
- (void)connectServer:(SPAirscreen *)airscreen  complete:(ResultBlock)block;
- (void)releaseAction;
@end
//
//  SPPluginBridge.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/19.
//

#import <Foundation/Foundation.h>
#import "SPSingle.h"

//extern "C" void callAction(const char* functionName, const char*  param,void* didFinishMethod, void* opaque);

@interface SPPluginBridge : NSObject
SPSingletonH(SPPluginBridge)

//- (void)requestBlock:(^(void)())reqBlock responseBlock:(^(void)())resp;
@end

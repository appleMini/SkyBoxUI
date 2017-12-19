//
//  ServiceCall.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/11.
//

#import <Foundation/Foundation.h>

@interface ServiceCall : NSObject

+ (void)callPostActionParams:(id)parameters requestUrl:(NSString *)url resultctxCall:(void (^)(NSDictionary *result))successBlock errorCall:(void (^)(NSDictionary *error))errorBlock;


+ (void)callGetActionParams:(id)parameters requestUrl:(NSString *)url resultctxCall:(void (^)(NSDictionary *result))successBlock errorCall:(void (^)(NSDictionary *error))errorBlock;
@end

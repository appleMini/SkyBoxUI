//
//  ServiceCall.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/11.
//

#import "ServiceCall.h"
#import <AFNetworking/AFNetworking.h>

@implementation ServiceCall

+ (void)callPostActionParams:(id)parameters requestUrl:(NSString *)url resultctxCall:(void (^)(NSDictionary *result))successBlock errorCall:(void (^)(NSDictionary *error))errorBlock {
    // 1.初始化单例类
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    // 2.设置非校验证书模式
    securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    //也不验证域名一致性
    [securityPolicy setValidatesDomainName:NO];
    manager.securityPolicy = securityPolicy;
    //    //关闭缓存避免干扰测试
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = nil;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            //     NSLog(@"%@", dict);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            if (errorBlock) {
                errorBlock([error userInfo]);
            }
        }
    }];
}

+ (void)callGetActionParams:(id)parameters requestUrl:(NSString *)url resultctxCall:(void (^)(NSDictionary *result))successBlock errorCall:(void (^)(NSDictionary *error))errorBlock {
    // 1.初始化单例类
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    // 2.设置非校验证书模式
    securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    //也不验证域名一致性
    [securityPolicy setValidatesDomainName:NO];
    manager.securityPolicy = securityPolicy;
    //    //关闭缓存避免干扰测试
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = nil;
    
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            
            if (successBlock) {
                successBlock(dict);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            if (errorBlock) {
                errorBlock([error userInfo]);
            }
        }
    }];
}
@end

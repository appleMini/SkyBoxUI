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
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            errorBlock([error userInfo]);
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
    
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            errorBlock([error userInfo]);
        }
    }];
}
@end

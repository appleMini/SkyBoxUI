//
//  SPDownloadManager.h
//  SPDownloadManagerExample
//
//  Created by hans on 15/8/4.
//  Copyright © 2015年 kl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPSessionModel.h"

@interface SPDownloadManager : NSObject

@property (nonatomic, copy) NSString *fileType;

/**
 *  单例
 *
 *  @return 返回单例对象
 */
+ (instancetype)sharedInstance;

/**
 *  开启任务下载资源
 *  param  saveFIleaPath  保存的地址
 *  @param url           下载地址
 *  @param fillType       下载文件后缀 ，默认为.zip
 *  @param progressBlock 回调下载进度
 *  @param stateBlock    下载状态
 *  [SPDownloadManager sharedInstance].fileType = @".zip" 使用时设置下载文件后缀
 */
- (void)downloadfillType:(NSString *)fillType saveFIleaPath:(NSString *)saveFIleaPath downloadUrl:(NSString *)downloadUrl progress:(void (^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))progressBlock state:(void (^)(DownloadState state))stateBlock;
/**
 *  查询该资源的下载进度值
 *
 *  @param url 下载地址
 *
 *  @return 返回下载进度值
 */
- (CGFloat)progress:(NSString *)url;

/**
 *  获取该资源总大小
 *
 *  @param url 下载地址
 *
 *  @return 资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url;

/**
 *  判断该资源是否下载完成
 *
 *  @param url 下载地址
 *
 *  @return YES: 完成
 */
- (BOOL)isCompletion:(NSString *)url;

/**
 *  删除该资源
 *
 *  @param url 下载地址
 */
- (void)deleteFile:(NSString *)url;

/**
 *  清空所有下载资源
 */
- (void)deleteAllFile;

/**
 *  文件路径
 */
- (NSString *)filePath:(NSString *)url;

/**
 *  暂停下载
 */
- (void)pause:(NSString *)url;

/**
 * 获取文件大小
 */
-(float)fileToCachesLength;

@end

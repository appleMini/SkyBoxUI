//
//  SPTaskModel.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/7.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SPDownloadStatus) {
    SPDownloadStatusNone = 0,       // 初始状态
    SPDownloadStatusRunning = 1,    // 下载中
    SPDownloadStatusSuspended = 2,  // 下载暂停
    SPDownloadStatusCompleted = 3,  // 下载完成
    SPDownloadStatusFailed  = 4,    // 下载失败
    SPDownloadStatusWaiting = 5,    // 等待下载
    SPDownloadStatusCancel = 6      //取消
};

@interface SPTaskModel : NSObject

/** 流 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 下载地址 */
@property (nonatomic, copy) NSString *downloadUrl;
// 下载后存储位置
@property (nonatomic, copy) NSString *localPath;

/** 获得服务器这次请求 返回数据的总长度 */
@property (nonatomic, assign) NSInteger totalLength;

/** 下载进度 */
@property (nonatomic, assign) double progress;
@property (nonatomic, copy) void(^progressBlock)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress);

@property (nonatomic, assign) SPDownloadStatus status;
/** 下载状态 */
@property (nonatomic, copy) void(^downloadStatusBlock)(SPDownloadStatus status);

@end

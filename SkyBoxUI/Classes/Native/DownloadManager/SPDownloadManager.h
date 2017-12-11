//
//  SPDownloadManager.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/6.
//

#import <Foundation/Foundation.h>

@protocol SPDownloadDelegate;
@class SPTaskModel;
@interface SPDownloadManager : NSObject
@property (weak, nonatomic) id<SPDownloadDelegate> delegate;

+ (SPDownloadManager *)shareInstance;

- (void)addTaskModel:(SPTaskModel *)taskmodel;

- (void)add:(NSString *)url;
- (void)suspendOperation:(NSString *)url;
- (void)resumeOperation:(NSString *)url;
- (void)cancelOperation:(NSString *)url;
- (void)cancelAllOperation;

@end

@protocol SPVideoProtocol <NSObject>
@end

@protocol SPAudioProtocol <NSObject>
@end

@protocol SPImageProtocol <NSObject>
@end

@protocol SPDownloadDelegate <NSObject>
@end

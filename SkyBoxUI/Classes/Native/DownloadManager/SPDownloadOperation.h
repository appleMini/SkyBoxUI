//
//  SPDownloadOperationQueue.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/6.
//

#import <Foundation/Foundation.h>

@class SPTaskModel;
@class SPMovieModel;
@interface SPDownloadOperation : NSOperation

@property (nonatomic, weak, readonly) SPTaskModel *taskModel;

- (instancetype)initWithModel:(SPTaskModel *)model movieModel:(SPMovieModel *)movie session:(NSURLSession *)session;

- (void)suspend;
- (void)resume;

- (void)completeOperation;
@end

@interface NSURLSessionTask (SPTaskModel)

// 为了更方便去获取，而不需要遍历，采用扩展的方式，可直接提取，提高效率
@property (nonatomic, weak) SPTaskModel *sp_taskModel;
@end

@interface NSURLSessionTask (SPMovieModel)

// 为了更方便去获取，而不需要遍历，采用扩展的方式，可直接提取，提高效率
@property (nonatomic, weak) SPMovieModel *sp_movieModel;
@end

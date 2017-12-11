//
//  SPDownloadOperationQueue.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/6.
//

#import "SPDownloadOperation.h"
#import <objc/runtime.h>
#import "SPDBTool.h"
#import "SPTaskModel.h"

#define kKVOBlock(KEYPATH, BLOCK) \
[self willChangeValueForKey:KEYPATH]; \
BLOCK(); \
[self didChangeValueForKey:KEYPATH];

static NSTimeInterval kTimeoutInterval = -1;

@interface SPDownloadOperation() {
    BOOL _finished;
    BOOL _executing;
}

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, weak, readwrite) SPTaskModel *taskModel;
@property (nonatomic, strong) SPMovieModel *movieModel;
@property (nonatomic, weak) NSURLSession *session;
@end

@implementation SPDownloadOperation

#pragma -mark Operation
- (instancetype)initWithModel:(SPTaskModel *)model movieModel:(SPMovieModel *)movie session:(NSURLSession *)session {
    
    if (self = [super init]) {
        self.movieModel = movie;
        self.taskModel = model;
        self.session = session;
        
        [self startRequest];
    }
    
    return self;
}

- (void)dealloc {
    self.task = nil;
}

#pragma -mark file
- (unsigned long long)downLoadLength {
    if (!self.movieModel.localUrl) {
        return 0;
    }
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:self.movieModel.localUrl]) {
        
        return [[manager attributesOfItemAtPath:self.movieModel.localUrl error:nil] fileSize];
    }
    
    return 0;
}

- (void)startRequest {
    NSURL *url = [NSURL URLWithString:self.taskModel.downloadUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTimeoutInterval];
    
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", [self downLoadLength]];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    self.task = [self.session dataTaskWithRequest:request];
    [self configTask];
}

- (void)configTask {
    self.task.sp_taskModel = self.taskModel;
    self.task.sp_movieModel = self.movieModel;
}

- (void)start {
    if (self.isCancelled) {
        kKVOBlock(@"isFinished", ^{
            _finished = YES;
        });
        return;
    }
    
    if (self.isExecuting) {
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    if (self.task.state == NSURLSessionTaskStateSuspended) {
        [self.task resume];
    }
    self.taskModel.status = SPDownloadStatusRunning;
    if (self.taskModel.downloadStatusBlock) {
        self.taskModel.downloadStatusBlock(SPDownloadStatusRunning);
    }
    
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)suspend {
    if (self.task) {
        [self willChangeValueForKey:@"isExecuting"];
        if (self.task.state == NSURLSessionTaskStateRunning) {
            [self.task suspend];
        }
        self.taskModel.status = SPDownloadStatusSuspended;
        if (self.taskModel.downloadStatusBlock) {
            self.taskModel.downloadStatusBlock(SPDownloadStatusSuspended);
        }
        _executing = NO;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)resume {
    if (self.taskModel.status == SPDownloadStatusCompleted || self.taskModel.status == SPDownloadStatusRunning || self.taskModel.status == SPDownloadStatusNone || self.taskModel.status == SPDownloadStatusFailed) {
        return;
    }
    self.taskModel.status = SPDownloadStatusRunning;
    if (self.taskModel.downloadStatusBlock) {
        self.taskModel.downloadStatusBlock(SPDownloadStatusRunning);
    }
    
    if (self.task == nil
        || (self.task.state == NSURLSessionTaskStateCompleted && self.taskModel.progress < 1.0)) {
        [self startRequest];
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    if (self.task.state == NSURLSessionTaskStateSuspended) {
        [self.task resume];
    }
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)cancel {
    [self willChangeValueForKey:@"isCancelled"];
    [super cancel];
    [self.task cancel];
    self.task = nil;
    [self didChangeValueForKey:@"isCancelled"];
    
    self.taskModel.status = SPDownloadStatusCancel;
    if (self.taskModel.downloadStatusBlock) {
        self.taskModel.downloadStatusBlock(SPDownloadStatusCancel);
    }
    
    [self completeOperation];
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    _executing = NO;
    _finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end

static const void *k_sp_taskModelKey = "k_sp_taskModelKey";

@implementation NSURLSessionTask (SPTaskModel)

- (void)setSp_taskModel:(SPTaskModel *)taskModel {
    objc_setAssociatedObject(self, k_sp_taskModelKey, taskModel, OBJC_ASSOCIATION_ASSIGN);
}

- (SPTaskModel *)sp_taskModel {
    return objc_getAssociatedObject(self, k_sp_taskModelKey);
}

@end

static const void *k_sp_movieModelKey = "k_sp_movieModelKey";

@implementation NSURLSessionTask (SPMovieModel)

- (void)setSp_movieModel:(SPMovieModel *)sp_movieModel {
    objc_setAssociatedObject(self, k_sp_movieModelKey, sp_movieModel, OBJC_ASSOCIATION_ASSIGN);
}

- (SPMovieModel *)sp_movieModel {
    return objc_getAssociatedObject(self, k_sp_movieModelKey);
}

@end


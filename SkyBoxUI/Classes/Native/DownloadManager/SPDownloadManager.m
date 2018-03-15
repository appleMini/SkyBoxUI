//
//  SPDownloadManager.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/6.
//

#import "SPDownloadManager.h"
#import "SPDownloadOperation.h"
#import "SPDBTool.h"
#import "NSString+Hash.h"
#import "SPTaskModel.h"

@interface SPDownloadManager()<NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSURLSession *session;
/** 保存所有任务(注：用下载地址md5后作为key) */
@property (nonatomic, strong) NSMutableDictionary *downloadTasks;

- (void)startOperation:(SPTaskModel *)taskModel movieModel:(SPMovieModel *)movie;
@end

@implementation SPDownloadManager

#pragma -mark file
- (unsigned long long)downLoadLength:(NSURLSessionTask *)dataTask {
    SPTaskModel *taskModel = [dataTask sp_taskModel];
    if (!taskModel.localPath) {
        return 0;
    }
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:taskModel.localPath]) {
        
        return [[manager attributesOfItemAtPath:taskModel.localPath error:nil] fileSize];
    }
    
    return 0;
}

- (unsigned long long)totalLength:(NSURLSessionTask *)dataTask {
    SPTaskModel *taskModel = [dataTask sp_taskModel];
    SPMovieModel *movieModel = [dataTask sp_movieModel];
    if (movieModel) {
        movieModel = [SPDBTool fetchWithRemoteUrl:taskModel.downloadUrl];
        return movieModel.totalLength;
    }
    
    return 0;
}

// 文件的存放路径（tmp） 文件下载完成后，移动到 cache 路径下
- (NSString *)downloadPath:(NSURLSessionTask *)dataTask {
    SPTaskModel *taskModel = [dataTask sp_taskModel];
    SPMovieModel *movieModel = [dataTask sp_movieModel];
    
    if (taskModel.localPath) {
        return taskModel.localPath;
    }
    
    NSString *tmppath = NSTemporaryDirectory();
    NSString *moviePath = [tmppath stringByAppendingPathComponent:@"movies"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:moviePath isDirectory:&isDir] && isDir) {
        
    }else{
        [fileManager createDirectoryAtPath:moviePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *tmpMoviePath = [moviePath stringByAppendingPathComponent:[taskModel.downloadUrl lastPathComponent]];
    taskModel.localPath = tmpMoviePath;
    movieModel.localUrl = tmpMoviePath;
    
    //   NSLog(@"tmpMoviePath ====== %@", tmpMoviePath);
    return tmpMoviePath;
}

/**
 *  判断该文件是否下载完成
 */
- (BOOL)isCompletion:(NSURLSessionTask *)dataTask
{
    SPTaskModel *taskModel = [dataTask sp_taskModel];
    if (taskModel.totalLength <= 0 || [self totalLength:dataTask] <= 0) {
        //还没开始下载
        return NO;
    }
    
    NSInteger downLength = [self downLoadLength:dataTask];
    NSInteger total = taskModel.totalLength;
    
    return (downLength >= total);
}

//删除文件
- (void)deleteFile:(NSString *)filePath {
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:filePath]) {
        [filemanager removeItemAtPath:filePath error:nil];
    }
}
//移动文件
- (void)saveFile:(NSURLSessionTask *)dataTask {
    SPTaskModel *taskModel = [dataTask sp_taskModel];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:taskModel.localPath]) {
        NSString *cachespath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *moviePath = [cachespath stringByAppendingPathComponent:@"movies"];
        
        BOOL isDir = NO;
        if ([filemanager fileExistsAtPath:moviePath isDirectory:&isDir] && isDir) {
            
        }else{
            [filemanager createDirectoryAtPath:moviePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *cachesMoviePath = [moviePath stringByAppendingPathComponent:[taskModel.downloadUrl lastPathComponent]];
        
        [filemanager moveItemAtPath:taskModel.localPath toPath:cachesMoviePath error:nil];
        [self deleteFile:taskModel.localPath];
    }
}

#pragma -mark DownloadManager
+ (SPDownloadManager *)shareInstance {
    static SPDownloadManager *_downloadManager = nil;
    if (!_downloadManager) {
        _downloadManager = [[SPDownloadManager alloc] init];
    }
    
    return _downloadManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 4;
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 不能传self.queue
        self.session = [NSURLSession sessionWithConfiguration:config
                                                     delegate:self
                                                delegateQueue:nil];
    }
    return self;
}

- (NSMutableDictionary *)downloadTasks {
    if (!_downloadTasks) {
        _downloadTasks = [[NSMutableDictionary alloc] init];
    }
    
    return _downloadTasks;
}

- (void)addTaskModel:(SPTaskModel *)taskmodel {
    SPDownloadOperation *op = _downloadTasks[taskmodel.downloadUrl.md5String];
    if (op) {
        return;
    }
    
    //判断文件是否下载过
    SPMovieModel *movie = [SPDBTool fetchWithRemoteUrl:taskmodel.downloadUrl];
    if (!movie) {
        //还没有下载过文件
        movie = [[SPMovieModel alloc] init];
        movie.remoteUrl = taskmodel.downloadUrl;
        movie.movieTitle = [[taskmodel.downloadUrl lastPathComponent] stringByDeletingPathExtension];
        movie.isFinished = NO;
        [SPDBTool save:movie];
        
        taskmodel.status = SPDownloadStatusWaiting;
        
        [self startOperation:taskmodel movieModel:movie];
        return;
    }
    //再次打开app
    taskmodel.totalLength = movie.totalLength;
    taskmodel.localPath = movie.localUrl;
    taskmodel.status = SPDownloadStatusWaiting;
    [self startOperation:taskmodel movieModel:movie];
}

- (void)add:(NSString *)url {
    SPDownloadOperation *op = _downloadTasks[url.md5String];
    if (op) {
        return;
    }
    
    //判断文件是否下载过
    SPMovieModel *movie = [SPDBTool fetchWithRemoteUrl:url];
    if (!movie) {
        //还没有下载过文件
        movie = [[SPMovieModel alloc] init];
        movie.remoteUrl = url;
        movie.movieTitle = [[url lastPathComponent] stringByDeletingPathExtension];
        movie.isFinished = NO;
        [SPDBTool save:movie];
        
        SPTaskModel *taskModel = [[SPTaskModel alloc] init];
        taskModel.downloadUrl = url;
        taskModel.status = SPDownloadStatusNone;
        
        [self startOperation:taskModel movieModel:movie];
        return;
    }
}

- (void)startOperation:(SPTaskModel *)taskModel movieModel:(SPMovieModel *)movie {
    SPDownloadOperation *op = [[SPDownloadOperation alloc] initWithModel:taskModel movieModel:movie session:self.session];
    [self.downloadTasks setObject:op forKey:taskModel.downloadUrl.md5String];
    
    [self.queue addOperation:op];
}
- (void)suspendOperation:(NSString *)url {
    SPDownloadOperation *op = _downloadTasks[url.md5String];
    if (!op) {
        return;
    }
    
    [op suspend];
}
- (void)resumeOperation:(NSString *)url {
    SPDownloadOperation *op = _downloadTasks[url.md5String];
    if (!op) {
        return;
    }
    
    [op resume];
}
- (void)cancelOperation:(NSString *)url {
    SPDownloadOperation *op = _downloadTasks[url.md5String];
    if (!op) {
        return;
    }
    
    [op cancel];
    [_downloadTasks removeObjectForKey:url.md5String];
}

- (void)cancelAllOperation {
    NSArray <SPDownloadOperation *>*ops = [_downloadTasks allValues];
    for (SPDownloadOperation *op in ops) {
        [op cancel];
        [_downloadTasks removeObjectForKey:op.taskModel.downloadUrl];
    }
}
#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler{
    
    OSStatus err;
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    SecTrustResultType  trustResult = kSecTrustResultInvalid;
    NSURLCredential *credential = nil;
    
    //获取服务器的trust object
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"" ofType:@"cer"];
    NSData *data = [NSData dataWithContentsOfFile:cerPath];
    SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) data);
    NSArray *trustedCerArr = @[(__bridge_transfer id)certificate];
    
    //将读取的证书设置为serverTrust的根证书
    err = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)trustedCerArr);
    
    if(err == noErr){
        //通过本地导入的证书来验证服务器的证书是否可信，如果将SecTrustSetAnchorCertificatesOnly设置为NO，则只要通过本地或者系统证书链任何一方认证就行
        err = SecTrustEvaluate(serverTrust, &trustResult);
    }
    
    if (err == errSecSuccess && (trustResult == kSecTrustResultProceed || trustResult == kSecTrustResultUnspecified)){
        //认证成功，则创建一个凭证返回给服务器
        disposition = NSURLSessionAuthChallengeUseCredential;
        credential = [NSURLCredential credentialForTrust:serverTrust];
    }
    else{
        disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    }
    
    //回调凭证，传递给服务器
    if(completionHandler){
        completionHandler(disposition, credential);
    }
}

#pragma mark - 代理
#pragma mark NSURLSessionDataDelegate
/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    SPTaskModel *taskModel = [dataTask sp_taskModel];
    SPMovieModel *movieModel = [dataTask sp_movieModel];
    
    if (!taskModel.stream) {
        // 创建流
        NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:[self downloadPath:dataTask] append:YES];
        taskModel.stream = stream;
    }
    
    // 打开流
    [taskModel.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + [self downLoadLength:dataTask];
    taskModel.totalLength = totalLength;
    
    movieModel.totalLength = totalLength;
    [SPDBTool save:movieModel];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    SPTaskModel *taskModel = [dataTask sp_taskModel];
    // 写入数据
    [taskModel.stream write:data.bytes maxLength:data.length];
    // 下载进度
    NSUInteger receivedSize = [self downLoadLength:dataTask];
    NSUInteger expectedSize = taskModel.totalLength;
    CGFloat progress = 1.0 * receivedSize / expectedSize;
    
    taskModel.progress = progress;
    if (taskModel.progressBlock) {
        taskModel.progressBlock(receivedSize, expectedSize, progress);
    }
}

/**
 * 请求完毕
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    SPTaskModel *taskModel = [task sp_taskModel];
    SPMovieModel *movieModel = [task sp_movieModel];
    
    if (!taskModel) return;
    
    BOOL isCompletion = [self isCompletion:task];
    if (isCompletion) {
        // 下载完成
        taskModel.status = SPDownloadStatusCompleted;
        if (taskModel.downloadStatusBlock) {
            taskModel.downloadStatusBlock(SPDownloadStatusCompleted);
        }
        
        //保存数据库，并移动文件
        movieModel.isFinished = YES;
        [SPDBTool save:movieModel];
        
    } else if (!isCompletion){
        //清除缓存
        [SPDBTool deleteData:movieModel];
        [self deleteFile:taskModel.localPath];
        
        // 下载失败
        taskModel.status = SPDownloadStatusFailed;
        if (taskModel.downloadStatusBlock) {
            taskModel.downloadStatusBlock(SPDownloadStatusFailed);
        }
    }
    
    // 关闭流
    [taskModel.stream close];
    taskModel.stream = nil;
    
    SPDownloadOperation *op = _downloadTasks[taskModel.downloadUrl.md5String];
    if (!op) {
        return;
    }
    
    [op completeOperation];
    [_downloadTasks removeObjectForKey:taskModel.downloadUrl.md5String];
}
@end

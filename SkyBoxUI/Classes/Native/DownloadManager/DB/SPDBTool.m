//
//  SPDBTool.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/4.
//

#import "SPDBTool.h"
#import <FMDB/FMDB.h>

#define sqliteFilePath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"SkyboxUI.sqlite"]
@implementation SPDBTool

+ (void)initialize
{
    // 打开数据库
    FMDatabase *_db = [FMDatabase databaseWithPath:sqliteFilePath];

    // 创建表
    if ([_db open]) {
        NSString *sql = @"CREATE TABLE IF NOT EXISTS sp_movies_list  (id INTEGER PRIMARY KEY AUTOINCREMENT, movieTitle TEXT, remoteUrl TEXT, localUrl TEXT ,bps TEXT,totalLength INTEGER, isFinished INTEGER NOT NULL);";
        ;
        if([_db executeUpdate:sql])
        {
            NSLog(@"创建表成功");
        }
        
        [_db close];
    }
}

//存入数据
+ (void)save:(SPMovieModel *)movie {
    SPMovieModel *model = [self fetchWithTitle:movie.movieTitle];
    if (model) {
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:sqliteFilePath];
        [queue inDatabase:^(FMDatabase *db) {
            if ([db executeUpdate:@"UPDATE sp_movies_list SET remoteUrl = ?, localUrl = ?, bps = ?, totalLength = ?, isFinished = ? where movieTitle = ?;", movie.remoteUrl, movie.localUrl, movie.bps, [NSNumber numberWithLong:movie.totalLength], [NSNumber numberWithBool:movie.isFinished], movie.movieTitle]) {
                NSLog(@"更新成功！");
            }
            
            [db close];
        }];

    }else{
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:sqliteFilePath];
        [queue inDatabase:^(FMDatabase *db) {
            if ([db executeUpdate:@"INSERT INTO sp_movies_list (movieTitle, remoteUrl, localUrl, bps,totalLength, isFinished) VALUES (?, ? , ? , ?, ?, ?);", movie.movieTitle, movie.remoteUrl ,movie.localUrl, movie.bps, [NSNumber numberWithLong:movie.totalLength],[NSNumber numberWithBool:movie.isFinished]]) {
                NSLog(@"保存成功！");
            }
            
            [db close];
        }];
    }
}
//删除数据
+ (void)deleteData:(SPMovieModel *)movie {
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:sqliteFilePath];
    [queue inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"delete from sp_movies_list where movieTitle = ?;", movie.movieTitle]) {
            NSLog(@"删除成功");
        }
        
        [db close];
    }];
}

+ (void)deleteAll {
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:sqliteFilePath];
    [queue inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"delete from sp_movies_list;"]) {
            NSLog(@"删除成功");
        }
        
        [db close];
    }];
}

+ (SPMovieModel *)fetchWithRemoteUrl:(NSString *)remoteUrl {
    dispatch_semaphore_t _sema = dispatch_semaphore_create(0);
    __block SPMovieModel *movie = nil;
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:sqliteFilePath];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM sp_movies_list where remoteUrl = ?;", remoteUrl];
        
        while ([set next]) {
            movie = [[SPMovieModel alloc] init];
            movie.movieTitle = [set stringForColumn:@"movieTitle"];
            movie.remoteUrl = [set stringForColumn:@"remoteUrl"];
            movie.localUrl = [set stringForColumn:@"localUrl"];
            movie.bps = [set stringForColumn:@"bps"];
            movie.isFinished = [set boolForColumn:@"isFinished"];
            movie.totalLength = [set longForColumn:@"totalLength"];
            
            break;
        }
        
        [db close];
        dispatch_semaphore_signal(_sema);
    }];
    
    dispatch_semaphore_wait(_sema, DISPATCH_TIME_FOREVER);
    
    return movie;
}
+ (SPMovieModel *)fetchWithTitle:(NSString *)title {

    dispatch_semaphore_t _sema = dispatch_semaphore_create(0);
    __block SPMovieModel *movie = nil;
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:sqliteFilePath];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM sp_movies_list where movieTitle = ?;", title];
        
        while ([set next]) {
            movie = [[SPMovieModel alloc] init];
            movie.movieTitle = [set stringForColumn:@"movieTitle"];
            movie.remoteUrl = [set stringForColumn:@"remoteUrl"];
            movie.localUrl = [set stringForColumn:@"localUrl"];
            movie.bps = [set stringForColumn:@"bps"];
            movie.isFinished = [set boolForColumn:@"isFinished"];
            movie.totalLength = [set longForColumn:@"totalLength"];
            
            break;
        }
        
        [db close];
        dispatch_semaphore_signal(_sema);
    }];
    
    dispatch_semaphore_wait(_sema, DISPATCH_TIME_FOREVER);
    
    return movie;
}
+ (SPMovieModel *)fetchWithLocalUrl:(NSString *)localUrl {
    dispatch_semaphore_t _sema = dispatch_semaphore_create(0);
    __block SPMovieModel *movie = nil;
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:sqliteFilePath];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM sp_movies_list where localUrl = ?;", localUrl];
        
        while ([set next]) {
            movie = [[SPMovieModel alloc] init];
            movie.movieTitle = [set stringForColumn:@"movieTitle"];
            movie.remoteUrl = [set stringForColumn:@"remoteUrl"];
            movie.localUrl = [set stringForColumn:@"localUrl"];
            movie.bps = [set stringForColumn:@"bps"];
            movie.isFinished = [set boolForColumn:@"isFinished"];
            movie.totalLength = [set longForColumn:@"totalLength"];
            
            break;
        }
        
        [db close];
        dispatch_semaphore_signal(_sema);
    }];
    
    dispatch_semaphore_wait(_sema, DISPATCH_TIME_FOREVER);
    
    return movie;
}

@end

@implementation SPMovieModel

- (double)progress {
    if (self.totalLength <= 0.0) {
        return 0.0;
    }
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:self.localUrl]) {
        
        return 1.0 * [[manager attributesOfItemAtPath:self.localUrl error:nil] fileSize] / self.totalLength;
    }
    
    return 0.0;
}

@end

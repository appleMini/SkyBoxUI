//
//  SPDBTool.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/4.
//

#import <Foundation/Foundation.h>

@class SPMovieModel;
@interface SPDBTool : NSObject

//存入数据
+ (void)save:(SPMovieModel *)movie;
//删除数据
+ (void)deleteData:(SPMovieModel *)movie;
//删除全部数据
+ (void)deleteAll;

+ (SPMovieModel *)fetchWithRemoteUrl:(NSString *)remoteUrl;
+ (SPMovieModel *)fetchWithTitle:(NSString *)title;
+ (SPMovieModel *)fetchWithLocalUrl:(NSString *)localUrl;
@end

@interface SPMovieModel : NSObject

@property (copy, nonatomic) NSString *movieTitle;
@property (copy, nonatomic) NSString *remoteUrl;
@property (copy, nonatomic) NSString *localUrl;
@property (assign, nonatomic) BOOL    isFinished;
@property (assign, nonatomic) long    totalLength;
@property (copy, nonatomic) NSString *bps;
@property (nonatomic, assign, readonly) double  progress;

@end

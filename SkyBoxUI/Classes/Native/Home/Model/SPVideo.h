//
//  SPVideo.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import <Foundation/Foundation.h>

@interface SPVideo : NSObject

@property (nonatomic, copy) NSString *mid;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *videoWidth;
@property (nonatomic, copy) NSString *videoHeight;
@property (nonatomic, copy) NSString *thumbnail_uri;
@property (nonatomic, copy) NSString *rcg_type;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *remote_id;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) BOOL   isFavourite;
@property (nonatomic, assign) BOOL   isDelete;

@property (nonatomic, assign) DataSourceType  dataSource;
@end

//
//  SPMuliteViewController.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/15.
//

#import <UIKit/UIKit.h>
#import "SPBaseViewController.h"
typedef enum : NSUInteger {
    LocalFilesType = 0,
    VRVideosType,
    FavoriteVideosType,
    HistoryVideosType,
    AirScreenType
} DataSourceType;

@interface SPMuliteViewController : SPBaseViewController

- (instancetype)initWithDataSource:(NSArray *)data type:(DataSourceType)type displayType:(DisplayType)show;
- (instancetype)initWithType:(DataSourceType)type displayType:(DisplayType)show;
- (void)didFinishRequest:(NSArray *)arr;
- (NSString *)cellIditify;
@end

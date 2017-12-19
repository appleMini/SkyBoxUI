//
//  SPMuliteViewController.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/15.
//

#import <UIKit/UIKit.h>
#import "SPBaseViewController.h"

typedef enum : NSUInteger {
    TableViewType,
    CollectionViewType,
} DisplayType;

typedef enum : NSUInteger {
    LocalFilesType,
    VRVideosType,
    FavoriteVideosType,
    HistoryVideosType
} DataSourceType;

@interface SPMuliteViewController : SPBaseViewController

- (NSString *)cellIditify;
@end

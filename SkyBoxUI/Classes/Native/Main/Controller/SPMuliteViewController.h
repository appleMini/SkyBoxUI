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

typedef void (^RefreshBlock) (NSString *dataStr);

@interface SPMuliteViewController : SPBaseViewController

@property (nonatomic, copy) RefreshBlock refreshBlock;

- (instancetype)initWithType:(DataSourceType)type displayType:(DisplayType)show;
- (void)didFinishRequest:(NSArray *)arr;
- (NSString *)cellIditify;
@end

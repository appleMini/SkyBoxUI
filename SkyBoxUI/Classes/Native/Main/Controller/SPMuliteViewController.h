//
//  SPMuliteViewController.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/15.
//

#import <UIKit/UIKit.h>
#import "SPBaseViewController.h"

@interface SPMuliteViewController : SPBaseViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, copy) NSArray *dataArr;

- (instancetype)initWithDataSource:(NSArray *)data type:(DataSourceType)type displayType:(DisplayType)show;
- (instancetype)initWithType:(DataSourceType)type displayType:(DisplayType)show;
- (void)didFinishRequest:(NSArray *)arr;
- (NSString *)cellIditify;

- (void)reload;
- (void)doRefreshSenior;
@end

@interface SPAlertViewController : UIAlertController
@end

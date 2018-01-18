//
//  SPNetworkViewController.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/18.
//

#import <UIKit/UIKit.h>
#import "SPBaseViewController.h"

@interface SPNetworkViewController : SPBaseViewController

- (instancetype)initWithHeadView:(NSArray <SPCmdAddDevice *> *)devices;
- (instancetype)initWithDataSource:(NSArray *)data  displayType:(DisplayType)show;
@end


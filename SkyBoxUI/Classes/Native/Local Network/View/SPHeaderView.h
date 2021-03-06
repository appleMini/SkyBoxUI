//
//  SPHeaderView.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/26.
//

#import <UIKit/UIKit.h>

@interface SPHeaderView : UIView
@property (nonatomic, strong) SPCmdAddDevice *device;

- (void)cleanHeadViews;
- (void)setDevices:(NSMutableArray<SPCmdAddDevice *> *)devices;
- (NSArray <NSString *>*)getDevices;
@end


@interface SPDeviceButton : UIButton
@end

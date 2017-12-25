//
//  SPBaseViewController.h
//  SkyBoxUitl
//
//  Created by Shao shuqiang on 2017/11/29.
//  Copyright © 2017年 Shao shuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define  adjustsScrollViewInsets(scrollView)\
do {\
_Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")\
if ([scrollView respondsToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {\
NSMethodSignature *signature = [UIScrollView instanceMethodSignatureForSelector:@selector(setContentInsetAdjustmentBehavior:)];\
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];\
NSInteger argument = 2;\
invocation.target = scrollView;\
invocation.selector = @selector(setContentInsetAdjustmentBehavior:);\
[invocation setArgument:&argument atIndex:2];\
[invocation retainArguments];\
[invocation invoke];\
}\
_Pragma("clang diagnostic pop")\
} while (0)


#define  UITOUNITYNOTIFICATIONNAME  @"AcrossDifferentNativeNotify_UI_UNITY"
#define  UNITYTOUINOTIFICATIONNAME  @"AcrossDifferentNativeNotify_UNITY_UI"
#define  SCANOVERUITOUNITYNOTIFICATIONNAME  @"SCANOVERNativeNotify_UI_UNITY"

typedef void (^RefreshBlock) (NSString *dataStr);

@interface SPBaseViewController : UIViewController

@property (nonatomic, copy) RefreshBlock refreshBlock;
@property (nonatomic, strong) UILabel *titleLabel;

- (instancetype)initWithSomething;
- (NSString *)titleOfLabelView;
- (NSArray *)leftNaviItem;
- (NSArray *)rightNaviItem;
- (void)setupNaviView;
- (void)refresh;
- (void)releaseAction;
- (void)showOrHiddenTopView:(BOOL)show;
@end

@interface SPCmdEvent : NSObject

@property (nonatomic, assign) void *callBack;
@property (nonatomic, copy) NSString *method;

- (instancetype)initWithEventName:(NSString *)name callBack:(void *)call;
@end

typedef enum : NSUInteger
{
    Disconnected = 0,
    Connected,
    Ready,
} EWebSocketState;

@interface SPAirscreen : NSObject

@property (nonatomic, assign) BOOL udp;
@property (nonatomic, copy) NSString *project;
@property (nonatomic, copy) NSString *command;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *computerId;
@property (nonatomic, copy) NSString *computerName;
@property (nonatomic, copy) NSString *ip;
@property (nonatomic, copy) NSArray<NSString *> *ips;
@property (nonatomic, copy) NSString *port;

@end

@interface SPCmdBase : NSObject
@property (nonatomic, copy) NSString *command;
@end

@interface SPCmdAddDevice : SPCmdBase
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, assign) BOOL   showLoginCode;
@end

@interface SPCmdAddDeviceResult : SPCmdBase
@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) BOOL isLoggedIn;
@end

@class SPCmdMediaInfo;
@interface SPMediaListResult : SPCmdBase
@property (nonatomic, copy) NSArray *list;

@end

@interface SPSubtitleInfo : NSObject
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *url;

@end

@interface SPCmdMediaInfo : NSObject
@property (nonatomic, assign) int      defaultVRSetting;
@property (nonatomic, assign) double   duration;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int width;
@property (nonatomic, copy) NSString *mid;
@property (nonatomic, copy) NSString *lastModified;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *orientDegree;
@property (nonatomic, copy) NSString *ratioTypeFor2DScreen;
@property (nonatomic, copy) NSString *rotationFor2DScreen;
@property (nonatomic, assign) float size;
@property (nonatomic, copy) NSArray<SPSubtitleInfo *> *subtitles;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, assign) int thumbnailHeight;
@property (nonatomic, assign) int thumbnailWidth;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) int userVRSetting;

@end


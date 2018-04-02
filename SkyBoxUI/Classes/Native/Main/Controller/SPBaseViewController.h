//
//  SPBaseViewController.h
//  SkyBoxUitl
//
//  Created by Shao shuqiang on 2017/11/29.
//  Copyright © 2017年 Shao shuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPBackgrondView.h"
#import <AFNetworking/AFNetworking.h>

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

#define  CHANGEDISPALYTYPENOTIFICATIONNAME  @"ChangeDispalyTypeNativeNotify_UI"

#ifndef  UPDATETHUMBNAIL_NOTIFICATION
    #define  UPDATETHUMBNAIL_NOTIFICATION  @"UpdateThumbnailNotify_UI_UTIL"
#endif

#ifndef  UPDATELOCALVIDEOSNOTIFICATIONNAME
#define  UPDATELOCALVIDEOSNOTIFICATIONNAME  @"UpdateLocalVideosNativeNotify_UI"
#endif
typedef enum : NSUInteger {
    TableViewType,
    CollectionViewType,
    UnknownType
} DisplayType;

typedef enum : NSUInteger {
    LocalFilesType = 0,
    VRVideosType,
    FavoriteVideosType,
    HistoryVideosType,
    AirScreenType,
    DLANType
} DataSourceType;

typedef enum : NSUInteger {
    CommomStatus,
    DeleteStatus
} SPCellStatus;

typedef void (^CompleteBlock) (void);
typedef void (^RefreshBlock) (NSString *dataStr);
typedef void (^NetStateBlock) (AFNetworkReachabilityStatus status);

@interface SPBaseViewController : UIViewController

@property (nonatomic, strong) UIViewController *mainVC;
@property (nonatomic, copy) CompleteBlock completeBlock;
@property (nonatomic, copy) RefreshBlock refreshBlock;
@property (nonatomic, copy) NetStateBlock netStateBlock;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) SPBackgrondView *emptyView;
@property (nonatomic, assign) BOOL refreshEnable;
@property (nonatomic, assign) BOOL isShow;

- (instancetype)initWithSomething;
- (UIView *)customTitleView;
- (NSString *)titleOfLabelView;
- (NSArray *)leftNaviItem;
- (NSArray *)rightNaviItem;
- (NSDictionary *)params;
- (BOOL)showNavigatinBar;
- (void)setupNaviView;
//重新装载之后，检测界面更新
- (void)viewWillToChanged;
- (void)refresh;
- (void)releaseAction;
- (void)showOrHiddenTopView:(BOOL)show;
- (void)showTopViewAlpha:(CGFloat)alpha;
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
@property (nonatomic, copy) NSString *iconURL;
@property (nonatomic, copy) NSString *ObjIDStr;
@property (nonatomic, copy) NSString *parentID;
@property (nonatomic, assign) BOOL   showLoginCode;
@end

@interface SPCmdFolderDevice : SPCmdAddDevice
@property (nonatomic, copy) NSString    *restricted;
@property (nonatomic, copy) NSString    *storageUsed;
@end

@interface SPCmdAlbumDevice : SPCmdAddDevice
@property (nonatomic, copy) NSString    *album;
@property (nonatomic, copy) NSString    *protocolInfo;
@property (nonatomic, copy) NSString    *resolution;
@end

@interface SPCmdVideoDevice : SPCmdAddDevice
@property (nonatomic, copy) NSString    *date;
@property (nonatomic, copy) NSString    *protocolInfo;
@property (nonatomic, copy) NSString    *resolution;
@property (nonatomic, copy) NSString    *size;
@property (nonatomic, copy) NSString    *bitrate;
@property (nonatomic, copy) NSString    *duration;
@property (nonatomic, copy) NSString    *nrAudioChannels;
@property (nonatomic, copy) NSString    *sampleFrequency;
@property (nonatomic, copy) NSString    *videoUrl;
@end

@interface SPCmdMusicDevice : SPCmdAddDevice
@property (nonatomic, copy) NSString    *album;
@property (nonatomic, copy) NSString    *protocolInfo;
@property (nonatomic, copy) NSString    *resolution;
@end

@interface SPCmdAddDeviceResult : SPCmdBase
@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) BOOL isLoggedIn;
@end

@class SPCmdMediaInfo;
@interface SPMediaListResult : SPCmdBase
@property (nonatomic, copy) NSArray *list;

@end

@interface SPCmdReadyMediaInfo : SPCmdBase
@property (nonatomic, copy) NSDictionary *media;

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


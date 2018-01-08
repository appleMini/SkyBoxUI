//
//  SPBackgrondView.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/1/8.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    NoVideos,
    NoWifi,
    NoLocalMediaServers,
    NoFiles,
    NoFavorite,
    NoHistory,
} SPBackgroundType;
@interface SPBackgrondView : UIView

- (instancetype)initWithFrame:(CGRect)frame backgroundType:(SPBackgroundType)type;
@end

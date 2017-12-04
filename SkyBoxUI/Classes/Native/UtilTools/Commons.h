//
//  Commons.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/4.
//

#import <Foundation/Foundation.h>

#define kEventType      @"kEventTypeNotification"
#define kTopViewController      @"kTopViewControllerNotification"

typedef enum : NSUInteger {
    nativeToUnityType = 1,
    testType = 2,
} ResponderType;

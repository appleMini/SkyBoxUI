//
//  UIResponder+YYIMCategory.m
//  YonyouIM
//
//  Created by litfb on 15/2/10.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "UIResponder+SPCategory.h"

@implementation UIResponder (SPCategory)

- (void)bubbleEventWithUserInfo:(NSDictionary *)userInfo {
    [[self nextResponder] bubbleEventWithUserInfo:userInfo];
}

- (void)bubbleLongPressWithUserInfo:(NSDictionary *)userInfo {
    [[self nextResponder] bubbleLongPressWithUserInfo:userInfo];
}

@end

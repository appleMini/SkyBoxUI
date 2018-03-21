//
//  SPAirScreenManager.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/2/5.
//

#import "SPAirScreenManager.h"
#import "SPVideo.h"

@interface SPAirScreenManager() {
    BOOL _socketOpened;
}

@property (nonatomic, strong) CADisplayLink *displink;
@property (nonatomic, strong) NSTimer *sendTimer;
@property (nonatomic, copy) ResultBlock completeBlock;

@end

@implementation SPAirScreenManager

static SPAirScreenManager *_manager = nil;

+ (instancetype)shareAirScreenManager {
    if (!_manager) {
        _manager = [[SPAirScreenManager alloc] init];
    }
    
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CADisplayLink *displink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tickSocketIO_MainThread)];
        [displink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.displink = displink;
    }
    return self;
}

- (void)tickSocketIO_MainThread {
    if (_socketOpened) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"TickSocketIO"}];
    }
}

- (void)stopSearch {
    if (_socketOpened) {
        [self.sendTimer invalidate];
        self.sendTimer = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"DestroySKYBOX"}];
    }
}
- (void)closeAirscreen {
    [self.sendTimer invalidate];
    self.sendTimer = nil;
    
    if (_socketOpened) {
//        _socketOpened = NO;
//        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"DestroySKYBOX"}];
    }
}

- (void)releaseAction {
    [self closeAirscreen];
    
    //    [self.displink invalidate];
    //    self.displink = nil;
    
    [self.sendTimer invalidate];
    self.sendTimer = nil;
    
    //    _manager = nil;
}

- (void)startupAirscreen {
    if (!_socketOpened) {
        _socketOpened = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"StartSKYBOX"}];
    }
}

- (void)startupAndSendPackage {
    if (!_socketOpened) {
        [self startupAirscreen];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sendTimer fire];
    });
}

- (NSTimer *)sendTimer {
    if (!_sendTimer) {
        if (@available(iOS 10.0, *)) {
            _sendTimer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
                if (_socketOpened) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"UdpSendTo"}];
                }
            }];
        } else {
            // Fallback on earlier versions
            _sendTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(sendUdpPackage) userInfo:nil repeats:YES];
        }
        
        [[NSRunLoop currentRunLoop] addTimer:_sendTimer forMode:NSRunLoopCommonModes];
    }
    
    return _sendTimer;
}

- (void)sendUdpPackage {
    if (_socketOpened) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"UdpSendTo"}];
    }
}

- (void)connectServer:(SPAirscreen *)airscreen  complete:(ResultBlock)block {
    if (_socketOpened && airscreen) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"WebSocketConnect", @"airscreen" : airscreen}];
        
        if (block) {
            _completeBlock = [block copy];
        }
    }
    
}

- (void)disConnectServer {
    if (_socketOpened) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UITOUNITYNOTIFICATIONNAME object:nil userInfo:@{@"method" : @"WebSocketDisConnect"}];
    }
}

- (void)dealloc {
    
}
@end


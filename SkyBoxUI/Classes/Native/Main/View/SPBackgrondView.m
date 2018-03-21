//
//  SPBackgrondView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/1/8.
//

#import "SPBackgrondView.h"
#import <AVFoundation/AVFoundation.h>
#import "UILabel+SPAttri.h"

@interface SPBackgrondView()

@property (nonatomic, strong) NSURL *movieUrl;
@property (nonatomic, strong) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) SPBackgroundType type;
@property (weak, nonatomic) IBOutlet UIImageView *iconV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconVHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconVWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconVCenterYConstraint;

@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@end

@implementation SPBackgrondView

- (instancetype)initWithFrame:(CGRect)frame backgroundType:(SPBackgroundType)type {
    self =  [[[UINib nibWithNibName:@"SPBackgrondView" bundle:[Commons resourceBundle]] instantiateWithOwner:nil options:nil] firstObject];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        _type = type;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.iconVCenterYConstraint.constant = [SPDeviceUtil isiPhoneX] ? -(34 + 88 + 15 + 20)/2.0 : -(84 + 15 + 20) / 2.0;
    
    self.noticeLabel.font = [UIFont fontWithName:@"Calibri" size:15];
    self.noticeLabel.textColor = [SPColorUtil getHexColor:@"#6a6c75"];
    switch (_type) {
        case NoVideos:
        {
            self.iconV.image = [Commons getPdfImageFromResource:@"Empty_icon_VRvideos"];
            self.iconVWidthConstraint.constant = 153;
            self.iconVHeightConstraint.constant = 113;
            self.noticeLabel.text = @"NO VR VIDEOS";
        }
            break;
        case NoWifi:
        {
            self.iconV.image = [Commons getPdfImageFromResource:@"Empty_icon_connection"];
            self.iconVWidthConstraint.constant = 158;
            self.iconVHeightConstraint.constant = 118;
            self.noticeLabel.text = @"NO CONNECTIONS";
        }
            break;
        case NoFiles:
        {
            self.iconV.image = [Commons getPdfImageFromResource:@"Empty_icon_file"];
            self.iconVWidthConstraint.constant = 170;
            self.iconVHeightConstraint.constant = 116;
            self.noticeLabel.text = @"NO FILES";
        }
            break;
        case NoHistory:
        {
            self.iconV.image = [Commons getPdfImageFromResource:@"Empty_icon_history"];
            self.iconVWidthConstraint.constant = 150;
            self.iconVHeightConstraint.constant = 150;
            self.noticeLabel.text = @"NO HISTORY";
        }
            break;
        case NoFavorite:
        {
            self.iconV.image = [Commons getPdfImageFromResource:@"Empty_icon_favorite"];
            self.iconVWidthConstraint.constant = 166;
            self.iconVHeightConstraint.constant = 139;
            self.noticeLabel.text = @"NO FAVORITES";
        }
            break;
        case NoLocalMediaServers:
        {
            self.iconV.image = [Commons getPdfImageFromResource:@"Empty_icon_server"];
            self.iconVWidthConstraint.constant = 150;
            self.iconVHeightConstraint.constant = 125;
            self.noticeLabel.text = @"NO LOCAL MEDIA SERVERS";
        }
            break;
        case NoAirScreenResult:
        {
            self.movieUrl = [Commons getMovieFromResource:@"AirScreen_empty" extension:@"mp4"];
            [self setMediaPlayer];
            
            //监听AVPlayerItem状态
            [self addObserverToPlayerItem];
            [self addNotification];//广播监听播放状态
            
            UIFont *boldFont = [UIFont fontWithName:@"Calibri-Bold" size:15.0];
            UIFont *regularFont = [UIFont fontWithName:@"Calibri" size:15.0];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"ADD VIDEOS TO " attributes:@{NSFontAttributeName : regularFont, NSForegroundColorAttributeName:[SPColorUtil getHexColor:@"#cccccc"]}]];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"SKYBOX" attributes:@{NSFontAttributeName : boldFont, NSForegroundColorAttributeName:[SPColorUtil getHexColor:@"#ffffff"]}]];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" ON YOUR COMPUTER" attributes:@{NSFontAttributeName : regularFont, NSForegroundColorAttributeName:[SPColorUtil getHexColor:@"#cccccc"]}]];
            self.noticeLabel.attributedText = [attributedString copy];
        }
            break;
        default:
            break;
    }
}

- (void)dealloc{
    if (_type == NoAirScreenResult) {
        [self.player.currentItem cancelPendingSeeks];
        [self.player.currentItem.asset cancelLoading];
        
        [self removeObserverFromPlayerItem:self.player.currentItem];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (AVPlayerLayer *)playerLayer {
    if(!_playerLayer){
        AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer = layer;
    }
    
    return _playerLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_player) {
        CGFloat y = (self.frame.size.height - (20 + 15)) / 2 + 84/2 - SCREEN_WIDTH * (1.0 * 360 / 750);
        CGRect frame = self.playerLayer.frame;
        frame.origin.y = y;
        self.playerLayer.frame = frame;
        
        frame = self.noticeLabel.frame;
        frame.origin.y = self.playerLayer.frame.origin.y + self.playerLayer.frame.size.height + 20;
        self.noticeLabel.frame = frame;
    }
}

- (void)setMediaPlayer{
    //创建播放器层
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * (1.0 * 360 / 750));
    [self.layer insertSublayer:self.playerLayer atIndex:0];
}

#pragma mark - set/get
- (AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem = [self getPlayItem:self.movieUrl];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")){
            //增加下面这行可以解决iOS10兼容性问题了
            _player.automaticallyWaitsToMinimizeStalling = NO;
        }
        _player.volume = 0.5;
    }
    return _player;
}

#pragma -mark 设置AVPlayerItem
- (AVPlayerItem *)getPlayItem:(NSURL *)URL {
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:URL];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = YES;
    }
    return playerItem;
}

#pragma mark - 通知
//给AVPlayerItem添加播放完成通知
- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}

// 播放完成通知
- (void)playbackFinished:(NSNotification *)notification{
    //     NSLog(@"视频播放完成.");
    // 播放完成后重复播放
    // 跳到最新的时间点开始播放
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player play];
}

/**
 *  给AVPlayer添加监控
 *  @param player AVPlayer对象
 */
//- (void)addObserverToPlayer:(AVPlayer *)player{
//    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
//    [player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//}

/**
 *  给AVPlayerItem添加监控
 */
- (void)addObserverToPlayerItem{
    
    AVPlayerItem *playerItem = self.player.currentItem;
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //监听播放的区域缓存是否为空
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //缓存可以播放的时候调用
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    if(playerItem){
        [playerItem removeObserver:self forKeyPath:@"status"];
        [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    
    [self.player removeObserver:self forKeyPath:@"rate"];
}
/**
 *  通过KVO监控播放器状态
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status= [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerItemStatusReadyToPlay){
            //     NSLog(@"开始播放。。。。。。。。");
            //            [self startPlayer:self.currentTime];
            [self.player play];
        }else if(status == AVPlayerItemStatusUnknown){
            //     NSLog(@"%@",@"AVPlayerItemStatusUnknown");
        }else if (status == AVPlayerItemStatusFailed){
            //     NSLog(@"%@",@"AVPlayerItemStatusFailed");
            //     NSLog(@"%@",self.player.currentItem.error);
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        //     NSLog(@"缓冲：%.2f",totalBuffer);
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        //     NSLog(@"playbackBufferEmpty");
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        //     NSLog(@"playbackLikelyToKeepUp");
    }
}

#pragma -mark 播放器开始

- (void)startPlayer:(NSTimeInterval)time {
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentItem.duration.timescale) completionHandler:^(BOOL finished) {
        if (finished) {
            [self.player play];
        }
    }];
}
@end


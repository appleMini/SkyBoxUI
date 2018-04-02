//
//  SPSwitchBar.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/11.
//

#import "SPSwitchBar.h"
#define LargeHeight      kWSCALE*94
#define SmallItem        kWSCALE*94

#define UnderLineItem    kWSCALE*60

#define CBGItem          kWSCALE*94
#define CSamllItem       kWSCALE*30
#define WSpace           kWSCALE*80
#define BottomSpace      kHSCALE*20
#define UpperSpace       kHSCALE*8
#define leadingSpace     kWSCALE*0

@interface SPSwitchBar() {
    BOOL _isHidden;
    CGFloat _dx;
    CGFloat _baseWidth;
    
    BOOL _hiddenLine;
    CGFloat _lineAlpha;
}

@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *leftBtn_active;

@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIButton *rightBtn_active;

@property (nonatomic, strong) UIButton *centerBtn;
@property (nonatomic, strong) UIButton   *centerVR;
@property (nonatomic, strong) UIImageView   *centerBg;
@property (nonatomic, strong) UIView   *underLine;

@property (nonatomic, assign) BOOL    animation;
@end

@implementation SPSwitchBar
SPSingletonM(SPSwitchBar)

#pragma -mark
- (BOOL)isHidden {
    return _isHidden;
}

- (void)hiddenWithAnimation {
    if (_isHidden) {
        return;
    }
    
    _isHidden = YES;
    CGRect frame = self.frame;
    frame.origin.y += (LargeHeight + 5);
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}
- (void)showWithAnimation {
    if (!_isHidden) {
        return;
    }
    
    _isHidden = NO;
    self.hidden = NO;
    [[self superview] bringSubviewToFront:self];
    CGRect frame = self.frame;
    frame.origin.y -= (LargeHeight + 5);
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma -mark init
- (instancetype)init
{
    CGFloat y = [SPDeviceUtil isiPhoneX] ? (SCREEN_HEIGHT - 5 - LargeHeight) : (SCREEN_HEIGHT - LargeHeight);
    self = [self initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, LargeHeight)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _animation = YES;
        _lineAlpha = 0.25;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _animation = YES;
        _selectIndex = 0;
        [self setupViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_isHidden) {
        return;
    }
    
    CGFloat y = [SPDeviceUtil isiPhoneX] ? (SCREEN_HEIGHT - 20 - LargeHeight) : (SCREEN_HEIGHT - LargeHeight);
    self.frame = CGRectMake(0, y, SCREEN_WIDTH, LargeHeight);
}

- (CGFloat)fixBottomLine:(CGFloat)x baseWidth:(CGFloat)width {
    CGFloat scale = 1.0 * (x / width);
    return scale;
}

- (void)hiddenLine:(BOOL)isHidden {
    _hiddenLine = isHidden;
    
    if (isHidden) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                if (_hiddenLine) {
                    self.underLine.alpha = 0.0;
                }
            }];
        });
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [UIView animateWithDuration:0.5 animations:^{
//                if (_hiddenLine) {
//                    self.underLine.alpha = 0.0;
//                }
//            }];
//        });
//        //开始一个新事物
//        [CATransaction begin];
//
//        //设置动画时间持续到1秒钟
//        [CATransaction setAnimationDuration:1.0];
//        if (_hiddenLine) {
//            self.underLine.backgroundColor = [UIColor yellowColor];
//        }
//        //提交事务
//        [CATransaction commit];
    }
}

- (void)showVRMode {
    self.selectIndex = 1;
    [self fixPosition:0 baseWidth:SCREEN_WIDTH / 2.0];
}

- (void)drawRect1:(CGRect)rect {
    if (_hiddenLine || (_dx == 0 && _baseWidth == 0)) {
        _lineAlpha = 0.25;
        return;
    }

    if (fabs(_dx) == 0) {
        _lineAlpha = 0;
    }else if(fabs(_dx) == fabs(_baseWidth)){
        [self hiddenLine:YES];
    }else {
        [self hiddenLine:NO];
    }
    
    // 1.获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    // --------------------------直线
    CGFloat mw = SmallItem / 2.0;
    CGFloat rw = 0;
    
    CGFloat scale = [self fixBottomLine:_dx baseWidth:_baseWidth];
    
    CGFloat leftx = leadingSpace + SmallItem * 3.0 / 4.0 ;
    CGFloat rx = _baseWidth / 2.0;
    
    CGFloat rwidth = SmallItem;
    CGFloat rightx = self.frame.size.width - rwidth * 3 / 4.0 - leadingSpace - [self coordinate:_baseWidth baseWidth:_baseWidth];
    
    CGFloat lx = 0;
    CGFloat lw = 0;
    
    lw = fabs((rw - mw) * scale);
    if (_dx >= 0) {
        lx = rx + (leftx - rx) * scale;
    }else {
        lx = rx + (rightx - rx) * -scale;
    }
    
    CGFloat y = self.frame.size.height - 10;
    CGContextMoveToPoint(ctx, lx,  y); // 起点
    CGContextAddLineToPoint(ctx, (lx + lw),  y); //终点
    [RGBACOLOR(0.0, 0.0, 0.0, _lineAlpha) set]; // 两种设置颜色的方式都可以
    CGContextSetLineWidth(ctx, 3.0f); // 线的宽度
    
    (_lineAlpha == 0) ? nil : CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextStrokePath(ctx); // 渲染（直线只能绘制空心的，不能调用CGContextFillPath(ctx);）
    CGContextRestoreGState(ctx);
}

- (void)setupViews {
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[Commons getImageFromResource:@"Home_tabbar_button_channels"] forState:UIControlStateNormal];
//    [leftBtn setBackgroundImage:[Commons getImageFromResource:@"Home_tabbar_button_channels_shadow"] forState:UIControlStateNormal];
    leftBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    //    leftBtn.frame = CGRectMake(0, LargeHeight-BottomSpace-SmallItem, SmallItem, SmallItem);
    leftBtn.frame = CGRectMake(0, 0, SmallItem, SmallItem);
    //    leftBtn.backgroundColor = [UIColor yellowColor];
    //    leftBtn.layer.cornerRadius = SmallItem / 2;
    //    leftBtn.layer.masksToBounds = YES;
    [leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftBtn];
    _leftBtn = leftBtn;
    
    UIButton *leftBtn_active = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn_active setImage:[Commons getImageFromResource:@"Home_tabbar_button_channels_active"] forState:UIControlStateNormal];
//    [leftBtn_active setBackgroundImage:[Commons getImageFromResource:@"Home_tabbar_button_channels_shadow"] forState:UIControlStateNormal];
    leftBtn_active.imageView.contentMode = UIViewContentModeScaleAspectFill;
    //    leftBtn.frame = CGRectMake(0, LargeHeight-BottomSpace-SmallItem, SmallItem, SmallItem);
    leftBtn_active.frame = CGRectMake(0, 0, SmallItem, SmallItem);
    //    leftBtn.backgroundColor = [UIColor yellowColor];
    //    leftBtn.layer.cornerRadius = SmallItem / 2;
    //    leftBtn.layer.masksToBounds = YES;
    [leftBtn_active addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftBtn_active];
    _leftBtn_active = leftBtn_active;
    
    
    UIImageView *centerBg = [[UIImageView alloc] initWithFrame:CGRectZero];
    centerBg.frame = CGRectMake(-100, 0, CBGItem, CBGItem);
    //    centerBg.backgroundColor = [UIColor blueColor];
    centerBg.image = [Commons getImageFromResource:@"Home_tabbar_button_bg"];
    centerBg.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:centerBg];
    _centerBg = centerBg;
    UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    centerBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    //    centerBtn.frame = CGRectMake(-100, LargeHeight-BottomSpace-CSamllItem, CSamllItem, CSamllItem);
    centerBtn.frame = CGRectMake(-100, 0, CSamllItem, CSamllItem);
    [centerBtn setImage:[Commons getImageFromResource:@"Home_tabbar_button_videos"] forState:UIControlStateNormal];
    //    [centerBtn setBackgroundImage:[Commons getImageFromResource:@"Home_tabbar_button_bg"] forState:UIControlStateNormal];
    centerBtn.backgroundColor = [UIColor clearColor];
    //    centerBtn.layer.cornerRadius = CSamllItem / 2;
    [centerBtn addTarget:self action:@selector(centerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:centerBtn];
    //    centerBtn.layer.shadowOpacity = 0.8;
    //    centerBtn.layer.shadowColor =  [UIColor blackColor].CGColor;
    //    self.centerBtn.layer.shadowRadius = self.centerBtn.frame.size.width / 2;
    //    centerBtn.layer.shadowOffset =  CGSizeMake(0, self.centerBtn.frame.size.height / 2);
    _centerBtn = centerBtn;
    
    
    UIButton *centerVR = [UIButton buttonWithType:UIButtonTypeCustom];
    centerVR.imageView.contentMode = UIViewContentModeScaleAspectFill;
    centerVR.frame = CGRectMake(-100, 0, CSamllItem, CSamllItem);
    //    centerBg.backgroundColor = [UIColor blueColor];
    [centerVR setImage:[Commons getImageFromResource:@"Home_tabbar_button_VR"] forState:UIControlStateNormal];
    [centerVR addTarget:self action:@selector(centerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:centerVR];
    
    _centerVR = centerVR;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.imageView.contentMode = UIViewContentModeScaleToFill;
    
    
    
    
//    [rightBtn setBackgroundImage:[Commons getImageFromResource:@"Home_tabbar_button_history_shadow"] forState:UIControlStateNormal];
    
    
    
    [rightBtn setImage:[Commons getImageFromResource:@"Home_tabbar_button_history"] forState:UIControlStateNormal];
    //    rightBtn.frame = CGRectMake(-100, LargeHeight-BottomSpace-SmallItem, SmallItem, SmallItem);
    rightBtn.frame = CGRectMake(-100, 0, SmallItem, SmallItem);
    //    rightBtn.backgroundColor = [UIColor redColor];
    //    rightBtn.layer.cornerRadius = SmallItem / 2;
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightBtn];
    _rightBtn = rightBtn;
    
    
    UIButton *rightBtn_active = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn_active setImage:[Commons getImageFromResource:@"Home_tabbar_button_history_active"] forState:UIControlStateNormal];
    
    
//    [rightBtn_active setBackgroundImage:[Commons getImageFromResource:@"Home_tabbar_button_history_shadow"] forState:UIControlStateNormal];
    
    
    
    rightBtn_active.imageView.contentMode = UIViewContentModeScaleAspectFill;
    //    leftBtn.frame = CGRectMake(0, LargeHeight-BottomSpace-SmallItem, SmallItem, SmallItem);
    rightBtn_active.frame = CGRectMake(0, 0, SmallItem, SmallItem);
    //    leftBtn.backgroundColor = [UIColor yellowColor];
    //    leftBtn.layer.cornerRadius = SmallItem / 2;
    //    leftBtn.layer.masksToBounds = YES;
    [rightBtn_active addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightBtn_active];
    _rightBtn_active = rightBtn_active;
    
    if (!_underLine) {
        [self addSubview:self.underLine];
        [self bringSubviewToFront:self.underLine];
    }
}

- (UIView *)underLine {
    if (!_underLine) {
        UIView *underLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 10, UnderLineItem, 3.0)];
        underLine.backgroundColor = [UIColor blackColor];
        underLine.layer.cornerRadius = 1.5;
        _underLine = underLine;
    }

    return _underLine;
}

- (void)moveUnderLineWithAnimation {
    if (_hiddenLine || (_dx == 0 && _baseWidth == 0)) {
        _lineAlpha = 0.25;
        [self hiddenLine:NO];
        return;
    }
    
    if (fabs(_dx) == 0) {
        _lineAlpha = 0.0;
    }else if(fabs(_dx) == fabs(_baseWidth)){
        [self hiddenLine:YES];
    }else {
        _lineAlpha = 0.25;
        [self hiddenLine:NO];
    }
    
    // --------------------------直线
    CGFloat mw = UnderLineItem / 2.0;
    CGFloat rw = 0;
    
    CGFloat scale = [self fixBottomLine:_dx baseWidth:_baseWidth];
    
   CGFloat leftx = leadingSpace + [self coordinate:fabs(_baseWidth) baseWidth:_baseWidth] + SmallItem / 2.0 - mw / 2.0;
    CGFloat rx = _baseWidth / 2.0;
    
    CGFloat rwidth = SmallItem * fabs(scale);
    CGFloat rightx = self.frame.size.width - rwidth - leadingSpace - [self coordinate:fabs(_baseWidth) baseWidth:_baseWidth] + SmallItem / 2.0 - mw / 2.0;
    
    CGFloat lx = 0;
    CGFloat lw = 0;
    
    lw = fabs((rw - mw) * scale);
    if (_dx >= 0) {
        lx = rx + (leftx - rx) * scale;
    }else {
        lx = rx + (rightx - rx) * -scale;
    }
    
    CGFloat y = self.frame.size.height - 10;
    
    self.underLine.alpha = _lineAlpha;
    self.underLine.frame = CGRectMake(lx, y, lw, 3.0);
}

#pragma -mark event
- (void)scale:(UIView *)view {
    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animation];
    scaleAnim.keyPath = @"transform.scale";
    scaleAnim.values = @[@1.0, @1.5, @1.0];
    scaleAnim.repeatCount = 0;
    scaleAnim.duration = 0.2;
    [view.layer addAnimation:scaleAnim forKey:@"tapAndScale"];
}
- (void)groupAnimation {
    //    CGRect oldFrame = self.leftBtn.frame;
    //    CABasicAnimation *leftMoveAnim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    //    leftMoveAnim.fromValue = [NSNumber numberWithDouble:oldFrame.origin.x];
    //    leftMoveAnim.toValue = @20;
    //    leftMoveAnim.duration = 2.0;
    //    leftMoveAnim.repeatCount = 0;
    //
    //    leftMoveAnim.removedOnCompletion = NO;
    //    leftMoveAnim.fillMode = kCAFillModeForwards;//不恢复原态
    //
    //    CABasicAnimation *leftScaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //    leftScaleAnim.fromValue = @1.0;
    //    leftScaleAnim.toValue = @1.5;
    //    leftScaleAnim.duration = 2.0;
    //    leftScaleAnim.repeatCount = 0;
    //
    //    leftScaleAnim.removedOnCompletion = NO;
    //    leftScaleAnim.fillMode = kCAFillModeForwards;//不恢复原态
    //
    //    CAAnimationGroup *leftAnimGroup = [CAAnimationGroup animation];
    //    [leftAnimGroup setAnimations:@[leftMoveAnim, leftScaleAnim]];
    //    leftAnimGroup.duration = 2.0;
    //
    //    leftAnimGroup.removedOnCompletion = NO;
    //    leftAnimGroup.fillMode = kCAFillModeForwards;
    //
    //    [self.leftBtn.layer addAnimation:leftAnimGroup forKey:nil];
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    if (_selectIndex == selectIndex) {
        return;
    }
    _selectIndex = selectIndex;
}

- (void)fixPosition:(CGFloat)dx baseWidth:(CGFloat)width {
    _dx = dx;
    _baseWidth = width;
    CGFloat fdx = fabs(dx);
    CGFloat alpha =  [self fixAlpha:fdx baseWidth:width];
    
    if (dx < 0) {
        self.rightBtn.alpha = 1.0 - alpha;
        self.rightBtn_active.alpha = alpha;
        self.leftBtn_active.alpha = 0.0;
        self.leftBtn.alpha = 1.0;
    }else if(dx > 0) {
        self.leftBtn.alpha = 1.0 - alpha;
        self.leftBtn_active.alpha = alpha;
        self.rightBtn_active.alpha = 0.0;
        self.rightBtn.alpha = 1.0;
    }else {
        self.rightBtn.alpha = 1.0 - alpha;
        self.rightBtn_active.alpha = alpha;
        self.leftBtn_active.alpha = alpha;
        self.leftBtn.alpha = 1.0 - alpha;
    }
    
    [self moveUnderLineWithAnimation];
    if (!_animation) {
        return;
    }
    
    self.centerBtn.alpha = [self fixAlpha:fdx baseWidth:width];
    self.centerVR.alpha = 1.0 - [self fixAlpha:fdx baseWidth:width];
    
    CGFloat scale = [self fixScale:fdx baseWidth:width];
    //left
    CGFloat lx = leadingSpace + [self coordinate:fdx baseWidth:width];
    CGFloat lwidth = SmallItem * scale;
    CGFloat lheight = SmallItem * scale;
    //    CGFloat ly = LargeHeight - BottomSpace - lheight;
    CGFloat ly = 0 + [self fixY:fdx baseWidth:width];
    CGRect lframe = self.leftBtn.frame;
    lframe.origin.x = lx;
    lframe.origin.y = ly;
    lframe.size.width = lwidth;
    lframe.size.height = lheight;
    
    self.leftBtn.frame = lframe;
    self.leftBtn_active.frame = lframe;
    
    //    self.leftBtn.backgroundColor = [UIColor yellowColor];
    //    self.leftBtn.layer.cornerRadius = lwidth / 2;
    //    self.leftBtn.layer.masksToBounds = YES;
    
    //right
    CGFloat rwidth = SmallItem * scale;
    CGFloat rheight = SmallItem * scale;
    CGFloat rx = self.frame.size.width - rwidth - leadingSpace - [self coordinate:fdx baseWidth:width];
    //    CGFloat ry = LargeHeight - BottomSpace - rheight;
    CGFloat ry = 0 + [self fixY:fdx baseWidth:width];
    CGRect rframe = self.rightBtn.frame;
    rframe.origin.x = rx;
    rframe.origin.y = ry;
    rframe.size.width = rwidth;
    rframe.size.height = rheight;
    
    self.rightBtn.frame = rframe;
    self.rightBtn_active.frame = rframe;
    
    
    //    self.rightBtn.backgroundColor = [UIColor blueColor];
    //    self.rightBtn.layer.cornerRadius = rwidth / 2;
    //    self.rightBtn.layer.masksToBounds = YES;
    
    //center
    CGFloat cscale = [self fixCenterBtnScale:fdx baseWidth:width];
    CGFloat cw = CSamllItem * cscale;
    CGFloat ch = CSamllItem * cscale;
    
    CGFloat cx = (self.frame.size.width - cw) / 2;
    //    CGFloat cy = LargeHeight - BottomSpace - ch - (UpperSpace - [self fixY:dx baseWidth:width]);
    //    CGFloat cy = 0 + [self fixCenterBtnY:dx baseWidth:width];
    CGFloat cy = ry + rheight / 2 - ch / 2;
    CGRect cframe = self.centerBtn.frame;
    cframe.origin.x = cx;
    cframe.origin.y = cy;
    cframe.size.width = cw;
    cframe.size.height = ch;
    
    self.centerBtn.frame = cframe;
    //    //     NSLog(@"centerBtn.cnetr ========== == %f   CGFloat cw ==  %f   cx ====== %f", self.centerBtn.center.x, cw, cx);
    //    self.centerBtn.layer.cornerRadius = cw / 2;
    //    self.centerBtn.layer.shadowOpacity = 0.8;
    //    self.centerBtn.layer.shadowColor =  [UIColor blackColor].CGColor;
    //    self.centerBtn.layer.shadowRadius = self.centerBtn.frame.size.width / 2;
    //    self.centerBtn.layer.shadowOffset =  CGSizeMake(0, self.centerBtn.frame.size.height / 2);
    //    self.centerBtn.clipsToBounds = NO;
    //    self.centerBtn.layer.masksToBounds = NO;
    
    
    CGFloat cvx = (self.frame.size.width - cw) / 2;
    CGFloat cvy = ry + rheight / 2 - ch / 2;
    CGRect cvframe = self.centerVR.frame;
    cvframe.origin.x = cvx;
    cvframe.origin.y = cvy;
    cvframe.size.width = cw;
    cvframe.size.height = ch;
    self.centerVR.frame = cvframe;
    
    CGFloat cbw = CBGItem * cscale;
    CGFloat cbh = CBGItem * cscale;
    
    CGFloat cbx = (self.frame.size.width - cbw) / 2;
    //    CGFloat cy = LargeHeight - BottomSpace - ch - (UpperSpace - [self fixY:dx baseWidth:width]);
    //    CGFloat cby = 0 + [self fixCenterBgBtnY:dx baseWidth:width];
    CGFloat cby = ry + rheight / 2 - cbh / 2;
    CGRect cbframe = self.centerBg.frame;
    cbframe.origin.x = cbx;
    cbframe.origin.y = cby;
    cbframe.size.width = cbw;
    cbframe.size.height = cbh;
    self.centerBg.frame = cbframe;
    //    self.centerBg.backgroundColor = [UIColor redColor];
    //    //     NSLog(@"centerBg.center == %f  cbw === %f", self.centerBg.center.x , cbw);
}

- (CGFloat)fixCenterBtnScale:(CGFloat)x baseWidth:(CGFloat)width {
    return 1.0 - 1.0 * (0.1 / width) * x;
}
- (CGFloat)fixCenterBtnY:(CGFloat)x baseWidth:(CGFloat)width {
    return 1.0 * (CSamllItem * 0.1 / width) * x;
}
- (CGFloat)fixCenterBgBtnY:(CGFloat)x baseWidth:(CGFloat)width {
    return 1.0 * (CBGItem * 0.1 / width) * x;
}

- (CGFloat)fixAlpha:(CGFloat)x baseWidth:(CGFloat)width {
    CGFloat alpha = 1.0 * (x / width);
    return alpha;
}
- (CGFloat)coordinate:(CGFloat)x baseWidth:(CGFloat)width {
    //    CGFloat dx = self.frame.size.width/2 - WSpace - SmallItem/2 - leadingSpace;
    CGFloat dx = self.frame.size.width/2 - CBGItem / 2 - SmallItem - leadingSpace;
    
    return 1.0 * (dx / width) * x;
}
- (CGFloat)fixScale:(CGFloat)x baseWidth:(CGFloat)width {
    //    return 1.5 - 1.0 * (0.5 / width) * x;
    return 1.0;
}

- (CGFloat)fixY:(CGFloat)x baseWidth:(CGFloat)width {
    return 1.0 * (UpperSpace / width) * x;
}

#pragma -mark event
- (void)resetAnimation {
    _animation = YES;
}

- (void)leftBtnClick:(UIButton *)btn {
    if (self.selectIndex == 0) {
        [self scale:self.leftBtn];
        [self scale:self.leftBtn_active];
        return;
    }else if(self.selectIndex == 2){
        _animation = NO;
    }else {
        _animation = YES;
    }
    
    self.selectIndex = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchBar: selectIndex:)]) {
        [self.delegate switchBar:self selectIndex:0];
    }
}
- (void)centerBtnClick:(UIButton *)btn {
    if (self.selectIndex == 1) {
        //进入VR模式
        [self vrBtnClick:btn];
        return;
    }else {
        _animation = YES;
    }
    self.selectIndex = 1;
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchBar: selectIndex:)]) {
        [self.delegate switchBar:self selectIndex:1];
    }
}
- (void)rightBtnClick:(UIButton *)btn {

    if (self.selectIndex == 2) {
        [self scale:self.rightBtn];
        [self scale:self.rightBtn_active];
        return ;
    }else if(self.selectIndex == 0){
        _animation = NO;
    }else {
        _animation = YES;
    }
    
    self.selectIndex = 2;
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchBar: selectIndex:)]) {
        [self.delegate switchBar:self selectIndex:2];
    }
}

//响应外部点击
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.clipsToBounds || self.hidden || (self.alpha == 0.f)) {
        return nil;
    }
    UIView *result = [super hitTest:point withEvent:event];
    // 如果事件发生在 switchBar 里面直接返回
    if (result) {
        return result;
    }
    
    CGPoint subPoint = [self.centerBtn convertPoint:point fromView:self];
    result = [self.centerBtn hitTest:subPoint withEvent:event];
    // 如果事件发生在 subView 里就返回
    if (result) {
        return result;
    }
    return nil;
}

#pragma -mark VRButton
- (void)vrBtnClick:(UIButton *)sender {
    NSUInteger selectedIndex = -1;
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:NativeToUnityType],
                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex]
                             };
    
    [sender bubbleEventWithUserInfo:notify];
}
@end


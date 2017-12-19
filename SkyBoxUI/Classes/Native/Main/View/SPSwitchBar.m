//
//  SPSwitchBar.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/11.
//

#import "SPSwitchBar.h"
#define LargeHeight      kWSCALE*49*1.5
#define SmallItem        kWSCALE*35
#define LargeItem        kWSCALE*35*1.5
#define CSamllItem       kWSCALE*49
#define CLargeItem       kWSCALE*49*1.5
#define WSpace           kWSCALE*80
#define BottomSpace      kWSCALE*20
#define UpperSpace       kWSCALE*10

@interface SPSwitchBar()

@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIButton *centerBtn;
//@property (nonatomic, strong) UIView   *underLine;

@end

@implementation SPSwitchBar
SPSingletonM(SPSwitchBar)

- (instancetype)init
{
    CGFloat y = [SPDeviceUtil isiPhoneX] ? (SCREEN_HEIGHT - 34 - LargeHeight) : (SCREEN_HEIGHT - LargeHeight);
    self = [self initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, LargeHeight)];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectIndex = 0;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, LargeHeight-BottomSpace-SmallItem, SmallItem, SmallItem);
    leftBtn.backgroundColor = [UIColor blueColor];
    leftBtn.layer.cornerRadius = SmallItem / 2;
    leftBtn.layer.masksToBounds = YES;
    [leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftBtn];
    _leftBtn = leftBtn;
    
    UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    centerBtn.frame = CGRectMake(-100, LargeHeight-BottomSpace-CSamllItem, CSamllItem, CSamllItem);
    centerBtn.backgroundColor = [UIColor yellowColor];
    centerBtn.layer.cornerRadius = CSamllItem / 2;
    [centerBtn addTarget:self action:@selector(centerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:centerBtn];
    centerBtn.clipsToBounds = NO;
    _centerBtn = centerBtn;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(-100, LargeHeight-BottomSpace-SmallItem, SmallItem, SmallItem);
    rightBtn.backgroundColor = [UIColor redColor];
    rightBtn.layer.cornerRadius = SmallItem / 2;
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightBtn];
    _rightBtn = rightBtn;
    
//    [self addSubview:self.underLine];
}

//- (UIView *)underLine {
//    if (!_underLine) {
//        UIView *underLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SmallItem, 4)];
//        underLine.backgroundColor = [UIColor grayColor];
//        underLine.layer.cornerRadius = 2;
//        _underLine = underLine;
//    }
//
//    return _underLine;
//}

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
    CGFloat scale = [self fixScale:dx baseWidth:width];
    
    //left
    CGFloat lx = 20 + [self coordinate:dx baseWidth:width];
    CGFloat lwidth = SmallItem * scale;
    CGFloat lheight = SmallItem * scale;
    CGFloat ly = LargeHeight - BottomSpace - lheight;
    CGRect lframe = self.leftBtn.frame;
    lframe.origin.x = lx;
    lframe.origin.y = ly;
    lframe.size.width = lwidth;
    lframe.size.height = lheight;
    self.leftBtn.frame = lframe;
    self.leftBtn.layer.cornerRadius = lwidth / 2;
    self.leftBtn.layer.masksToBounds = YES;
    
    //right
    CGFloat rwidth = SmallItem * scale;
    CGFloat rheight = SmallItem * scale;
    CGFloat rx = self.frame.size.width - rwidth - 20 - [self coordinate:dx baseWidth:width];
    CGFloat ry = LargeHeight - BottomSpace - rheight;
    CGRect rframe = self.rightBtn.frame;
    rframe.origin.x = rx;
    rframe.origin.y = ry;
    rframe.size.width = rwidth;
    rframe.size.height = rheight;
    self.rightBtn.frame = rframe;
    self.rightBtn.layer.cornerRadius = rwidth / 2;
    self.rightBtn.layer.masksToBounds = YES;
    
    //center
    CGFloat cw = CSamllItem * scale;
    CGFloat ch = CSamllItem * scale;
    CGFloat cx = (self.frame.size.width - cw) / 2;
    CGFloat cy = LargeHeight - BottomSpace - ch - (UpperSpace - [self fixY:dx baseWidth:width]);
    CGRect cframe = self.centerBtn.frame;
    cframe.origin.x = cx;
    cframe.origin.y = cy;
    cframe.size.width = cw;
    cframe.size.height = ch;
    self.centerBtn.frame = cframe;
    self.centerBtn.layer.cornerRadius = cw / 2;
    self.centerBtn.layer.masksToBounds = YES;
}

- (CGFloat)coordinate:(CGFloat)x baseWidth:(CGFloat)width {
    CGFloat dx = self.frame.size.width/2 - WSpace - SmallItem/2 - 20;

    return 1.0 * (dx / width) * x;
}
- (CGFloat)fixScale:(CGFloat)x baseWidth:(CGFloat)width {
    return 1.5 - 1.0 * (0.5 / width) * x;
}

- (CGFloat)fixY:(CGFloat)x baseWidth:(CGFloat)width {
    return 1.0 * (UpperSpace / width) * x;
}

#pragma -mark event
- (void)leftBtnClick:(UIButton *)btn {
    if (self.selectIndex == 0) {
        [self scale:self.leftBtn];
        return;
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
    }
    self.selectIndex = 1;
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchBar: selectIndex:)]) {
        [self.delegate switchBar:self selectIndex:1];
    }
}
- (void)rightBtnClick:(UIButton *)btn {
    if (self.selectIndex == 2) {
        [self scale:self.rightBtn];
        return ;
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
    NSDictionary *notify = @{kEventType : [NSNumber numberWithUnsignedInteger:nativeToUnityType],
                             kSelectTabBarItem: [NSNumber numberWithUnsignedInteger:selectedIndex]
                             };
    
    [sender bubbleEventWithUserInfo:notify];
}
@end

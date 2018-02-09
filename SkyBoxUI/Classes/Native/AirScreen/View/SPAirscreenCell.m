//
//  SPAirscreenCellTableViewCell.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2018/2/6.
//

#import "SPAirscreenCell.h"

@interface SPAirscreenCell()

@property (strong, nonatomic) SPLineView *lineView;
@end

@implementation SPAirscreenCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupLineView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupLineView];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setupLineView];
    }
    
    return self;
}

- (void)setupLineView {
    SPLineView *lineview = [[SPLineView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:lineview];
    _lineView = lineview;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _lineView.frame = CGRectMake(0, self.contentView.bounds.size.height - 1.0, self.contentView.bounds.size.width, 1.0);
    [self sendSubviewToBack:_lineView];
}

- (void)showLineView:(BOOL)show {
    _lineView.hidden = !show;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    //动画高亮变色效果
    if(highlighted) {
        self.contentView.backgroundColor = [SPColorUtil getHexColor:@"#e5e5e5"];
        self.lineView.backgroundColor = [SPColorUtil getHexColor:@"#e5e5e5"];
    }else {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.lineView.backgroundColor = [SPColorUtil getHexColor:@"#e5e5e5"];
    }
}

@end

@implementation SPLineView

- (void)drawRect:(CGRect)rect {
    
    // 1.获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
//    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);//填充色设置成白色
//    CGContextFillRect(ctx, self.bounds);//把整个空间用刚设置的颜色填充
    
    // --------------------------实心圆
    
    //    // 2.画图
    //        CGContextAddEllipseInRect(ctx, CGRectMake(10, 10, 50, 50));
    //        [[UIColor greenColor] set];
    //
    //        // 3.渲染
    //        CGContextFillPath(ctx);
    //
    //
    //
    //    // --------------------------空心圆
    //
    //    CGContextAddEllipseInRect(ctx, CGRectMake(70, 10, 50, 50));
    //    [[UIColor redColor] set];
    //    CGContextStrokePath(ctx);
    //
    //
    //
    //    // --------------------------椭圆
    //    //画椭圆和画圆方法一样，椭圆只是设置不同的长宽
    //    CGContextAddEllipseInRect(ctx, CGRectMake(130, 10, 100, 50));
    //    [[UIColor purpleColor] set];
    //    CGContextFillPath(ctx);
    
    
    
    // --------------------------直线
    CGContextMoveToPoint(ctx, 0, rect.size.height); // 起点
    CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height); //终点
    //    CGContextSetRGBStrokeColor(ctx, 0, 1.0, 0, 1.0); // 颜色
    [[SPColorUtil getHexColor:@"##d4d5d7"] set]; // 两种设置颜色的方式都可以
    CGContextSetLineWidth(ctx, 2.0f); // 线的宽度
    //    CGContextSetLineCap(ctx, kCGLineCapRound); // 起点和重点圆角
    //    CGContextSetLineJoin(ctx, kCGLineJoinRound); // 转角圆角
    CGContextStrokePath(ctx); // 渲染（直线只能绘制空心的，不能调用CGContextFillPath(ctx);）
    
    
    
    //    // --------------------------三角形
    //    CGContextMoveToPoint(ctx, 10, 150); // 第一个点
    //    CGContextAddLineToPoint(ctx, 60, 100); // 第二个点
    //    CGContextAddLineToPoint(ctx, 100, 150); // 第三个点
    //    [[UIColor purpleColor] set];
    //    CGContextClosePath(ctx);
    //    CGContextStrokePath(ctx);
    //
    //
    //
    //    // --------------------------矩形
    //    CGContextAddRect(ctx, CGRectMake(20, 170, 100, 50));
    //    [[UIColor orangeColor] set];
    //    //    CGContextStrokePath(ctx); // 空心
    //    CGContextFillPath(ctx);
    //
    //
    //
    //    // --------------------------圆弧
    //    CGContextAddArc(ctx, 200, 170, 50, M_PI, M_PI_4, 0);
    //    CGContextClosePath(ctx);
    //    CGContextFillPath(ctx);
    //
    //
    //    // --------------------------文字
    //    NSString *str = @"你在红楼，我在西游";
    //    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //    dict[NSForegroundColorAttributeName] = [UIColor whiteColor]; // 文字颜色
    //    dict[NSFontAttributeName] = [UIFont systemFontOfSize:14]; // 字体
    //
    //    [str drawInRect:CGRectMake(20, 250, 300, 30) withAttributes:dict];
    //
    //
    //    // --------------------------图片
    //    UIImage *img = [UIImage imageNamed:@"yingmu"];
    //    //    [img drawAsPatternInRect:CGRectMake(20, 280, 300, 300)]; // 多个平铺
    //    //    [img drawAtPoint:CGPointMake(20, 280)]; // 绘制到指定点，图片有多大就显示多大
    //    [img drawInRect:CGRectMake(20, 280, 80, 80)]; // 拉伸
}

@end



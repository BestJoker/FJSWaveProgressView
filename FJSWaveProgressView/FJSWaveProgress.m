//
//  FJSWaveProgress.m
//  FJSWaveAnimation
//
//  Created by 付金诗 on 16/6/29.
//  Copyright © 2016年 www.fujinshi.com. All rights reserved.
//

#import "FJSWaveProgress.h"

@interface FJSWaveProgress ()
@property (nonatomic,assign)CGFloat yHeight;/**< 当前进度对应的y值,由于y是向下递增,所以要注意 */
@property (nonatomic,assign)CGFloat offset;/**< 偏移量,决定了这个点在y轴上的位置,以此来实现动态效果*/
@property (nonatomic,strong)CADisplayLink * link;/**< 定时器*/
@property (nonatomic,strong)CAShapeLayer * waveLayer;/**< 水波的layer */
@property (nonatomic,strong)UILabel * label;
@end
@implementation FJSWaveProgress

//水波动画的关键点就在于正余弦函数,使用两条正余弦函数进行周期性变化,就会产生所谓的波纹动画.
/*
 正弦型函数解析式：y=Asin（ωx+φ）+h
 各常数值对函数图像的影响：
 φ（初相位）：决定波形与X轴位置关系或横向移动距离（左加右减）
 ω：决定周期（最小正周期T=2π/|ω|）
 A：决定峰值（即纵向拉伸压缩的倍数）
 h：表示波形在Y轴的位置关系或纵向移动距离（上加下减）
 */
/*
 如果想绘制出来一条正弦函数曲线，可以沿着假想的曲线绘制许多个点，然后把点逐一用直线连在一起，如果点足够多，就可以得到一条满足需求的曲线，这也是一种微分的思想。而这些点的位置可以通过正弦函数的解析式求得。
 加入水波的峰值是1，周期是2π，初相位是0，h位移也是0。那么计算各个点的坐标公式就是y = sin(x);获得各个点的坐标之后，使用CGPathAddLineToPoint这个函数，把这些点逐一连成线，就可以得到最后的路径。
 */
/*
 如果想要得到一个动态的波纹,随着时间的变化,我们如果假定每个点的x位置没有变化,那么只要让其y随着时间有规律的变化就可以让人觉得是在有规律的动.需要注意UIKit的坐标系统y轴是向下延伸。
 如果想在0到2π这个距离显示2个完整的波曲线，那么周期就是π.如果每次增加π/4,则4s就会完成一个周期.
 如果想要在width上来宽度上展示2个周期的水波,则周期是waveWidth / 2,w = 2 * M_PI / waveWidth
 */

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bounds = CGRectMake(0, 0, MIN(frame.size.width, frame.size.height), MIN(frame.size.width, frame.size.height));
        self.layer.cornerRadius = MIN(frame.size.width, frame.size.height) * 0.5;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.0f;
        
        self.waveHeight = 5.0;
        self.waveColor = [UIColor greenColor];
        self.yHeight = self.bounds.size.height;
        self.waveLayer = [CAShapeLayer layer];
        self.waveLayer.frame = self.bounds;
        self.waveLayer.fillColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:self.waveLayer];

        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.label.font = [UIFont boldSystemFontOfSize:20];
        self.label.textAlignment = 1;
        self.label.textColor = [UIColor orangeColor];
        [self addSubview:self.label];
        self.label.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    return self;
}

-(void)setProgress:(CGFloat)progress
{
    _progress = progress;
    //将进度转成百分比.
    self.label.text = [NSString stringWithFormat:@"%ld%%",[[NSNumber numberWithFloat:progress * 100] integerValue]];
    [self.label sizeToFit];
    //由于y坐标轴的方向是由上向下,逐渐增加的,所以这里对于y坐标进行处理
    self.yHeight = self.bounds.size.height * (1 - progress);
    //先停止动画,然后在开始动画,保证不会有什么冲突和重复.
    [self stopWaveAnimation];
    [self startWaveAnimation];
}

#pragma mark -- 开始波动动画
- (void)startWaveAnimation
{
    //相对于NSTimer CADisplayLink更准确,每一帧调用一次.
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(waveAnimation)];
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark -- 停止波动动画
- (void)stopWaveAnimation
{
    [self.link invalidate];
    self.link = nil;
}


#pragma mark -- 波动动画实现
- (void)waveAnimation
{
    CGFloat waveHeight = self.waveHeight;
    //如果是0或者1,则不需要wave的高度,否则会看出来一个小的波动.
    if (self.progress == 0.0f || self.progress == 1.0f) {
        waveHeight = 0.f;
    }
    //累加偏移量,这样就可以通过speed来控制波动的速度了.对于正弦函数中的各个参数,你可以通过上面的注释进行了解.
    self.offset += self.speed;
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGFloat startOffY = waveHeight * sinf(self.offset * M_PI * 2 / self.bounds.size.width);
    CGFloat orignOffY = 0.0;
    CGPathMoveToPoint(pathRef, NULL, 0, startOffY);
    for (CGFloat i = 0.f; i <= self.bounds.size.width; i++) {
        orignOffY = waveHeight * sinf(2 * M_PI / self.bounds.size.width * i + self.offset * M_PI * 2 / self.bounds.size.width) + self.yHeight;
        CGPathAddLineToPoint(pathRef, NULL, i, orignOffY);
    }
    //连接四个角和以及波浪,共同组成水波.
    CGPathAddLineToPoint(pathRef, NULL, self.bounds.size.width, orignOffY);
    CGPathAddLineToPoint(pathRef, NULL, self.bounds.size.width, self.bounds.size.height);
    CGPathAddLineToPoint(pathRef, NULL, 0, self.bounds.size.height);
    CGPathAddLineToPoint(pathRef, NULL, 0, startOffY);
    CGPathCloseSubpath(pathRef);
    self.waveLayer.path = pathRef;
    self.waveLayer.fillColor = self.waveColor.CGColor;
    CGPathRelease(pathRef);
}









/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  ViewController.m
//  FJSWaveAnimation
//
//  Created by 付金诗 on 16/6/27.
//  Copyright © 2016年 www.fujinshi.com. All rights reserved.
//

#import "ViewController.h"
#import "FJSWaveProgress.h"
@interface ViewController ()
@property (nonatomic,strong)FJSWaveProgress * progressView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"FJSWaveProgressView";
    self.progressView = [[FJSWaveProgress alloc] initWithFrame:CGRectMake(60, 100, 150, 150)];
    self.progressView.waveHeight = 5;
    self.progressView.speed = 1.0;
    [self.view addSubview:self.progressView];
    
    CGPoint center = self.progressView.center;
    center.x = CGRectGetMidX(self.view.bounds);
    self.progressView.center = center;
    
    UISlider * slider = [[UISlider alloc] initWithFrame:CGRectMake(60, 300, self.view.bounds.size.width - 60 * 2, 30)];
    [slider addTarget:self action:@selector(changeProgress:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
}

- (void)changeProgress:(UISlider *)slider
{
    self.progressView.progress = slider.value;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

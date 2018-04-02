//
//  ViewController.m
//  ZYCycleView
//
//  Created by 夏小静 on 2018/3/27.
//  Copyright © 2018年 夏小静. All rights reserved.
//

#import "ViewController.h"
#import "ZYCycleView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *imageArr = @[[UIImage imageNamed:@"11.jpg"],[UIImage imageNamed:@"12.jpg"],[UIImage imageNamed:@"12.jpg"],[UIImage imageNamed:@"12.jpg"], [UIImage imageNamed:@"11.jpg"]];
    ZYCycleView *zyCycleView = [ZYCycleView initWithFrameCycleViewFrame:CGRectMake(0, 20, self.view.frame.size.width, 300) imageArray:imageArr];
    zyCycleView.scrollTimeInterval = 1;
    zyCycleView.currentPageDotColor = [UIColor redColor];
    zyCycleView.backIndexBlock = ^(NSInteger imageIndex) {
        NSLog(@"点击了%ld图片",imageIndex);
    };
    [self.view addSubview:zyCycleView];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

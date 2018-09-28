//
//  ViewController.m
//  EGOCycleScrollViewExample
//
//  Created by RLY on 2018/9/28.
//  Copyright © 2018年 RLY. All rights reserved.
//

#import "ViewController.h"
#import "EGOCycleScrollView/EGOCycleScrollView.h"

@interface ViewController () <EGOCycleScrollViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    EGOCycleScrollView *view = [[EGOCycleScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds] itemsCount:5 itemHeight:500];
    view.backgroundColor = [UIColor lightGrayColor];
    view.dataSource = self;
    [self.view addSubview:view];
    
    __block NSInteger i = 0;
    __weak EGOCycleScrollView *weakView = view;
    NSTimer *timer = [NSTimer timerWithTimeInterval:3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        i = weakView.currentIndex + 1;
        if (i == 2) {
            weakView.itemsCount ++;
        }
        [weakView setCurrentIndex:i animate:YES];
    }];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
}

- (UIView *)cycleScrollView:(EGOCycleScrollView *)cycleScrollView viewForItemAtIndex:(NSInteger)index
{
    UILabel *view = [cycleScrollView dequeueReusableView];
    if (!view) {
        view = [UILabel new];
        view.font = [UIFont boldSystemFontOfSize:180];
        view.textAlignment = NSTextAlignmentCenter;
        view.textColor = [UIColor darkGrayColor];
        view.backgroundColor = [UIColor lightGrayColor];
    }
    view.text = [NSString stringWithFormat:@"%ld", index];
    
    return view;
}

@end

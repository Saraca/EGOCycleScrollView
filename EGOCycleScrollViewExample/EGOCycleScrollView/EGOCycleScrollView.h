//
//  EGOCycleScrollView.h
//  LEO
//
//  Created by RLY on 2018/9/26.
//  Copyright © 2018年 RLY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EGOCycleScrollView;
@protocol EGOCycleScrollViewDataSource <NSObject>

@required
- (UIView * _Nonnull)cycleScrollView:(EGOCycleScrollView *)cycleScrollView viewForItemAtIndex:(NSInteger)index;

@optional
//- (NSInteger)numberOfItemsInCycleScrollView:(EGOCycleScrollView *)cycleScrollView;
//- (CGSize)cycleScrollView:(EGOCycleScrollView *)cycleScrollView itemSizeAtIndex:(NSInteger)index;

@end


/**
 由三个view互相切换实现无限循环滚动，核心是保证view2在滚动后始终在中间，另外有重用机制
 */
@interface EGOCycleScrollView : UIScrollView

@property (weak,   nonatomic) id<EGOCycleScrollViewDataSource> dataSource;

@property (assign, nonatomic) CGFloat   itemHeight;
@property (assign, nonatomic) NSInteger itemsCount;
@property (assign, nonatomic, readonly) NSInteger currentIndex;
@property (assign, nonatomic, readonly) CGFloat   itemWidth;
@property (copy,   nonatomic) void                (^didSelectBlock)(NSInteger);
@property (copy,   nonatomic) void                (^didScrollBlock)(NSInteger);


/**
 初始化方法

 @param frame frame
 @param itemsCount item数量
 @param itemHeight item高度
 @return EGOCycleScrollView实例
 */
- (instancetype)initWithFrame:(CGRect)frame itemsCount:(NSInteger)itemsCount itemHeight:(CGFloat)itemHeight;

/// 获取重用视图
- (id)dequeueReusableView;
/// 设置当前页
- (void)setCurrentIndex:(NSInteger)currentIndex animate:(BOOL)animate;
/// 重新加载
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END

//
//  EGOCycleself.m
//  LEO
//
//  Created by RLY on 2018/9/26.
//  Copyright © 2018年 RLY. All rights reserved.
//

#import "EGOCycleScrollView.h"


@interface EGOCycleScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *view1; ///< left
@property (nonatomic, strong) UIView *view2; ///< middle
@property (nonatomic, strong) UIView *view3; ///< right
@property (nonatomic, strong) UIView *reuseView; ///< 重用视图

@end

@implementation EGOCycleScrollView


//MARK:- ❤life cycle❤
- (instancetype)initWithFrame:(CGRect)frame itemsCount:(NSInteger)itemsCount itemHeight:(CGFloat)itemHeight
{
    self = [super initWithFrame:frame];
    if (self) {
        _itemHeight = itemHeight;
        if (itemsCount > 0) {
            _itemsCount = itemsCount;
        }
    }
    return self;
}

- (void)didMoveToSuperview
{
    if (self.superview && _itemsCount > 0) {
        [self config];
    }
}


//MARK:- ❤response event❤
- (void)scrollViewClickAction
{
    if (_didSelectBlock && !self.isDragging && !self.isDecelerating) {
        _didSelectBlock(_currentIndex);
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.isDecelerating) {
        return false;
    }
    return true;
}


//MARK:- ❤public method❤
- (id)dequeueReusableView
{
    return _reuseView;
}

- (void)reloadData
{
    if (![_dataSource respondsToSelector:@selector(cycleScrollView:viewForItemAtIndex:)]) {
        return;
    }
    
    _itemWidth = self.frame.size.width;
    if (_itemsCount < 1) {
        [_view1 removeFromSuperview];
        [_view2 removeFromSuperview];
        [_view3 removeFromSuperview];
        self.scrollEnabled = NO;
    }
    else if (_itemsCount == 1) {
        // 只有一个item时
        _view1 = [self viewForItemAtIndex:0 type:1];
        self.scrollEnabled = NO;
        self.contentOffset = CGPointMake(0, 0);
    }
    else {
        // 显示中间的
        self.scrollEnabled = YES;
        self.contentOffset = CGPointMake(_itemWidth, 0);
        
        NSInteger lastIndex = (_currentIndex + _itemsCount - 1) % _itemsCount;
        NSInteger nextIndex = (_currentIndex + 1) % _itemsCount;
        _view1 = [self viewForItemAtIndex:lastIndex type:1];
        _view2 = [self viewForItemAtIndex:_currentIndex type:2];
        _view3 = [self viewForItemAtIndex:nextIndex type:3];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex animate:(BOOL)animate
{
    currentIndex = [self adjustCurrentIndex:currentIndex];
    if (currentIndex == _currentIndex) {
        return;
    }
    
    NSInteger lastIndex = (currentIndex + _itemsCount - 1) % _itemsCount;
    NSInteger nextIndex = (currentIndex + 1) % _itemsCount;
    BOOL isSwipeRight = NO;
    BOOL isNeedReset = labs(currentIndex - _currentIndex) > 1;
    if (currentIndex == 0 || _currentIndex == 0) {
        NSInteger a = MAX(currentIndex, _currentIndex);
        isNeedReset = a > 1 && a < _itemsCount - 1;
    }
    
    // 判断是该往右滑还是往左滑，取最近的，isSwipeRight=YES时向右滑
    if (currentIndex > _currentIndex) {
        isSwipeRight = currentIndex - _currentIndex > _itemsCount - 1 - currentIndex + _currentIndex;
    }
    else {
        isSwipeRight = _itemsCount - 1 - _currentIndex + currentIndex > _currentIndex - currentIndex;
    }
    
    if (self.contentOffset.x == _itemWidth && isSwipeRight) {
        _reuseView = _view1;
        _view1 = [self viewForItemAtIndex:currentIndex type:1];
    }
    else if (self.contentOffset.x == _itemWidth && !isSwipeRight) {
        _reuseView = _view3;
        _view3 = [self viewForItemAtIndex:currentIndex type:3];
    }
    else if (self.contentOffset.x > _itemWidth) {
        // 在setCurrentIndex的时候已经右滑了一点点
        _reuseView = _view1;
        _view1 = [self viewForItemAtIndex:currentIndex type:1];
    }
    else if (self.contentOffset.x < _itemWidth) {
        // 在setCurrentIndex的时候已经左滑了一点点
        _reuseView = _view3;
        _view3 = [self viewForItemAtIndex:currentIndex type:3];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.contentOffset = CGPointMake(isSwipeRight ?0 :self.itemWidth * 2, 0);
    } completion:^(BOOL finished) {
        [self preloadItemAtIndex:isSwipeRight ?lastIndex :nextIndex isSwipeRight:isSwipeRight];
        [self setContentOffset:CGPointMake(self.itemWidth, 0) animated:NO];
        [self setCurrentIndex:currentIndex];
        
        //EGOLogObj(EGOObjTypeConvert(UILabel, _view1).text)
        //EGOLogFmt(@"%@ %ld", EGOObjTypeConvert(UILabel, _view2).text, _currentIndex)
        //EGOLogObj(EGOObjTypeConvert(UILabel, _view3).text)
    }];
}


//MARK:- ❤private method❤
- (void)config
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewClickAction)];
    [self addGestureRecognizer:tap];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentSize = CGSizeMake(_itemWidth * 3, self.frame.size.height);
    self.pagingEnabled = YES;
    self.bounces = NO;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    
    [self reloadData];
}

- (NSInteger)adjustCurrentIndex:(NSInteger)index
{
    NSInteger newIndex = index == -1 ?_currentIndex :index;
    if (_itemsCount < 2
        || newIndex > _itemsCount - 1 // 越界就从第一个开始
        || newIndex < 0) {
        newIndex = 0;
    }
    if (index == -1) {
        _currentIndex = newIndex;
    }
    return newIndex;
}

- (void)resetSubviewsFrame
{
    _view1.frame = CGRectMake(_view1.frame.origin.x, _view1.frame.origin.y, _itemWidth, _itemHeight);
    _view2.frame = CGRectMake(_view2.frame.origin.x, _view2.frame.origin.y, _itemWidth, _itemHeight);
    _view3.frame = CGRectMake(_view3.frame.origin.x, _view3.frame.origin.y, _itemWidth, _itemHeight);
}

/**
 通过_dataSource获取item

 @param index item的index
 @param type 根据type设置view的frame
 @return 对应视图
 */
- (UIView *)viewForItemAtIndex:(NSInteger)index type:(NSInteger)type
{
    UIView *view = [_dataSource cycleScrollView:self viewForItemAtIndex:index];
    NSAssert(view != nil, @"view不能为nil");
    
    if (type == 1) {
        view.frame = CGRectMake(0, 0, _itemWidth, _itemHeight);
    }
    else if (type == 2) {
        view.frame = CGRectMake(_itemWidth, 0, _itemWidth, _itemHeight);
    }
    else if (type == 3) {
        view.frame = CGRectMake(_itemWidth * 2, 0, _itemWidth, _itemHeight);
    }
    
    if (!view.superview) {
        [self addSubview:view];
    }
    return view;
}

/**
 预加载index所对应的item，并交换view1，view2，view3的位置

 @param index 要加载的index
 @param isSwipeRight 加载的方向，YES：表示向右滑移除view3，NO：表示向左滑移除view1
 */
- (void)preloadItemAtIndex:(NSInteger)index isSwipeRight:(BOOL)isSwipeRight
{
    if (index == _currentIndex) {
        return;
    }
    
    if (isSwipeRight) {
        _reuseView = _view3;
        _view3 = _view2;
        _view3.frame = CGRectMake(_itemWidth * 2, 0, _itemWidth, _itemHeight);
        _view2 = _view1;
        _view2.frame = CGRectMake(_itemWidth, 0, _itemWidth, _itemHeight);
        _view1 = [self viewForItemAtIndex:index type:1];
    }
    else {
        _reuseView = _view1;
        _view1 = _view2;
        _view1.frame = CGRectMake(0, 0, _itemWidth, _itemHeight);
        _view2 = _view3;
        _view2.frame = CGRectMake(_itemWidth, 0, _itemWidth, _itemHeight);
        _view3 = [self viewForItemAtIndex:index type:3];
    }
}


//MARK:- ❤getter & setter❤
- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    _itemWidth = self.frame.size.width;
    [self resetSubviewsFrame];
}

- (void)setItemHeight:(CGFloat)itemHeight
{
    [self resetSubviewsFrame];
}

- (void)setItemsCount:(NSInteger)itemsCount
{
    if (itemsCount < 1) {
        _itemsCount = 0;
    }
    else {
        _itemsCount = itemsCount;
    }
    if (_currentIndex != [self adjustCurrentIndex:-1]) {
        [self reloadData];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
}

//MARK:- UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint contentOffset = scrollView.contentOffset;
    BOOL isSwipeRight = NO;
    
    if (contentOffset.x == _itemWidth) {
        return;
    }
    else if (contentOffset.x > _itemWidth) {
        // 向左滑动 让currentIndex加1
        _currentIndex = (_currentIndex + 1) % _itemsCount;
    }
    else if (contentOffset.x < _itemWidth) {
        // 向右滑动 让currentIndex减1
        _currentIndex = (_currentIndex + _itemsCount - 1) % _itemsCount;
        isSwipeRight = YES;
    }
    
    NSInteger lastIndex = (_currentIndex + _itemsCount - 1) % _itemsCount;
    NSInteger nextIndex = (_currentIndex + 1) % _itemsCount;
    [self preloadItemAtIndex:isSwipeRight ?lastIndex :nextIndex isSwipeRight:isSwipeRight];
    
    // 把currentIndex移到中间来
    [scrollView setContentOffset:CGPointMake(_itemWidth, 0) animated:NO];
    
    if (_didScrollBlock) {
        _didScrollBlock(_currentIndex);
    }
}

@end

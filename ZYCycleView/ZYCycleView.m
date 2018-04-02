//
//  ZYCycleView.m
//  ZYCycleView
//
//  Created by 夏小静 on 2018/3/27.
//  Copyright © 2018年 夏小静. All rights reserved.
//

#import "ZYCycleView.h"

@interface ZYCycleView()<UIScrollViewDelegate>

@property (nonatomic,strong) UIPageControl *pageControl;//分页控件

@property (nonatomic,strong) UIScrollView *cycleScrollView;//放图片scrollview

@property (nonatomic,assign) CGRect cycleFrame;//scrollviewFrame

@property (nonatomic,copy) NSMutableArray *dealImageArr;//循环轮播需要的数据

@property (nonatomic,strong) NSTimer *timer;

@end

@implementation ZYCycleView

- (instancetype)initWithFrame:(CGRect)frame withImageArr:(NSArray *)imageArr {
    self = [super initWithFrame:frame];
    if (self) {
        self.cycleFrame = frame;
        self.imageArr = imageArr;
        [self initData];//初始化默认值
        [self dealImageArray];//处理图片数据源
        [self configScrollView];//配置scrollview
        [self configPageControl];//配置分页控件
    }
    return self;
}

/*初始化默认属性*/
- (void)initData {
    _scrollTimeInterval = 1.0;
    _isShowPageControl = YES;
    _currentPageDotColor = [UIColor whiteColor];
    _pageDotColor = [UIColor lightGrayColor];
    _imageViewContentMode = UIViewContentModeScaleToFill;
}

/*处理轮播图片数据*/
- (void)dealImageArray {
    _dealImageArr = [NSMutableArray arrayWithArray:_imageArr];
    [_dealImageArr insertObject:_imageArr[0] atIndex:0];
    [_dealImageArr addObject:_imageArr.lastObject];
}

/*配置scrollview*/
- (void)configScrollView {
    [self addSubview:self.cycleScrollView];
}

/*配置分页控件*/
- (void)configPageControl {
    [self addSubview:self.pageControl];
}

/*初始化轮播控件*/
+ (instancetype)initWithFrameCycleViewFrame:(CGRect)frame imageArray:(NSArray *)imageArr {
    ZYCycleView *cycleView = [[self alloc] initWithFrame:frame withImageArr:imageArr];
    [cycleView createTimer];
    return cycleView;
}

#pragma mark - 循环timer
- (void)createTimer {
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:_scrollTimeInterval target:self selector:@selector(cyclePictures:) userInfo:nil repeats:YES];
    }
}

- (void)removeTimer {
    [self.timer invalidate];
    _timer = nil;
}

#pragma mark - 循环图片
- (void)cyclePictures:(NSTimer *)timer {
    if (self.cycleScrollView.contentOffset.x == (self.pageControl.numberOfPages+1)*CGRectGetWidth(self.bounds)) {
        [self.cycleScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds), 0) animated:NO];
        self.pageControl.currentPage = 0;
    }else{
        [self.cycleScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds)*(self.pageControl.currentPage+2), 0) animated:YES];
        self.pageControl.currentPage = self.cycleScrollView.contentOffset.x/CGRectGetWidth(self.bounds)-1;
    }
}

#pragma mark - 懒加载
- (UIScrollView *)cycleScrollView {
    if (!_cycleScrollView) {
        _cycleScrollView = [[UIScrollView alloc] initWithFrame:_cycleFrame];
        _cycleScrollView.showsHorizontalScrollIndicator = NO;
        _cycleScrollView.pagingEnabled = YES;
        _cycleScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds)*_dealImageArr.count, CGRectGetHeight(self.bounds));
        [_cycleScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds), 0)];
        for (int i = 0; i < _dealImageArr.count; i ++) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:_dealImageArr[i]];
            imageView.frame = CGRectMake(CGRectGetWidth(self.bounds)*i, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            imageView.contentMode = _imageViewContentMode;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
            [imageView addGestureRecognizer:tap];
            [_cycleScrollView addSubview:imageView];
        }
    }
    return _cycleScrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.origin.y + CGRectGetHeight(self.bounds) - 40, CGRectGetWidth(self.bounds), 40)];
        _pageControl.pageIndicatorTintColor = _pageDotColor;
        _pageControl.currentPageIndicatorTintColor = _currentPageDotColor;
        _pageControl.numberOfPages = _imageArr.count;
        [_pageControl addTarget:self action:@selector(pageIndexChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}

#pragma mark - ClickImageAction
- (void)clickImage:(UITapGestureRecognizer *)tap {
    NSInteger index = _cycleScrollView.contentOffset.x/CGRectGetWidth(self.bounds);
    if (self.backIndexBlock) {
        self.backIndexBlock(index);
    }
    if ([self.delegate respondsToSelector:@selector(cycleView:didSelectImageAtIndex:)]) {
        [self.delegate cycleView:self didSelectImageAtIndex:index];
    }
}

#pragma mark - pageControlAction
- (void)pageIndexChange:(UIPageControl *)page {
    [_cycleScrollView setContentOffset:CGPointMake((page.currentPage + 1)*CGRectGetWidth(self.bounds), 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self createTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == 0) {
        [self.cycleScrollView setContentOffset:CGPointMake(self.pageControl.numberOfPages*CGRectGetWidth(self.bounds), 0) animated:NO];
        self.pageControl.currentPage = self.pageControl.numberOfPages;
    }else if (scrollView.contentOffset.x == (self.pageControl.numberOfPages+1)*CGRectGetWidth(self.bounds)){
        
        [self.cycleScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds), 0) animated:NO];
        self.pageControl.currentPage = 0 ;
        
    }else{
        
        self.pageControl.currentPage = scrollView.contentOffset.x/CGRectGetWidth(self.bounds)-1;
        
    }
}

#pragma mark - Setter
- (void)setPageDotColor:(UIColor *)pageDotColor {
    _pageDotColor = pageDotColor;
    _pageControl.pageIndicatorTintColor = _pageDotColor;
}

- (void)setImageViewContentMode:(UIViewContentMode)imageViewContentMode {
    _imageViewContentMode = imageViewContentMode;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)view;
            imageView.contentMode = _imageViewContentMode;
        }
    }
}

- (void)setIsShowPageControl:(BOOL)isShowPageControl {
    _isShowPageControl = isShowPageControl;
    _pageControl.hidden = !isShowPageControl;
}

- (void)setPageControlFrame:(CGRect)pageControlFrame {
    _pageControlFrame = pageControlFrame;
    _pageControl.frame = pageControlFrame;
}

- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor {
    _currentPageDotColor = currentPageDotColor;
    _pageControl.currentPageIndicatorTintColor = _currentPageDotColor;
}

- (void)setScrollTimeInterval:(CGFloat)scrollTimeInterval {
    _scrollTimeInterval = scrollTimeInterval;
    [self removeTimer];
    [self createTimer];
}

@end

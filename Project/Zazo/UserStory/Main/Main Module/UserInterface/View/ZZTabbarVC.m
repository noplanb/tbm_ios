//
//  ZZTabbarVC.m
//  Zazo
//

#import "ZZTabbarVC.h"
#import "ZZMain.h"
#import "TabbarView/ZZTabbarView.h"
@import OAStackView;

@interface ZZTabbarVC () <ZZTabbarViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) OAStackView *stackView;
@property (nonatomic, strong) ZZTabbarView *tabbarView;

@property (nonatomic, weak) UIViewController *controllerThatWillAppear;

@property (nonatomic, assign) BOOL progressBarVisibilityIsBeingChanged;

@end

@implementation ZZTabbarVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        _progressBarVisibilityIsBeingChanged = NO;
        _activePageIndex = NSUIntegerMax;
    }
    return self;
}

- (void)viewDidLoad
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [super viewDidLoad];
}

- (void)loadView
{
    self.view = [UIView new];
    self.view.backgroundColor = [ZZColorTheme shared].gridBackgroundColor;
    
    CALayer *statusBarBackground = [CALayer layer];
    statusBarBackground.backgroundColor = [ZZColorTheme shared].tintColor.CGColor;
    statusBarBackground.frame = [UIApplication sharedApplication].statusBarFrame;
    [self.view.layer addSublayer:statusBarBackground];
    
    [self scrollView];
}

- (void)viewDidLayoutSubviews
{
    [self _scrollToActivePageIfNeededAnimated:NO];
}

@synthesize activePageIndex = _activePageIndex;

- (void)setActivePageIndex:(NSUInteger)activePageIndex
{
    if (_activePageIndex == activePageIndex)
    {
        UIViewController *activeViewController = self.viewControllers[activePageIndex];
        
        if ([activeViewController isKindOfClass:[UINavigationController class]])
        {
            [((UINavigationController *)activeViewController) popToRootViewControllerAnimated:YES];
        }
        
        return;
    }
    
    UIViewController<ZZTabbarViewItem> *currentItem =
        _activePageIndex == NSUIntegerMax ? nil : self.viewControllers[_activePageIndex];
    
    if ([currentItem respondsToSelector:@selector(tabbarItemDidDisappear)])
    {
        [currentItem tabbarItemDidDisappear];
    }

    _activePageIndex = activePageIndex;
    self.tabbarView.activeItemIndex = activePageIndex;

    [self _scrollToActivePageIfNeededAnimated:YES];
    
    UIViewController<ZZTabbarViewItem> *item = self.viewControllers[activePageIndex];
    
    if ([item respondsToSelector:@selector(tabbarItemDidAppear)])
    {
        [item tabbarItemDidAppear];
    }
}

@dynamic progressBarPosition;

- (void)setProgressBarPosition:(CGFloat)progressBarPosition
{
    BOOL progressBarMustBeVisible = progressBarPosition > 0.01 && progressBarPosition < 0.99;
    BOOL progressBarIsVisible = self.tabbarView.progressView.alpha > 0.99;
    
    if (progressBarMustBeVisible)
    {
        self.tabbarView.progressView.value = progressBarPosition;
    }

    if (self.progressBarVisibilityIsBeingChanged)
    {
        return;
    }
    
    if (progressBarMustBeVisible != progressBarIsVisible)
    {
        self.progressBarVisibilityIsBeingChanged = YES;
        
        NSLog(@"progressBarPosition %1.5f, progressBarMustBeVisible = %d", progressBarPosition, progressBarMustBeVisible);

        [UIView animateWithDuration:0.25 animations:^{
            self.tabbarView.progressView.alpha = progressBarMustBeVisible ? 1 : 0;
        } completion:^(BOOL finished) {
            self.progressBarVisibilityIsBeingChanged = NO;
        }];
    }
    
}

- (CGFloat)progressBarPosition
{
    return self.tabbarView.progressView.value;
}

@dynamic progressBarBadge;

- (void)setProgressBarBadge:(NSUInteger)progressBarBadge
{
    self.tabbarView.progressViewBadge = progressBarBadge;
}

- (void)_scrollToActivePageIfNeededAnimated:(BOOL)animated
{
    CGPoint offset = [self _offsetForPage:self.activePageIndex];

    if (CGPointEqualToPoint(self.scrollView.contentOffset, offset))
    {
        return;
    }

    ANCodeBlock changes = ^{
        self.scrollView.contentOffset = offset;
    };

    if (!animated)
    {
        changes();
        return;
    }

    [UIView animateWithDuration:.5
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1
                        options:0
                     animations:changes
                     completion:nil];

}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.bounces = NO;
        
        [self.view addSubview:_scrollView];
        [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.bottom.equalTo(self.tabbarView.mas_top);
        }];
    }
    return _scrollView;
}

- (ZZTabbarView *)tabbarView
{
    if (!_tabbarView) {
        _tabbarView = [[ZZTabbarView alloc] init];
        _tabbarView.delegate = self;

        [self.view addSubview:_tabbarView];
        [_tabbarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self.view);
        }];
    }
    return _tabbarView;
}


- (OAStackView *)stackView
{
    if (!_stackView)
    {
        NSArray <UIView *> *views = [self.viewControllers.rac_sequence map:^id(id value) {
            return [value view];
        }].array;
        
        _stackView = [[OAStackView alloc] initWithArrangedSubviews:views];

        [self.scrollView addSubview:_stackView];

        [views mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self.scrollView);
        }];

        [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollView);
        }];
    }
    return _stackView;
}

- (void)setViewControllers:(NSArray <UIViewController<ZZTabbarViewItem> *> *)viewControllers
{
    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger idx, BOOL *stop) {
        [controller willMoveToParentViewController:nil];
    }];

    [self.stackView removeFromSuperview];
    self.stackView = nil;

    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger idx, BOOL *stop) {
        [controller removeFromParentViewController];
    }];

    _viewControllers = viewControllers;

    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger idx, BOOL *stop) {
        [controller willMoveToParentViewController:self];
    }];

    [self stackView];

    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger idx, BOOL *stop) {
        [self addChildViewController:controller];
    }];

    self.tabbarView.items = viewControllers;
}

#pragma mark ZZTabbarViewDelegate


- (void)tabbarView:(ZZTabbarView *)tabbarView didTapOnItemWithIndex:(NSUInteger)index
{
    self.activePageIndex = index;
}

#pragma mark Scrollview Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offsetForCurrentPage = [self _offsetForPage:self.activePageIndex];
    
    CGFloat movement = offsetForCurrentPage.x - scrollView.contentOffset.x;
    
    BOOL directionRight = movement < 0;
    
    if (directionRight && [self _isLastPage:self.activePageIndex])
    {
        return;
    }
    
    if (!directionRight && [self _isFirstPage:self.activePageIndex])
    {
        return;
    }
    
    NSInteger direction = directionRight ? 1 : -1;
    NSUInteger nextIndex = self.activePageIndex + direction;
    id controllerThatWillAppear = self.viewControllers[nextIndex];
    
    UIViewController *currentVC = self.viewControllers[self.activePageIndex];
    
    if (controllerThatWillAppear == currentVC)
    {
        return; // it's current page
    }
    
    if (controllerThatWillAppear == self.controllerThatWillAppear)
    {
        return; // viewWillAppear already called
    }
    
    self.controllerThatWillAppear = controllerThatWillAppear;
    [self.controllerThatWillAppear viewWillAppear:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.viewControllers[self.activePageIndex] viewWillDisappear:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate)
    {
        return;
    }

    self.activePageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    self.controllerThatWillAppear = nil;

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDragging:scrollView willDecelerate:NO];
}

#pragma mark Support

- (BOOL)_isLastPage:(NSUInteger)index
{
    return self.viewControllers.count == index + 1;
}

- (BOOL)_isFirstPage:(NSUInteger)index
{
    return index == 0;
}

- (CGPoint)_offsetForPage:(NSUInteger)index
{
    return CGPointMake(self.scrollView.bounds.size.width * index, 0);
}

@end

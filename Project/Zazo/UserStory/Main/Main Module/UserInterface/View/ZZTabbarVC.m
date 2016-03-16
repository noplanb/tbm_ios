//
//  ZZTabbarVC.m
//  Zazo
//

#import "ZZTabbarVC.h"
#import "ZZMain.h"
#import "ZZTabbarView.h"
#import <OAStackView.h>

@interface ZZTabbarVC () <ZZTabbarViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) OAStackView *stackView;
@property (nonatomic, strong) ZZTabbarView *tabbarView;

@end

@implementation ZZTabbarVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)loadView
{
    self.view = [UIView new];
    [self scrollView];
}

- (void)setActivePageIndex:(NSUInteger)activePageIndex
{
    _activePageIndex = activePageIndex;
    self.tabbarView.activeItemIndex = activePageIndex;
    CGPoint offset = CGPointMake(self.scrollView.bounds.size.width * activePageIndex, 0);

    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:50
          initialSpringVelocity:20
                        options:0
                     animations:^{
        self.scrollView.contentOffset = offset;
    } completion:nil];
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];

        _scrollView.pagingEnabled = YES;
        [self.view addSubview:_scrollView];
        [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
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

@end

//
//  ZZTabbarVC.m
//  Zazo
//

#import "ZZTabbarVC.h"
#import "ZZMain.h"
#import "ZZTabbarView.h"
#import <OAStackView.h>

@interface ZZTabbarVC ()

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

        [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollView);
            make.size.equalTo(self.view);
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

@end

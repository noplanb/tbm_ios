//
//  ZZPlayerWireframe.m
//  Zazo
//

#import "ZZPlayerWireframe.h"
#import "ZZPlayerInteractor.h"
#import "ZZPlayerVC.h"
#import "ZZPlayerPresenter.h"
#import "ZZPlayer.h"
#import "ZZPlayerModuleDelegate.h"

@interface ZZPlayerWireframe () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak) UIViewController *parentVC;
@property (nonatomic, strong) ZZPlayerPresenter *presenter;
@property (nonatomic, strong) ZZPlayerVC *playerVC;

@end

@implementation ZZPlayerWireframe

- (instancetype)initWithVC:(UIViewController *)VC
{
    self = [super init];
    if (self) {
        _parentVC = VC;
        _parentVC.transitioningDelegate = self;

        [self _setup];
        
    }
    return self;
}

- (void)_setup
{
    ZZPlayerVC *playerController = [ZZPlayerVC new];
    ZZPlayerInteractor *interactor = [ZZPlayerInteractor new];
    ZZPlayerPresenter *presenter = [ZZPlayerPresenter new];
    
    interactor.output = presenter;
    
    playerController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:playerController];
    
    self.presenter = presenter;
    self.playerVC = playerController;
    
    playerController.transitioningDelegate = self;
    _player = presenter;
}

- (void)setDelegate:(id<ZZPlayerModuleDelegate>)delegate
{
    _delegate = delegate;
    
    self.presenter.delegate = delegate;
}

- (void)setGrid:(id<ZZGridModuleInterface>)grid
{
    _grid = grid;
    self.presenter.grid = grid;
}

- (void)setPlayerVisible:(BOOL)playerVisible
{
    if (playerVisible == _playerVisible)
    {
        return;
    }
    
    _playerVisible = playerVisible;
    
    if (playerVisible)
    {
        [self.parentVC presentViewController:self.playerVC
                                    animated:YES
                                  completion:nil];
    }
    else
    {
        [self.playerVC dismissViewControllerAnimated:YES completion:nil];
    }
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.15f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromViewController.view.userInteractionEnabled = NO;
    [transitionContext containerView].userInteractionEnabled = NO;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        fromViewController.view.alpha = 0;
    } completion:^(BOOL finished) {
        fromViewController.view.userInteractionEnabled = YES;
        [fromViewController.view removeFromSuperview];
        fromViewController.view.alpha = 1;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
    }];

}


@end

//
//  ZZPlayerWireframe.m
//  Zazo
//

#import "ZZPlayerWireframe.h"
#import "ZZPlayerInteractor.h"
#import "ZZPlayerVC.h"
#import "ZZPlayerPresenter.h"
#import "ZZPlayer.h"

@interface ZZPlayerWireframe ()

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
        [self _setup];
    }
    return self;
}

- (void)_setup
{
    ZZPlayerVC* playerController = [ZZPlayerVC new];
    ZZPlayerInteractor* interactor = [ZZPlayerInteractor new];
    ZZPlayerPresenter* presenter = [ZZPlayerPresenter new];
    
    interactor.output = presenter;
    
    playerController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:playerController];
    
    
    self.presenter = presenter;
    self.playerVC = playerController;
    
    _player = presenter;
}

- (void)setDelegate:(id<ZZPlayerModuleDelegate>)delegate
{
    _delegate = delegate;
    
    self.presenter.delegate = delegate;
}

- (void)setPlayerVisible:(BOOL)playerVisible
{
    if (playerVisible == _playerVisible)
    {
        return;
    }
    
    _playerVisible = playerVisible;
    
    [self.parentVC presentViewController:self.playerVC
                                animated:NO
                              completion:nil];
}

@end

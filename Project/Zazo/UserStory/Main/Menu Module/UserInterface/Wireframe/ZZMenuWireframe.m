//
//  ZZMenuWireframe.m
//  Zazo
//

#import "ZZMenuWireframe.h"
#import "ZZMenuInteractor.h"
#import "ZZMenuVC.h"
#import "ZZMenuPresenter.h"
#import "ZZMenu.h"

@interface ZZMenuWireframe ()

@property (nonatomic, weak) ZZMenuPresenter* presenter;
@property (nonatomic, strong, readwrite) ZZMenuVC * menuController;
@property (nonatomic, weak) UINavigationController* presentedController;

@end

@implementation ZZMenuWireframe

- (ZZMenuVC *)menuController
{
    if (!_menuController)
    {
        [self _setup];
    }
    
    return _menuController;
}

- (void)_setup
{
    ZZMenuVC* menuController = [ZZMenuVC new];
    ZZMenuInteractor* interactor = [ZZMenuInteractor new];
    ZZMenuPresenter* presenter = [ZZMenuPresenter new];
    
    interactor.output = presenter;
    
    menuController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:menuController];
    
    self.presenter = presenter;
    self.menuController = menuController;
}


@end

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
@property (nonatomic, weak) ZZMenuVC* menuController;
@property (nonatomic, weak) UINavigationController* presentedController;

@end

@implementation ZZMenuWireframe

- (void)presentMenuControllerFromNavigationController:(UINavigationController *)nc
{
    ZZMenuVC* menuController = [ZZMenuVC new];
    ZZMenuInteractor* interactor = [ZZMenuInteractor new];
    ZZMenuPresenter* presenter = [ZZMenuPresenter new];
    
    interactor.output = presenter;
    
    menuController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:menuController];
    
    ANDispatchBlockToMainQueue(^{
        [nc pushViewController:menuController animated:YES];
    });
    
    self.presenter = presenter;
    self.presentedController = nc;
    self.menuController = menuController;
}

- (void)dismissMenuController
{
    [self.presentedController popViewControllerAnimated:YES];
}

@end

//
//  ZZMainWireframe.m
//  Zazo
//

#import "ZZMainWireframe.h"
#import "ZZMainInteractor.h"
#import "ZZMainVC.h"
#import "ZZMainPresenter.h"
#import "ZZMain.h"

@interface ZZMainWireframe ()

@property (nonatomic, weak) ZZMainPresenter* presenter;
@property (nonatomic, weak) ZZMainVC* mainController;
@property (nonatomic, weak) UINavigationController* presentedController;

@end

@implementation ZZMainWireframe

- (void)presentMainControllerFromNavigationController:(UINavigationController *)nc
{
    ZZMainVC* mainController = [ZZMainVC new];
    ZZMainInteractor* interactor = [ZZMainInteractor new];
    ZZMainPresenter* presenter = [ZZMainPresenter new];
    
    interactor.output = presenter;
    
    mainController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:mainController];
    
    ANDispatchBlockToMainQueue(^{
        [nc pushViewController:mainController animated:YES];
    });
    
    self.presenter = presenter;
    self.presentedController = nc;
    self.mainController = mainController;
}

- (void)dismissMainController
{
    [self.presentedController popViewControllerAnimated:YES];
}

@end

//
//  ZZMainWireframe.m
//  Zazo
//

#import "ZZMainWireframe.h"
#import "ZZMainInteractor.h"
#import "ZZTabbarVC.h"
#import "ZZMainPresenter.h"
#import "ZZMain.h"
#import "ZZGridWireframe.h"
#import "ZZGridPresenter.h"
#import "ZZMenuPresenter.h"

@interface ZZMainWireframe ()

@property (nonatomic, weak) ZZMainPresenter* presenter;
@property (nonatomic, weak) ZZTabbarVC * mainController;
@property (nonatomic, weak) UINavigationController* presentedController;

@property (nonatomic, strong) ZZGridWireframe *gridWireframe;
@property (nonatomic, strong) ZZMenuWireframe *menuWireframe;

@end

@implementation ZZMainWireframe

- (void)presentMainControllerFromWindow:(UIWindow *)window completion:(ANCodeBlock)completionBlock;
{
    ZZTabbarVC * mainController = [ZZTabbarVC new];
    ZZMainInteractor* interactor = [ZZMainInteractor new];
    ZZMainPresenter* presenter = [ZZMainPresenter new];

    self.gridWireframe = [ZZGridWireframe new];
    self.menuWireframe = [ZZMenuWireframe new];
    
    self.gridWireframe.mainWireframe = self;
    self.menuWireframe.mainWireframe = self;    
    
    mainController.viewControllers = @[[UIViewController new], self.gridWireframe.gridController, self.menuWireframe.menuController];
    
    self.menuWireframe.presenter.menuModuleDelegate = self.gridWireframe.presenter;
    interactor.output = presenter;   
    mainController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:mainController];
    
    ANDispatchBlockToMainQueue(^{
        window.rootViewController = mainController;
    });
    
    self.presenter = presenter;
    self.mainController = mainController;
}

- (void)showTab:(ZZMainWireframeTab)tab
{
    self.presenter.activePageIndex = tab;
}

@end

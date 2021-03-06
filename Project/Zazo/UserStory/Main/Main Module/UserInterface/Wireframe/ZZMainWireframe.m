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
#import "ZZContactsPresenter.h"
#import "ZZMenuWireframe.h"
#import "ZZEditFriendListPresenter.h"
#import "ANMessagesWireframe.h"
#import "ZZEditFriendListWireframe.h"
#import "ANMessageDomainModel.h"

@interface ZZMainWireframe ()

@property (nonatomic, weak) ZZMainPresenter *presenter;
@property (nonatomic, weak) ZZTabbarVC *mainController;
@property (nonatomic, weak) UINavigationController *presentedController;

@property (nonatomic, strong) ANMessagesWireframe *messageWireframe;

@end

@implementation ZZMainWireframe

- (void)presentMainControllerFromWindow:(UIWindow *)window completion:(ANCodeBlock)completionBlock;
{
    ZZTabbarVC *mainController = [ZZTabbarVC new];
    ZZMainInteractor *interactor = [ZZMainInteractor new];
    ZZMainPresenter *presenter = [ZZMainPresenter new];

    mainController.viewControllers = @[self.menuWireframe.menuController,
            self.gridWireframe.gridController,
            self.contactsWireframe.contactsController];

    self.contactsWireframe.presenter.menuModuleDelegate = self.gridWireframe.presenter;
    interactor.output = presenter;
    mainController.eventHandler = presenter;

    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:mainController];

    UINavigationController *presentedController =
            [[UINavigationController alloc] initWithRootViewController:mainController];

    presentedController.navigationBarHidden = YES;
    presentedController.navigationBar.barTintColor = [ZZColorTheme shared].tintColor;
    presentedController.navigationBar.barStyle = UIBarStyleBlack;
    presentedController.navigationBar.tintColor = [UIColor whiteColor];
    
    ANDispatchBlockToMainQueue(^{

        [UIView transitionFromView:window.rootViewController.view
                            toView:presentedController.view
                          duration:0.65f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        completion:^(BOOL finished) {
                            
                            window.rootViewController = presentedController;
                            
                            if (completionBlock)
                            {
                                completionBlock();
                            }
                            
                        }];
    });

    self.presentedController = presentedController;

    self.presenter = presenter;
    self.mainController = mainController;
}

@dynamic activeTab;

- (void)setActiveTab:(ZZMainWireframeTab)activeTab
{
    self.presenter.activePageIndex = activeTab;
}

- (ZZMainWireframeTab)activeTab
{
    return self.presenter.activePageIndex;
}

- (void)presentEditFriendsController
{
    ZZEditFriendListWireframe *wireFrame = [ZZEditFriendListWireframe new];
    [wireFrame presentEditFriendListControllerFromNavigationController:self.presentedController];
    wireFrame.presenter.editFriendListModuleDelegate = self.gridWireframe.presenter;
}

- (void)presentSendFeedbackWithModel:(ANMessageDomainModel *)model;
{
    self.messageWireframe = [ANMessagesWireframe new];
    [self.messageWireframe presentEmailControllerFromViewController:self.presentedController
                                                          withModel:model completion:nil];
}

- (void)popToRootVC
{
    [self.presentedController popToRootViewControllerAnimated:YES];
}

@dynamic moduleInterface;

- (id <ZZMainModuleInterface>)moduleInterface
{
    return self.presenter;
}

@end

//
//  ZZMenuWireframe.m
//  Zazo
//

#import "ZZMenuWireframe.h"
#import "ZZMenuInteractor.h"
#import "ZZMenuVC.h"
#import "ZZMenuPresenter.h"
#import "ZZMenu.h"
#import "ZZMainWireframe.h"
#import "ANMessagesWireframe.h"
#import "ZZEditFriendListWireframe.h"
#import "ANMessageDomainModel.h"

@interface ZZMenuWireframe ()

@property (nonatomic, weak) ZZMenuPresenter* presenter;
@property (nonatomic, strong, readwrite) ZZMenuVC * menuController;
@property (nonatomic, weak) UINavigationController* presentedController;
@property (nonatomic, strong) ANMessagesWireframe *messageWireframe;

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

- (void)presentEditFriendsController
{
    ZZEditFriendListWireframe* wireFrame = [ZZEditFriendListWireframe new];
    [wireFrame presentEditFriendListControllerFromNavigationController:self.presentedController];
//    wireFrame.presenter.editFriendListModuleDelegate = self.presenter;
}

- (void)presentSendFeedbackWithModel:(ANMessageDomainModel*)model;
{
    self.messageWireframe = [ANMessagesWireframe new];
    [self.messageWireframe presentEmailControllerFromViewController:self.menuController withModel:model completion:nil];
}

@end

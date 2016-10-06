//
//  ZZAvatarWireframe.m
//  Zazo
//

#import "ZZAvatarWireframe.h"
#import "ZZAvatarInteractor.h"
#import "ZZAvatarVC.h"
#import "ZZAvatarPresenter.h"
#import "ZZAvatar.h"

@interface ZZAvatarWireframe ()

@property (nonatomic, weak) ZZAvatarPresenter* presenter;
@property (nonatomic, weak) ZZAvatarVC* avatarController;
@property (nonatomic, weak) UINavigationController* presentedController;

@end

@implementation ZZAvatarWireframe

- (void)presentAvatarControllerFromNavigationController:(UINavigationController *)nc
{
    ZZAvatarVC* avatarController = [ZZAvatarVC new];
    ZZAvatarInteractor* interactor = [ZZAvatarInteractor new];
    ZZAvatarPresenter* presenter = [ZZAvatarPresenter new];
    
    interactor.output = presenter;
    
    avatarController.eventHandler = presenter;
    
    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:avatarController];
    
    ANDispatchBlockToMainQueue(^{
        [nc pushViewController:avatarController animated:YES];
    });
    
    self.presenter = presenter;
    self.presentedController = nc;
    self.avatarController = avatarController;
}

- (void)dismissAvatarController
{
    [self.presentedController popViewControllerAnimated:YES];
}

@end

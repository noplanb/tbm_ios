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
#import "ZZRootWireframe.h"

@interface ZZMenuWireframe ()

@property (nonatomic, weak) ZZMenuPresenter *presenter;

@end

@implementation ZZMenuWireframe

@synthesize menuController = _menuController;

- (UIViewController *)menuController
{
    if (!_menuController)
    {
        [self _setup];
    }

    return _menuController;
}

- (void)_setup
{
    ZZMenuVC *menuController = [ZZMenuVC new];
    ZZMenuInteractor *interactor = [ZZMenuInteractor new];
    ZZMenuPresenter *presenter = [ZZMenuPresenter new];

    NetworkClient *networkClient = [NetworkClient new];
    networkClient.baseURL = [NSURL URLWithString: APIBaseURL()];
    
    ConcreteAvatarService *avatarService = [[ConcreteAvatarService alloc] init];
    avatarService.networkClient = networkClient;
    
    NSString *persistenceKey = @"avatar";
    AvatarUpdateService *updateService = [[AvatarUpdateService alloc] initWith:persistenceKey];
    updateService.legacyAvatarService = avatarService;
    updateService.delegate = interactor;
    
    interactor.networkService = avatarService;
    interactor.output = presenter;
    interactor.updateService = updateService;
    interactor.storageService = [AvatarStorageService sharedService];
    
    menuController.eventHandler = presenter;

    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:menuController];

    self.presenter = presenter;
    _menuController = menuController;
}

- (void)showSecretScreen
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ZZNeedsToShowSecretScreenNotificationName object:nil];
}

@end

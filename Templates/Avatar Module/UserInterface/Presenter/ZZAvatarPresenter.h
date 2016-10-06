//
//  ZZAvatarPresenter.h
//  Zazo
//

#import "ZZAvatarInteractorIO.h"
#import "ZZAvatarWireframe.h"
#import "ZZAvatarViewInterface.h"
#import "ZZAvatarModuleDelegate.h"
#import "ZZAvatarModuleInterface.h"

@interface ZZAvatarPresenter : NSObject <ZZAvatarInteractorOutput, ZZAvatarModuleInterface>

@property (nonatomic, strong) id<ZZAvatarInteractorInput> interactor;
@property (nonatomic, strong) ZZAvatarWireframe* wireframe;

@property (nonatomic, weak) UIViewController<ZZAvatarViewInterface>* userInterface;
@property (nonatomic, weak) id<ZZAvatarModuleDelegate> avatarModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController<ZZAvatarViewInterface>*)userInterface;

@end

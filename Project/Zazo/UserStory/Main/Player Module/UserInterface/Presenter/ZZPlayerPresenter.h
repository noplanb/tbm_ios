//
//  ZZPlayerPresenter.h
//  Zazo
//

#import "ZZPlayerInteractorIO.h"
#import "ZZPlayerViewInterface.h"
#import "ZZPlayerModuleDelegate.h"
#import "ZZPlayerModuleInterface.h"
#import "ZZGridModuleInterface.h"

@class ZZPlayerWireframe;

@interface ZZPlayerPresenter : NSObject <ZZPlayerInteractorOutput, ZZPlayerModuleInterface>

@property (nonatomic, strong) id<ZZPlayerInteractorInput> interactor;
@property (nonatomic, weak) ZZPlayerWireframe *wireframe;

@property (nonatomic, weak) UIViewController<ZZPlayerViewInterface> *userInterface;
@property (nonatomic, weak) id<ZZPlayerModuleDelegate> delegate;
@property (nonatomic, weak) id<ZZGridModuleInterface> grid;

- (void)configurePresenterWithUserInterface:(UIViewController <ZZPlayerViewInterface> *)userInterface;

@end

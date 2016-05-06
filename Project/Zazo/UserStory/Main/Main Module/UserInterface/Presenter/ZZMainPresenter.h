//
//  ZZMainPresenter.h
//  Zazo
//

#import "ZZMainInteractorIO.h"
#import "ZZMainWireframe.h"
#import "ZZMainViewInterface.h"
#import "ZZMainModuleDelegate.h"
#import "ZZMainModuleInterface.h"

@interface ZZMainPresenter : NSObject <ZZMainInteractorOutput, ZZMainModuleInterface>

@property (nonatomic, strong) id <ZZMainInteractorInput> interactor;
@property (nonatomic, strong) ZZMainWireframe *wireframe;

@property (nonatomic, weak) UIViewController <ZZMainViewInterface> *userInterface;
@property (nonatomic, weak) id <ZZMainModuleDelegate> mainModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController <ZZMainViewInterface> *)userInterface;

@end

//
//  ZZDebugStatePresenter.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZDebugStateInteractorIO.h"
#import "ZZDebugStateWireframe.h"
#import "ZZDebugStateViewInterface.h"
#import "ZZDebugStateModuleDelegate.h"
#import "ZZDebugStateModuleInterface.h"

@interface ZZDebugStatePresenter : NSObject <ZZDebugStateInteractorOutput, ZZDebugStateModuleInterface>

@property (nonatomic, strong) id<ZZDebugStateInteractorInput> interactor;
@property (nonatomic, strong) ZZDebugStateWireframe* wireframe;

@property (nonatomic, weak) UIViewController<ZZDebugStateViewInterface>* userInterface;
@property (nonatomic, weak) id<ZZDebugStateModuleDelegate> debugstateModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController<ZZDebugStateViewInterface>*)userInterface;

@end

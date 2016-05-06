//
//  ZZAuthPresenter.h
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthInteractorIO.h"
#import "ZZAuthWireframe.h"
#import "ZZAuthViewInterface.h"
#import "ZZAuthModuleDelegate.h"
#import "ZZAuthModuleInterface.h"

@interface ZZAuthPresenter : NSObject <ZZAuthInteractorOutput, ZZAuthModuleInterface>

@property (nonatomic, strong) id <ZZAuthInteractorInput> interactor;
@property (nonatomic, strong) ZZAuthWireframe *wireframe;

@property (nonatomic, weak) UIViewController <ZZAuthViewInterface> *userInterface;
@property (nonatomic, weak) id <ZZAuthModuleDelegate> authModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController <ZZAuthViewInterface> *)userInterface;

@end

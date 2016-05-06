//
//  ZZStartPresenter.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStartInteractorIO.h"
#import "ZZStartWireframe.h"
#import "ZZStartViewInterface.h"
#import "ZZStartModuleDelegate.h"
#import "ZZStartModuleInterface.h"

@interface ZZStartPresenter : NSObject <ZZStartInteractorOutput, ZZStartModuleInterface>

@property (nonatomic, strong) id <ZZStartInteractorInput> interactor;
@property (nonatomic, strong) ZZStartWireframe *wireframe;

@property (nonatomic, weak) UIViewController <ZZStartViewInterface> *userInterface;
@property (nonatomic, weak) id <ZZStartModuleDelegate> startModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController <ZZStartViewInterface> *)userInterface;

@end

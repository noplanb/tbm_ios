//
//  ZZSecretScreenPresenter.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenInteractorIO.h"
#import "ZZSecretScreenWireframe.h"
#import "ZZSecretScreenViewInterface.h"
#import "ZZSecretScreenModuleDelegate.h"
#import "ZZSecretScreenModuleInterface.h"

@interface ZZSecretScreenPresenter : NSObject <ZZSecretScreenInteractorOutput, ZZSecretScreenModuleInterface>

@property (nonatomic, strong) id<ZZSecretScreenInteractorInput> interactor;
@property (nonatomic, strong) ZZSecretScreenWireframe* wireframe;

@property (nonatomic, weak) UIViewController<ZZSecretScreenViewInterface>* userInterface;
@property (nonatomic, weak) id<ZZSecretScreenModuleDelegate> secretScreenModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController<ZZSecretScreenViewInterface>*)userInterface;

@end

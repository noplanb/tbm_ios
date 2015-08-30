//
//  ZZSecretPresenter.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretInteractorIO.h"
#import "ZZSecretWireframe.h"
#import "ZZSecretViewInterface.h"
#import "ZZSecretModuleDelegate.h"
#import "ZZSecretModuleInterface.h"

@interface ZZSecretPresenter : NSObject <ZZSecretInteractorOutput, ZZSecretModuleInterface>

@property (nonatomic, strong) id<ZZSecretInteractorInput> interactor;
@property (nonatomic, strong) ZZSecretWireframe* wireframe;

@property (nonatomic, weak) UIViewController<ZZSecretViewInterface>* userInterface;
@property (nonatomic, weak) id<ZZSecretModuleDelegate> secretModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController<ZZSecretViewInterface>*)userInterface;

@end

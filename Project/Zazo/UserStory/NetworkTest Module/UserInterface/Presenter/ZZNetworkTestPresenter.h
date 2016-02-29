//
//  ZZNetworkTestPresenter.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTestInteractorIO.h"
#import "ZZNetworkTestWireframe.h"
#import "ZZNetworkTestViewInterface.h"
#import "ZZNetworkTestModuleDelegate.h"
#import "ZZNetworkTestModuleInterface.h"

@interface ZZNetworkTestPresenter : NSObject <ZZNetworkTestInteractorOutput, ZZNetworkTestModuleInterface>

@property (nonatomic, strong) id<ZZNetworkTestInteractorInput> interactor;
@property (nonatomic, strong) ZZNetworkTestWireframe* wireframe;

@property (nonatomic, weak) UIViewController<ZZNetworkTestViewInterface>* userInterface;
@property (nonatomic, weak) id<ZZNetworkTestModuleDelegate> networkTestModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController<ZZNetworkTestViewInterface>*)userInterface;

@end

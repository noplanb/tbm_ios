//
//  ZZMenuPresenter.h
//  zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuInteractorIO.h"
#import "ZZMenuWireframe.h"
#import "ZZMenuViewInterface.h"
#import "ZZMenuModuleDelegate.h"
#import "ZZMenuModuleInterface.h"
#import "ZZGridModuleDelegate.h"
#import "ANDrawerNC.h"

@interface ZZMenuPresenter : NSObject
<   ZZMenuInteractorOutput,
    ZZMenuModuleInterface,
    ANDrawerNCDelegate
>

@property (nonatomic, strong) id<ZZMenuInteractorInput> interactor;
@property (nonatomic, strong) ZZMenuWireframe* wireframe;

@property (nonatomic, weak) UIViewController<ZZMenuViewInterface>* userInterface;
@property (nonatomic, weak) id<ZZMenuModuleDelegate> menuModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController<ZZMenuViewInterface>*)userInterface;
- (void)reloadContactMenuData;
- (void)reloadContacts;

@end

//
//  ZZGridPresenter.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridInteractorIO.h"
#import "ZZGridViewInterface.h"
#import "ZZGridModuleDelegate.h"
#import "ZZGridModuleInterface.h"
#import "ZZContactsModuleDelegate.h"
#import "ZZGridWireframe.h"
#import "ZZEditFriendListModuleDelegate.h"
#import "ZZGridPresenterInterface.h"
#import "ZZEditFriendEnumsAdditions.h"
@class ZZGridWireframe;

@interface ZZGridPresenter : NSObject
<
    ZZGridInteractorOutput,
    ZZGridModuleInterface,
    ZZContactsModuleDelegate,
    ZZEditFriendListModuleDelegate,
    ZZGridPresenterInterface,
    ZZGridInteractorOutputActionHandler
>

@property (nonatomic, strong) id<ZZGridInteractorInput> interactor;
@property (nonatomic, strong) ZZGridWireframe* wireframe;

@property (nonatomic, weak) UIViewController<ZZGridViewInterface>* userInterface;
@property (nonatomic, weak) id<ZZGridModuleDelegate> gridModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController<ZZGridViewInterface>*)userInterface;

@end

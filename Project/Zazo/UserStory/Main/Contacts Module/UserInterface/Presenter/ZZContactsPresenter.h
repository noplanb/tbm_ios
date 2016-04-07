//
//  ZZContactsPresenter.h
//  zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactsInteractorIO.h"
#import "ZZContactsWireframe.h"
#import "ZZContactsViewInterface.h"
#import "ZZContactsModuleDelegate.h"
#import "ZZContactsModuleInterface.h"
#import "ZZGridModuleDelegate.h"

@interface ZZContactsPresenter : NSObject <ZZContactsInteractorOutput, ZZContactsModuleInterface>

@property (nonatomic, strong) id<ZZContactsInteractorInput> interactor;
@property (nonatomic, strong) ZZContactsWireframe * wireframe;

@property (nonatomic, weak) UIViewController<ZZContactsViewInterface>* userInterface;
@property (nonatomic, weak) id<ZZContactsModuleDelegate> menuModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController<ZZContactsViewInterface>*)userInterface;
- (void)reloadContactMenuData;
- (void)reloadContacts;

@end

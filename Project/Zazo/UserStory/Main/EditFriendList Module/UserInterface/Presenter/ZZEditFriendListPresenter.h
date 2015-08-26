//
//  ZZEditFriendListPresenter.h
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEditFriendListInteractorIO.h"
#import "ZZEditFriendListWireframe.h"
#import "ZZEditFriendListViewInterface.h"
#import "ZZEditFriendListModuleDelegate.h"
#import "ZZEditFriendListModuleInterface.h"

@interface ZZEditFriendListPresenter : NSObject <ZZEditFriendListInteractorOutput, ZZEditFriendListModuleInterface>

@property (nonatomic, strong) id<ZZEditFriendListInteractorInput> interactor;
@property (nonatomic, strong) ZZEditFriendListWireframe* wireframe;

@property (nonatomic, weak) UIViewController<ZZEditFriendListViewInterface>* userInterface;
@property (nonatomic, weak) id<ZZEditFriendListModuleDelegate> editFriendListModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController<ZZEditFriendListViewInterface>*)userInterface;

@end

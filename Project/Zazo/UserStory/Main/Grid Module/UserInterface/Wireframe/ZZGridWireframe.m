//
//  ZZGridWireframe.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridWireframe.h"
#import "ZZGridInteractor.h"
#import "ZZGridVC.h"
#import "ZZGridPresenter.h"
#import "ZZEditFriendListWireframe.h"
#import "ANMessagesWireframe.h"
#import "ZZEditFriendListPresenter.h"
#import "ZZMainWireframe.h"
#import "ZZPlayerWireframe.h"
#import "ZZGridCollectionController.h"
#import "ZZFriendDataProvider.h"
#import "ZZGridCell.h"

@interface ZZGridWireframe ()

@property (nonatomic, strong) UINavigationController *presentedController;
@property (nonatomic, strong) ANMessagesWireframe *messageWireframe;
@property (nonatomic, strong) ZZPlayerWireframe *playerWireframe;
@property (nonatomic, strong) TranscriptModuleAssembly *transcriptAssembly;
@property (nonatomic, strong) ComposeAssembly *composeAssembly;

@end

@implementation ZZGridWireframe

@synthesize gridController = _gridController;
@synthesize presenter = _presenter;

- (UIViewController *)gridController
{
    if (!_gridController)
    {
        [self _setup];
    }
    return _gridController;
}


- (void)dismissGridController
{
    [self.presentedController popViewControllerAnimated:YES];
}

#pragma mark - Details

- (void)presentComposeForUserWithID:(NSString *)friendID
{
    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:friendID];
    
    self.composeAssembly = [[ComposeAssembly alloc] initWithPresentFromVC:self.gridController toFriendWithKey:friendModel.mKey];
    
    ZZGridVC *gridVC = (ZZGridVC *)self.gridController;
    UIView *fromView = [gridVC.controller gridCellWithFriendModel:friendModel];

    [self.composeAssembly.module presentFrom:fromView];
}

- (void)presentTranscriptionForUserWithID:(NSString *)friendID
{
    self.transcriptAssembly = [[TranscriptModuleAssembly alloc] initWith:self.gridController];
    
    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:friendID];
    ZZGridVC *gridVC = (ZZGridVC *)self.gridController;
    UIView *fromView = [gridVC.controller gridCellWithFriendModel:friendModel];
    
    [self.transcriptAssembly.module presentFor:friendID from:fromView];
}

- (void)presentSMSDialogWithModel:(ANMessageDomainModel *)model
                          success:(ANCodeBlock)success
                             fail:(ANCodeBlock)fail
{
    self.messageWireframe = [ANMessagesWireframe new];
    
    [self.messageWireframe presentMessageControllerFromViewController:self.gridController
                                                            withModel:model
                                                           completion:^(MessageComposeResult result) {                                                               
        switch (result)
        {
            case MessageComposeResultSent:
            {
                if (success) success();
            }
                break;
            default:
            {
                if (fail) fail();
            }
                break;
        }
    }];
}

- (void)presentSharingDialogWithModel:(ANMessageDomainModel *)model
                              success:(ANCodeBlock)success
                                 fail:(ANCodeBlock)fail
{
    self.messageWireframe = [ANMessagesWireframe new];
    [self.messageWireframe presentSharingControllerFromViewController:self.gridController
                                                            withModel:model
                                                           completion:^(BOOL completed) {

                                                               ANCodeBlock block = completed ? success : fail;

                                                               if (block)
                                                               {
                                                                   block();
                                                               }

                                                           }];
}

#pragma mark - Private

- (void)_setup
{
    ZZGridVC *gridController = [ZZGridVC new];
    ZZGridInteractor *interactor = [ZZGridInteractor new];
    ZZGridPresenter *presenter = [ZZGridPresenter new];

    interactor.output = presenter;

    gridController.eventHandler = presenter;

    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:gridController];

    _presenter = presenter;
    _gridController = gridController;
    
    [self _setupPlayer];
}

- (void)_setupPlayer
{
    _playerWireframe = [[ZZPlayerWireframe alloc] initWithVC:self.gridController];
    
    _playerWireframe.delegate = self.presenter;
    _playerWireframe.grid = self.presenter;
    
    self.presenter.videoPlayer = _playerWireframe.player;
}

@end

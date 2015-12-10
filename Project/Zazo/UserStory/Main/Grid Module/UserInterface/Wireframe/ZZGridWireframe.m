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
#import "ZZEditFriendListPresenter.h"

#import "ANMessagesWireframe.h"
#import "DeviceUtil.h"


@interface ZZGridWireframe ()

@property (nonatomic, strong) ZZGridVC* gridController;
@property (nonatomic, strong) UINavigationController* presentedController;
@property (nonatomic, strong) ANMessagesWireframe* emailWireframe;

@end

@implementation ZZGridWireframe

- (void)presentGridControllerFromNavigationController:(UINavigationController*)nc completion:(ANCodeBlock)completionBlock
{
    [self _setup];
    ANDispatchBlockToMainQueue(^{
        [nc pushViewController:self.gridController animated:YES];
        
        if (completionBlock)
        {
            completionBlock();
        }
        
    });
    
    self.presentedController = nc;
}

- (void)dismissGridController
{
    [self.presentedController popViewControllerAnimated:YES];
}

- (void)toggleMenu
{
    [self.menuWireFrame toggleMenu];
}

- (void)closeMenu
{
    [self.menuWireFrame closeMenu];
}


#pragma mark - Details

- (void)presentEditFriendsController
{
    [self closeMenu];
    
    ZZEditFriendListWireframe* wireFrame = [ZZEditFriendListWireframe new];
    [wireFrame presentEditFriendListControllerFromNavigationController:self.presentedController];
    wireFrame.presenter.editFriendListModuleDelegate = self.presenter;
}

- (void)presentSendFeedbackWithModel:(ANMessageDomainModel*)model;
{
    self.emailWireframe = [ANMessagesWireframe new];
    [self.emailWireframe presentEmailControllerFromViewController:self.gridController withModel:model completion:nil];
}

- (void)presentSMSDialogWithModel:(ANMessageDomainModel*)model success:(ANCodeBlock)success fail:(ANCodeBlock)fail
{
    self.emailWireframe = [ANMessagesWireframe new];
    [self.emailWireframe presentMessageControllerFromViewController:self.gridController withModel:model completion:^(MessageComposeResult result) {
        switch (result)
        {
            case MessageComposeResultSent:
            {
                if (success) success();
            } break;
            default:
            {
                if (fail) fail();
            } break;
        }
    }];
}

- (void)attachAdditionalPanGestureToMenu:(UIPanGestureRecognizer*)pan
{
    [self.menuWireFrame attachAdditionalPanGestureToMenu:pan];
}


#pragma mark - Private

- (void)_setup
{
    ZZGridVC* gridController = [ZZGridVC new];
    ZZGridInteractor* interactor = [ZZGridInteractor new];
    ZZGridPresenter* presenter = [ZZGridPresenter new];
    
    interactor.output = presenter;
    
    gridController.eventHandler = presenter;

    presenter.interactor = interactor;
    presenter.wireframe = self;
    [presenter configurePresenterWithUserInterface:gridController];
    
    self.presenter = presenter;
    self.gridController = gridController;
}

@end

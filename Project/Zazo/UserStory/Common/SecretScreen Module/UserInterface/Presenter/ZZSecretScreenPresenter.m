//
//  ZZSecretScreenPresenter.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenPresenter.h"
#import "ZZSettingsModel.h"

@interface ZZSecretScreenPresenter ()

@end

@implementation ZZSecretScreenPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZSecretScreenViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    [self.interactor loadData];
}


#pragma mark - Output

- (void)dataLoaded:(ZZSettingsModel*)data
{
    //TODO:
}


#pragma mark - Module Interface


- (void)forceCrash
{
    [self.interactor forceCrash];
}

- (void)dispatchData
{
    [self.interactor dispatchData];
}

- (void)resetHints
{
    [self.interactor resetHints];
}

- (void)updateDebugModeStateTo:(BOOL)isEnabled
{
    [self.interactor updateDebugStateTo:isEnabled];
}

- (void)updateServerStateTo:(NSInteger)state
{
    [self.interactor updateServerStateTo:state];
    [self.userInterface updateCustomServerFieldToEnabled:(state == 2)]; // TODO: states
}

- (void)updateCustomServerEnpointValueTo:(NSString *)value
{
    [self.interactor updateCustomServerEnpointValueTo:value];
}

- (void)dismissController
{
    [self.wireframe dismissSecretScreenController];
}

- (void)presentStateController
{
    [self.wireframe presentStateController];
}

- (void)presentLogsController
{
    [self.wireframe presentLogsController];
}

@end

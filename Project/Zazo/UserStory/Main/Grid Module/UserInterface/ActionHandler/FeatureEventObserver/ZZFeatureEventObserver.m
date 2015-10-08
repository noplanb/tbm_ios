//
//  ZZFeatureEventObserver.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventObserver.h"
#import "ZZFeatureEventStrategyBase.h"
#import "ZZUserDataProvider.h"
#import "ZZFeatureEventStrategyInviteeUser.h"
#import "ZZFeatureEventStrategyRegisteredUser.h"

@interface ZZFeatureEventObserver ()

@property (nonatomic, strong) ZZFeatureEventStrategyBase* strategy;

@end

@implementation ZZFeatureEventObserver


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self _setupStrategy];
    }
    return self;
}


#pragma mark - Strategy Configuration

- (void)_setupStrategy
{
    ZZUserDomainModel* authUser = [ZZUserDataProvider authenticatedUser];
    
    if (authUser.isInvitee)
    {
        self.strategy = [ZZFeatureEventStrategyInviteeUser new];
    }
    else
    {
        self.strategy = [ZZFeatureEventStrategyRegisteredUser new];
    }
}

- (void)handleEvent:(ZZGridActionEventType)event withModel:(ZZGridCellViewModel*)model
{
    switch (event)
    {
        case ZZGridActionEventTypeMessageDidSent:
        {
            [self _handleBothCameraFeatureWithViewModel:model];
            [self _handleAbortRecordingWithDragWithViewModel:model];
            
        }break;
    }
}

- (void)_handleBothCameraFeatureWithViewModel:(ZZGridCellViewModel*)viewModel
{
    [self.strategy handleBothCameraFeatureWithModel:viewModel withCompletionBlock:^(BOOL isFeatureEnabled) {
        if (isFeatureEnabled)
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeSwitchCamera];
        }
        else
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionEventTypeNone];
        }
    }];
}

- (void)_handleAbortRecordingWithDragWithViewModel:(ZZGridCellViewModel*)model
{
    [self.strategy handleAbortRecordingFeatureWithModel:model withCompletionBlock:^(BOOL isFeatureEnabled) {
        if (isFeatureEnabled)
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionFeatureTypeAbortRec];
        }
        else
        {
            [self.delegate handleUnlockFeatureWithType:ZZGridActionEventTypeNone];
        }
    }];
}

@end

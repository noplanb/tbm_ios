//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMTutorialSystem.h"
#import "TBMGridModuleInterface.h"
#import "TBMEventsFlowModuleInterface.h"
#import "TBMEventsFlowModulePresenter.h"
#import "TBMHomeViewController.h"
#import "TBMInviteSomeOneElseHintPresenter.h"
#import "TBMPlayHintPresenter.h"
#import "TBMViewedHintPresenter.h"
#import "TBMWelcomeHintPresenter.h"
#import "TBMSentHintPresenter.h"
#import "TBMRecordHintPresenter.h"
#import "TBMInviteHintPresenter.h"
#import "TBMFeatureUnlockModulePresenter.h"
#import "TBMNextFeatureDialogPresenter.h"
#import "TBMAbortRecordUsageHintPresenter.h"
#import "TBMFrontCameraUsageHintPresenter.h"
#import "TBMEarpieceUsageHintPresenter.h"
#import "TBMRecordWelcomeHintPresenter.h"


@interface TBMTutorialSystem ()

// Hints
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> inviteHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> inviteSomeOneElseHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> playHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> recordHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> recordWelcomeHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> sentHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> viewedHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> welcomeHintModule;

@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> abortRecordUsageHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> frontCameraUsageHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> earpieceUsageHintModule;

@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler, TBMFeatureUnlockModuleInterface> featureUnlockModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> nextFeatureModule;
@property(nonatomic, strong) id <TBMHomeModuleInterface> homeModule;
@end

@implementation TBMTutorialSystem

//TODO:Refactor it: move to app delegate and remove grid module from parameter and put it into setup method


- (void)setupHandlersWithGridModule:(TBMHomeViewController *)homeController
{
    //TODO: Remove HomeViewController from here after it will transform to module
//    [self.eventsFlowModule setupGridModule:gridModule]; TODO: Bring here from TBMHomeViewController
    [homeController setupEvensFlowModule:self.eventsFlowModule];
    self.homeModule = homeController;
    /**
     * Hints
     */
    [self.eventsFlowModule addEventHandler:self.inviteHintModule];
    [self.eventsFlowModule addEventHandler:self.inviteSomeOneElseHintModule];
    [self.eventsFlowModule addEventHandler:self.playHintModule];
    [self.eventsFlowModule addEventHandler:self.recordWelcomeHintModule];
    [self.eventsFlowModule addEventHandler:self.recordHintModule];
    [self.eventsFlowModule addEventHandler:self.sentHintModule];
    [self.eventsFlowModule addEventHandler:self.viewedHintModule];
    [self.eventsFlowModule addEventHandler:self.welcomeHintModule];

    [self.eventsFlowModule addEventHandler:self.frontCameraUsageHintModule];
    [self.eventsFlowModule addEventHandler:self.abortRecordUsageHintModule];
    [self.eventsFlowModule addEventHandler:self.earpieceUsageHintModule];

    /**
     * Features
     */
    [self.eventsFlowModule addEventHandler:self.featureUnlockModule];
    [self.eventsFlowModule addEventHandler:self.nextFeatureModule];


}

#pragma mark - Modules initialization

- (id <TBMEventsFlowModuleInterface>)eventsFlowModule
{
    if (!_eventsFlowModule)
    {
        _eventsFlowModule = [[TBMEventsFlowModulePresenter alloc] init];
    }
    return _eventsFlowModule;

}

- (id <TBMEventsFlowModuleEventHandler>)inviteHintModule
{
    if (!_inviteHintModule)
    {
        TBMInviteHintPresenter *inviteHintModule = [TBMInviteHintPresenter new];
        [inviteHintModule setupEventFlowModule:self.eventsFlowModule];
        _inviteHintModule = inviteHintModule;
    }
    return _inviteHintModule;
}

- (id <TBMEventsFlowModuleEventHandler>)inviteSomeOneElseHintModule
{
    if (!_inviteSomeOneElseHintModule)
    {
        TBMInviteSomeOneElseHintPresenter *inviteSomeOneElseHintModule = [[TBMInviteSomeOneElseHintPresenter alloc] init];
        [inviteSomeOneElseHintModule setupEventFlowModule:self.eventsFlowModule];
        _inviteSomeOneElseHintModule = inviteSomeOneElseHintModule;
    }
    return _inviteSomeOneElseHintModule;
}

- (id <TBMEventsFlowModuleEventHandler>)playHintModule
{
    if (!_playHintModule)
    {
        TBMPlayHintPresenter *playHintPresenter = [[TBMPlayHintPresenter alloc] init];
        [playHintPresenter setupEventFlowModule:self.eventsFlowModule];
        _playHintModule = playHintPresenter;
    }
    return _playHintModule;
}

- (id <TBMEventsFlowModuleEventHandler>)recordHintModule
{
    if (!_recordHintModule)
    {
        TBMRecordHintPresenter *recordHintPresenter = [[TBMRecordHintPresenter alloc] init];
        [recordHintPresenter setupEventFlowModule:self.eventsFlowModule];
        _recordHintModule = recordHintPresenter;
    }
    return _recordHintModule;
}

- (id <TBMEventsFlowModuleEventHandler>)recordWelcomeHintModule
{
    if (!_recordWelcomeHintModule)
    {
        TBMRecordWelcomeHintPresenter *recordWelcomeHintModule = [[TBMRecordWelcomeHintPresenter alloc] init];
        [recordWelcomeHintModule setupEventFlowModule:self.eventsFlowModule];
        _recordWelcomeHintModule = recordWelcomeHintModule;
    }
    return _recordWelcomeHintModule;
}


- (id <TBMEventsFlowModuleEventHandler>)sentHintModule
{
    if (!_sentHintModule)
    {
        TBMSentHintPresenter *sentHintPresenter = [[TBMSentHintPresenter alloc] init];
        [sentHintPresenter setupEventFlowModule:self.eventsFlowModule];
        _sentHintModule = sentHintPresenter;
    }
    return _sentHintModule;
}

- (id <TBMEventsFlowModuleEventHandler>)viewedHintModule
{
    if (!_viewedHintModule)
    {
        TBMViewedHintPresenter *viewedHintPresenter = [[TBMViewedHintPresenter alloc] init];
        [viewedHintPresenter setupEventFlowModule:self.eventsFlowModule];
        _viewedHintModule = viewedHintPresenter;
    }
    return _viewedHintModule;
}

- (id <TBMEventsFlowModuleEventHandler>)welcomeHintModule
{
    if (!_welcomeHintModule)
    {
        TBMWelcomeHintPresenter *welcomeHintPresenter = [[TBMWelcomeHintPresenter alloc] init];
        [welcomeHintPresenter setupEventFlowModule:self.eventsFlowModule];
        _welcomeHintModule = welcomeHintPresenter;
    }
    return _welcomeHintModule;
}

- (id <TBMEventsFlowModuleEventHandler>)abortRecordUsageHintModule
{
    if (!_abortRecordUsageHintModule)
    {
        TBMAbortRecordUsageHintPresenter *recordUsageHintPresenter = [[TBMAbortRecordUsageHintPresenter alloc] init];
        [recordUsageHintPresenter setupEventFlowModule:self.eventsFlowModule];
        _abortRecordUsageHintModule = recordUsageHintPresenter;
    }
    return _abortRecordUsageHintModule;
}

- (id <TBMEventsFlowModuleEventHandler>)frontCameraUsageHintModule
{
    if (!_featureUnlockModule)
    {
        TBMFrontCameraUsageHintPresenter *frontCameraUsageHintModule = [[TBMFrontCameraUsageHintPresenter alloc] init];
        [frontCameraUsageHintModule setupEventFlowModule:self.eventsFlowModule];
        _frontCameraUsageHintModule = frontCameraUsageHintModule;
    }
    return _frontCameraUsageHintModule;
}


- (id <TBMEventsFlowModuleEventHandler>)earpieceUsageHintModule
{
    if (!_earpieceUsageHintModule)
    {
        TBMEarpieceUsageHintPresenter *earpieceUsageHintModule = [[TBMEarpieceUsageHintPresenter alloc] init];
        [earpieceUsageHintModule setupEventFlowModule:self.eventsFlowModule];
        _earpieceUsageHintModule = earpieceUsageHintModule;
    }
    return _earpieceUsageHintModule;
}

- (id <TBMEventsFlowModuleEventHandler, TBMFeatureUnlockModuleInterface>)featureUnlockModule
{
    if (!_featureUnlockModule)
    {
        TBMFeatureUnlockModulePresenter *featureUnlockModule = [[TBMFeatureUnlockModulePresenter alloc] init];
        [featureUnlockModule setupEventFlowModule:self.eventsFlowModule];
        _featureUnlockModule = featureUnlockModule;
    }
    return _featureUnlockModule;
}

- (id <TBMEventsFlowModuleEventHandler>)nextFeatureModule
{
    if (!_nextFeatureModule)
    {
        TBMNextFeatureDialogPresenter *nextFeatureDialogPresenter = [[TBMNextFeatureDialogPresenter alloc] init];
        [nextFeatureDialogPresenter setupHomeModule:self.homeModule];
        [nextFeatureDialogPresenter setupEventFlowModule:self.eventsFlowModule];
        [nextFeatureDialogPresenter setupFeatureUnlockModule:self.featureUnlockModule];
        [nextFeatureDialogPresenter setupInviteSomeOneElseHintModule:self.inviteSomeOneElseHintModule];
        _nextFeatureModule = nextFeatureDialogPresenter;
    }
    return _nextFeatureModule;
}

#pragma mark Hints modules


@end
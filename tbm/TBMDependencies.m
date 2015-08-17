//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMDependencies.h"
#import "TBMGridModuleInterface.h"
#import "TBMEventsFlowModuleInterface.h"
#import "TBMEventsFlowModulePresenter.h"
#import "TBMInviteHintView.h"
#import "TBMInviteHintPresenter.h"
#import "TBMHomeViewController.h"
#import "TBMInviteSomeOneElseHintPresenter.h"
#import "TBMPlayHintPresenter.h"
#import "TBMViewedHintPresenter.h"
#import "TBMWelcomeHintPresenter.h"
#import "TBMSentHintPresenter.h"
#import "TBMRecordHintPresenter.h"


@interface TBMDependencies ()

// Hints
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> inviteHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> inviteSomeOneElseHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> playHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> recordHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> sentHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> viewedHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> welcomeHintModule;
@end

@implementation TBMDependencies

//TODO:Refactor it: move to app delegate and remove grid module from parameter and put it into setup method


- (void)setupDependenciesWithHomeViewController:(TBMHomeViewController *)homeController {
    //TODO: Remove HomeViewController from here after it will transform to module
//    [self.eventsFlowModule setupGridModule:gridModule]; TODO: Bring here from TBMHomeViewController
    [homeController setupEvensFlowModule:self.eventsFlowModule];

    [self.eventsFlowModule addEventHandler:self.inviteHintModule];
    [self.eventsFlowModule addEventHandler:self.inviteSomeOneElseHintModule];
    [self.eventsFlowModule addEventHandler:self.playHintModule];
    [self.eventsFlowModule addEventHandler:self.recordHintModule];
    [self.eventsFlowModule addEventHandler:self.sentHintModule];
    [self.eventsFlowModule addEventHandler:self.viewedHintModule];
    [self.eventsFlowModule addEventHandler:self.welcomeHintModule];

}

#pragma mark - Modules initialization

- (id <TBMEventsFlowModuleInterface>)eventsFlowModule {
    if (!_eventsFlowModule) {
        _eventsFlowModule = [[TBMEventsFlowModulePresenter alloc] init];
    }
    return _eventsFlowModule;

}

- (id <TBMEventsFlowModuleEventHandler>)inviteHintModule {
    if (!_inviteHintModule) {
        TBMInviteHintPresenter *inviteHintModule = [[TBMInviteHintPresenter alloc] init];
        [inviteHintModule setupEventFlowModule:self.eventsFlowModule];
        _inviteHintModule = inviteHintModule;
    }
    return _inviteHintModule;
}

- (id <TBMEventsFlowModuleEventHandler>)inviteSomeOneElseHintModule {
    if (!_inviteSomeOneElseHintModule) {
        TBMInviteSomeOneElseHintPresenter *inviteSomeOneElseHintModule = [[TBMInviteHintPresenter alloc] init];
        [inviteSomeOneElseHintModule setupEventFlowModule:self.eventsFlowModule];
        _inviteSomeOneElseHintModule = inviteSomeOneElseHintModule;
    }
    return _inviteSomeOneElseHintModule;
}

- (id <TBMEventsFlowModuleEventHandler>)playHintModule {
    if (!_playHintModule) {
        TBMPlayHintPresenter *playHintPresenter = [[TBMPlayHintPresenter alloc] init];
        [playHintPresenter setupEventFlowModule:self.eventsFlowModule];
        _playHintModule = playHintPresenter;
    }
    return _playHintModule;
}

- (id <TBMEventsFlowModuleEventHandler>)recordHintModule {
    if (!_recordHintModule) {
        TBMRecordHintPresenter *recordHintPresenter = [[TBMRecordHintPresenter alloc] init];
        [recordHintPresenter setupEventFlowModule:self.eventsFlowModule];
        _recordHintModule = recordHintPresenter;
    }
    return _recordHintModule;
}


- (id <TBMEventsFlowModuleEventHandler>)sentHintModule {
    if (!_sentHintModule) {
        TBMSentHintPresenter *sentHintPresenter = [[TBMSentHintPresenter alloc] init];
        [sentHintPresenter setupEventFlowModule:self.eventsFlowModule];
        _sentHintModule = sentHintPresenter;
    }
    return _sentHintModule;
}

- (id <TBMEventsFlowModuleEventHandler>)viewedHintModule {
    if (!_viewedHintModule) {
        TBMViewedHintPresenter *viewedHintPresenter = [[TBMViewedHintPresenter alloc] init];
        [viewedHintPresenter setupEventFlowModule:self.eventsFlowModule];
        _viewedHintModule = viewedHintPresenter;
    }
    return _viewedHintModule;
}

- (id <TBMEventsFlowModuleEventHandler>)welcomeHintModule {
    if (!_welcomeHintModule) {
        TBMWelcomeHintPresenter *welcomeHintPresenter = [[TBMWelcomeHintPresenter alloc] init];
        [welcomeHintPresenter setupEventFlowModule:self.eventsFlowModule];
        _welcomeHintModule = welcomeHintPresenter;
    }
    return _welcomeHintModule;
}


#pragma mark Hints modules


@end
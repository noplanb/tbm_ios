//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMHomeViewController+Invite.h"
#import "TBMEventsFlowModulePresenter.h"
#import "TBMEventsFlowDataSource.h"
#import "TBMEventsFlowModuleEventHandlerInterface.h"
#import "TBMFeatureUnlockModuleInterface.h"
#import "TBMInviteHintPresenter.h"
#import "TBMInviteSomeOneElseHintPresenter.h"
#import "TBMPlayHintPresenter.h"
#import "TBMRecordHintPresenter.h"
#import "TBMRecordWelcomeHintPresenter.h"
#import "TBMSentHintPresenter.h"
#import "TBMViewedHintPresenter.h"
#import "TBMWelcomeHintPresenter.h"
#import "TBMAbortRecordUsageHintPresenter.h"
#import "TBMFrontCameraUsageHintPresenter.h"
#import "TBMEarpieceUsageHintPresenter.h"
#import "TBMFeatureUnlockModulePresenter.h"
#import "TBMNextFeatureDialogPresenter.h"

@interface TBMEventsFlowModulePresenter ()

@property(nonatomic, strong) TBMEventsFlowDataSource *dataSource;

@property(nonatomic, strong) NSSet *eventHandlers;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> curentEventHandler;
@property(nonatomic) BOOL isRecordingFlag;

//Hints and Features

@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> inviteHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> inviteSomeOneElseHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> playHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> recordHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> recordWelcomeHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> sentHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> viewedHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> welcomeHintModule;

@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> abortRecordUsageHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> frontCameraUsageHintModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> earpieceUsageHintModule;

@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface, TBMFeatureUnlockModuleInterface> featureUnlockModule;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> nextFeatureModule;
@property(nonatomic, strong) id <TBMHomeModuleInterface> homeModule;

@end

@implementation TBMEventsFlowModulePresenter

#pragma mark - TBMEventsFlowModuleInterface

- (void)setupGridModule:(id <TBMGridModuleInterface>)gridModule
{
    self.gridModule = gridModule;
}

- (void)resetSession
{
    for (id <TBMEventsFlowModuleEventHandlerInterface> evenHandler in self.eventHandlers)
    {
        [evenHandler resetSessionState];
    }
}

- (void)resetHintsState
{
    [self.dataSource resetHintsState];
}

- (void)addEventHandler:(id <TBMEventsFlowModuleEventHandlerInterface>)eventHandler
{
    NSMutableSet *eventHandlers = [self.eventHandlers mutableCopy];
    [eventHandlers addObject:eventHandler];
    self.eventHandlers = eventHandlers;
}

- (void)throwEvent:(TBMEventFlowEvent)anEvent
{
    OB_INFO(@"[ EVENT throwEvent ] %ld ", (long) anEvent);

    if (anEvent == TBMEventFlowEventMessageDidStopPlaying)
    {
        [self.dataSource setMessageEverPlayedState:YES];
    }

    id <TBMEventsFlowModuleEventHandlerInterface> currentEvenHandler = nil;
    for (id <TBMEventsFlowModuleEventHandlerInterface> evenHandler in self.eventHandlers)
    {
        if ([evenHandler conditionForEvent:anEvent])
        {
            OB_INFO(@"[ EVENT HANDLER ] %@ — condition complain and priority is %lu", evenHandler.class, (unsigned long) evenHandler.priority);
            if ([currentEvenHandler priority] < [evenHandler priority])
            {
                currentEvenHandler = evenHandler;
                OB_INFO(@"[+ CURENT EVENT HANDLER ] %@ — priority is %lud", currentEvenHandler.class, (unsigned long) currentEvenHandler.priority);
            }
        }
        else
        {
            OB_INFO(@"[ EVENT HANDLER ] %@ — fails", evenHandler.class);
        }
    }

    if (currentEvenHandler)
    {
        [currentEvenHandler present];
        if ([currentEvenHandler isPresented])
        {
            self.curentEventHandler = currentEvenHandler;
        }
    }
}

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.isRecordingFlag = NO;
        [self registerToNotifications];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isRecording
{
    return self.isRecordingFlag;
}

- (BOOL)isAnyHandlerActive
{
    return [self.curentEventHandler isPresented];
}

#pragma mark - Handle NSNotifications

- (void)registerToNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDidStartRecording) name:TBMVideoRecorderShouldStartRecording object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDidRecorded) name:TBMVideoRecorderDidFinishRecording object:nil];
}

- (void)messageDidRecorded
{
    self.isRecordingFlag = NO;
    [self.dataSource setMessageRecordedState:YES];
}

- (void)messageDidStartRecording
{
    self.isRecordingFlag = YES;
}

- (id <TBMEventsFlowModuleEventHandlerInterface>)currentHandler
{
    return self.curentEventHandler;
}

- (void)setupCurrentHandler:(id <TBMEventsFlowModuleEventHandlerInterface>)eventHandler
{
    self.curentEventHandler = eventHandler;
}


- (void)setupHandlers
{
    //TODO: Remove HomeViewController from here after it will transform to module
//    [self.eventsFlowModule setupGridModule:gridModule]; TODO: Bring here from TBMHomeViewController
//    [homeController setupEvensFlowModule:self.eventsFlowModule];
//    self.homeModule = homeController;
    /**
     * Hints
     */
    [self addEventHandler:self.inviteHintModule];
    [self addEventHandler:self.inviteSomeOneElseHintModule];
    [self addEventHandler:self.playHintModule];
    [self addEventHandler:self.recordWelcomeHintModule];
    [self addEventHandler:self.recordHintModule];
    [self addEventHandler:self.sentHintModule];
    [self addEventHandler:self.viewedHintModule];
    [self addEventHandler:self.welcomeHintModule];

    [self addEventHandler:self.frontCameraUsageHintModule];
    [self addEventHandler:self.abortRecordUsageHintModule];
    [self addEventHandler:self.earpieceUsageHintModule];

    /**
     * Features
     */
    [self addEventHandler:self.featureUnlockModule];
    [self addEventHandler:self.nextFeatureModule];


}


#pragma mark - Lazy initialization

- (TBMEventsFlowDataSource *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [[TBMEventsFlowDataSource alloc] init];
    }
    return _dataSource;
}

- (NSSet *)eventHandlers
{
    if (!_eventHandlers)
    {
        _eventHandlers = [NSSet set];
    }
    return _eventHandlers;
}

#pragma mark Hints and Features
- (id <TBMEventsFlowModuleEventHandlerInterface>)inviteHintModule
{
    if (!_inviteHintModule)
    {
        TBMInviteHintPresenter *inviteHintModule = [TBMInviteHintPresenter new];
        inviteHintModule.eventFlowModule = self;
        inviteHintModule.gridModule = self.gridModule;
        inviteHintModule.dataSource = self.dataSource;
        _inviteHintModule = inviteHintModule;
    }
    return _inviteHintModule;
}

- (id <TBMEventsFlowModuleEventHandlerInterface>)inviteSomeOneElseHintModule
{
    if (!_inviteSomeOneElseHintModule)
    {
        TBMInviteSomeOneElseHintPresenter *inviteSomeOneElseHintModule = [TBMInviteSomeOneElseHintPresenter new];
        inviteSomeOneElseHintModule.eventFlowModule = self;
        inviteSomeOneElseHintModule.gridModule = self.gridModule;
        inviteSomeOneElseHintModule.dataSource = self.dataSource;
        _inviteSomeOneElseHintModule = inviteSomeOneElseHintModule;
    }
    return _inviteSomeOneElseHintModule;
}

- (id <TBMEventsFlowModuleEventHandlerInterface>)playHintModule
{
    if (!_playHintModule)
    {
        TBMPlayHintPresenter *playHintPresenter = [[TBMPlayHintPresenter alloc] init];
        playHintPresenter.eventFlowModule = self;
        playHintPresenter.gridModule = self.gridModule;
        playHintPresenter.dataSource = self.dataSource;
        _playHintModule = playHintPresenter;
    }
    return _playHintModule;
}

- (id <TBMEventsFlowModuleEventHandlerInterface>)recordHintModule
{
    if (!_recordHintModule)
    {
        TBMRecordHintPresenter *recordHintPresenter = [[TBMRecordHintPresenter alloc] init];
        recordHintPresenter.eventFlowModule = self;
        recordHintPresenter.gridModule = self.gridModule;
        recordHintPresenter.dataSource = self.dataSource;
        _recordHintModule = recordHintPresenter;
    }
    return _recordHintModule;
}

- (id <TBMEventsFlowModuleEventHandlerInterface>)recordWelcomeHintModule
{
    if (!_recordWelcomeHintModule)
    {
        TBMRecordWelcomeHintPresenter *recordWelcomeHintModule = [[TBMRecordWelcomeHintPresenter alloc] init];
        recordWelcomeHintModule.eventFlowModule = self;
        recordWelcomeHintModule.gridModule = self.gridModule;
        recordWelcomeHintModule.dataSource = self.dataSource;
        _recordWelcomeHintModule = recordWelcomeHintModule;
    }
    return _recordWelcomeHintModule;
}


- (id <TBMEventsFlowModuleEventHandlerInterface>)sentHintModule
{
    if (!_sentHintModule)
    {
        TBMSentHintPresenter *sentHintPresenter = [[TBMSentHintPresenter alloc] init];
        sentHintPresenter.eventFlowModule = self;
        sentHintPresenter.gridModule = self.gridModule;
        sentHintPresenter.dataSource = self.dataSource;
        _sentHintModule = sentHintPresenter;
    }
    return _sentHintModule;
}

- (id <TBMEventsFlowModuleEventHandlerInterface>)viewedHintModule
{
    if (!_viewedHintModule)
    {
        TBMViewedHintPresenter *viewedHintPresenter = [[TBMViewedHintPresenter alloc] init];
        viewedHintPresenter.eventFlowModule = self;
        viewedHintPresenter.gridModule = self.gridModule;
        viewedHintPresenter.dataSource = self.dataSource;
        _viewedHintModule = viewedHintPresenter;
    }
    return _viewedHintModule;
}

- (id <TBMEventsFlowModuleEventHandlerInterface>)welcomeHintModule
{
    if (!_welcomeHintModule)
    {
        TBMWelcomeHintPresenter *welcomeHintPresenter = [[TBMWelcomeHintPresenter alloc] init];
        welcomeHintPresenter.eventFlowModule = self;
        welcomeHintPresenter.gridModule = self.gridModule;
        welcomeHintPresenter.dataSource = self.dataSource;
        _welcomeHintModule = welcomeHintPresenter;
    }
    return _welcomeHintModule;
}

- (id <TBMEventsFlowModuleEventHandlerInterface>)abortRecordUsageHintModule
{
    if (!_abortRecordUsageHintModule)
    {
        TBMAbortRecordUsageHintPresenter *recordUsageHintPresenter = [TBMAbortRecordUsageHintPresenter new];
        recordUsageHintPresenter.eventFlowModule = self;
        recordUsageHintPresenter.gridModule = self.gridModule;
        recordUsageHintPresenter.dataSource = self.dataSource;
        _abortRecordUsageHintModule = recordUsageHintPresenter;
    }
    return _abortRecordUsageHintModule;
}

- (id <TBMEventsFlowModuleEventHandlerInterface>)frontCameraUsageHintModule
{
    if (!_featureUnlockModule)
    {
        TBMFrontCameraUsageHintPresenter *frontCameraUsageHintModule = [[TBMFrontCameraUsageHintPresenter alloc] init];
        frontCameraUsageHintModule.eventFlowModule = self;
        frontCameraUsageHintModule.gridModule = self.gridModule;
        frontCameraUsageHintModule.dataSource = self.dataSource;
        _frontCameraUsageHintModule = frontCameraUsageHintModule;
    }
    return _frontCameraUsageHintModule;
}


- (id <TBMEventsFlowModuleEventHandlerInterface>)earpieceUsageHintModule
{
    if (!_earpieceUsageHintModule)
    {
        TBMEarpieceUsageHintPresenter *earpieceUsageHintModule = [[TBMEarpieceUsageHintPresenter alloc] init];
        earpieceUsageHintModule.eventFlowModule = self;
        earpieceUsageHintModule.gridModule = self.gridModule;
        earpieceUsageHintModule.dataSource = self.dataSource;
        _earpieceUsageHintModule = earpieceUsageHintModule;
    }
    return _earpieceUsageHintModule;
}

- (id <TBMEventsFlowModuleEventHandlerInterface, TBMFeatureUnlockModuleInterface>)featureUnlockModule
{
    if (!_featureUnlockModule)
    {
        TBMFeatureUnlockModulePresenter *featureUnlockModule = [[TBMFeatureUnlockModulePresenter alloc] init];
        featureUnlockModule.eventFlowModule = self;
        featureUnlockModule.gridModule = self.gridModule;
        featureUnlockModule.dataSource = self.dataSource;

        _featureUnlockModule = featureUnlockModule;
    }
    return _featureUnlockModule;
}

- (id <TBMEventsFlowModuleEventHandlerInterface>)nextFeatureModule
{
    if (!_nextFeatureModule)
    {
        TBMNextFeatureDialogPresenter *nextFeatureDialogPresenter = [[TBMNextFeatureDialogPresenter alloc] init];

        //TODO: MAKS
        //[nextFeatureDialogPresenter setupHomeModule:self.homeModule];
        nextFeatureDialogPresenter.eventFlowModule = self;
        nextFeatureDialogPresenter.gridModule = self.gridModule;
        nextFeatureDialogPresenter.dataSource = self.dataSource;
        nextFeatureDialogPresenter.featureUnlockModule =self.featureUnlockModule;
        //[nextFeatureDialogPresenter setupInviteSomeOneElseHintModule:self.inviteSomeOneElseHintModule];
        _nextFeatureModule = nextFeatureDialogPresenter;
    }
    return _nextFeatureModule;
}

@end
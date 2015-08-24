//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMHomeViewController+Invite.h"
#import "TBMEventsFlowModulePresenter.h"
#import "TBMEventsFlowDataSource.h"
#import "TBMEventsFlowModuleEventHandler.h"

@interface TBMEventsFlowModulePresenter ()

@property(nonatomic, strong) TBMEventsFlowDataSource *dataSource;

@property(nonatomic, strong) NSSet *eventHandlers;
@property(nonatomic, strong) id <TBMEventsFlowModuleEventHandler> curentEventHandler;
@property(nonatomic) BOOL isRecordingFlag;
@end

@implementation TBMEventsFlowModulePresenter

#pragma mark - TBMEventsFlowModuleInterface

- (void)setupGridModule:(id <TBMGridModuleInterface>)gridModule
{
    self.gridModule = gridModule;
}

- (void)resetSession
{
    for (id <TBMEventsFlowModuleEventHandler> evenHandler in self.eventHandlers)
    {
        [evenHandler resetSessionState];
    }
}

- (void)resetHintsState
{
    [self.dataSource resetHintsState];
}

- (void)addEventHandler:(id <TBMEventsFlowModuleEventHandler>)eventHandler
{
    NSMutableSet *eventHandlers = [self.eventHandlers mutableCopy];
    [eventHandlers addObject:eventHandler];
    self.eventHandlers = eventHandlers;
}

- (void)throwEvent:(TBMEventFlowEvent)anEvent
{
    id <TBMEventsFlowModuleEventHandler> currentEvenHandler = nil;
    for (id <TBMEventsFlowModuleEventHandler> evenHandler in self.eventHandlers)
    {
        NSLog(@"enumerate %@ -", [evenHandler class]);
        if ([evenHandler conditionForEvent:anEvent dataSource:self.dataSource])
        {
            NSLog(@"++ Condition for  %@ ++", [evenHandler class]);
            NSLog(@"priority %lu | %@ priority = %lu  -", (unsigned long) [evenHandler priority], [currentEvenHandler class], (unsigned long) [currentEvenHandler priority]);
            if ([currentEvenHandler priority] < [evenHandler priority])
            {
                NSLog(@">> Select:  %@ ++", [evenHandler class]);
                currentEvenHandler = evenHandler;
            }
        }
    }

    if (currentEvenHandler)
    {
        [currentEvenHandler presentWithGridModule:self.gridModule];
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
}

- (void)messageDidStartRecording
{
    self.isRecordingFlag = YES;
}

- (id <TBMEventsFlowModuleEventHandler>)currentHandler
{
    return self.curentEventHandler;
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

@end
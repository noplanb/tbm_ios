//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

@protocol TBMGridModuleInterface;
@protocol TBMEventsFlowModuleInterface;
@class TBMHomeViewController;
@protocol TBMEventsFlowModuleEventHandler;
@protocol TBMEventsFlowModuleEventHandler;

@interface TBMTutorialSystem : NSObject

@property(nonatomic, strong) id <TBMEventsFlowModuleInterface> eventsFlowModule;

- (void)setupHandlersWithGridModule:(TBMHomeViewController *)homeController;

@end
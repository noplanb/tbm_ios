//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

@protocol TBMGridModuleInterface;
@protocol TBMEventsFlowModuleInterface;
@class TBMHomeViewController;
@protocol TBMEventsFlowModuleEventHandler;
@protocol TBMEventsFlowModuleEventHandler;

@interface TBMDependencies : NSObject

//TODO:Make private after refactoring Home
@property(nonatomic, strong) id <TBMEventsFlowModuleInterface> eventsFlowModule;

- (void)setupDependenciesWithHomeViewController:(TBMHomeViewController *)homeController;

@end
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBMGridModuleInterface;
@protocol TBMEventsFlowModuleInterface;
@class TBMHomeViewController;


@interface TBMDependencies : NSObject
//TODO:Make private after refactoring Home
@property(nonatomic, strong) id <TBMEventsFlowModuleInterface> eventsFlowModule;

/**
 * Setup dependencies of application
 */
- (void)setupDependenciesWithHomeViewController:(TBMHomeViewController *)homeController;



@end
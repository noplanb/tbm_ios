//
// Created by Maksim Bazarov on 20/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMEventsFlowModuleEventHandler.h"
#import "TBMEventHandlerPresenter.h"

@protocol TBMHomeModuleInterface;


@interface TBMNextFeatureDialogPresenter : TBMEventHandlerPresenter <TBMEventsFlowModuleEventHandler>

/**
 * Home module needs for present bench
 */
- (void)setupHomeModule:(id <TBMHomeModuleInterface>)homeModule;

/**
 * View callback
 */
- (void)dialogDidTap;

@end
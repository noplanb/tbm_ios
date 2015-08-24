/**
 *
 * Base class for hints presenters
 *
 * Created by Maksim Bazarov on 16/08/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */



#import <Foundation/Foundation.h>
#import "TBMEventsFlowModuleEventHandler.h"

@class TBMHintView;


@interface TBMHintPresenter : NSObject

@property(nonatomic, strong) TBMHintView *hintView;

@property(nonatomic, weak) id <TBMEventsFlowModuleInterface> eventFlowModule;

- (void)setupEventFlowModule:(id <TBMEventsFlowModuleInterface>)eventFlowModule;

- (void)hintDidDismiss;
@end
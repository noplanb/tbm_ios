/**
 *
 * Base class for features presenters
 *
 * Created by Maksim Bazarov on 12/08/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */



#import <Foundation/Foundation.h>
#import "TBMEventsFlowModuleEventHandler.h"

@class TBMFeatureView;


@interface TBMFeaturePresenter : NSObject

@property(nonatomic, strong) TBMFeatureView *featureView;

@property(nonatomic, weak) id <TBMEventsFlowModuleInterface> eventFlowModule;

- (void)setupEventFlowModule:(id <TBMEventsFlowModuleInterface>)eventFlowModule;

- (void)featureDidDismiss;

- (void)showMeButtonDidPress;

- (void)hintDidDismiss;
@end
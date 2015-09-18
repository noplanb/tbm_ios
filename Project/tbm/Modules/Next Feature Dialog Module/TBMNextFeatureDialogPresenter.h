//
// Created by Maksim Bazarov on 20/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventsFlowModuleEventHandlerInterface.h"
#import "TBMEventHandlerPresenter.h"

@protocol TBMHomeModuleInterface;
@protocol TBMFeatureUnlockModuleInterface;

@interface TBMNextFeatureDialogPresenter : TBMEventHandlerPresenter <TBMEventsFlowModuleEventHandlerInterface, TBMDialogViewDelegate>

@property (nonatomic, strong) id <TBMFeatureUnlockModuleInterface> featureUnlockModule;
@property (nonatomic, strong) id <TBMEventsFlowModuleEventHandlerInterface> inviteSomeOneElseHintModule;

- (void)dialogDidTap;

@end
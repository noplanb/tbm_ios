//
// Created by Maksim Bazarov on 20/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMEventsFlowModuleEventHandler.h"

@protocol TBMHomeModuleInterface;


@interface TBMNextFeatureDialogPresenter : NSObject <TBMEventsFlowModuleEventHandler>
- (void)setupHomeModule:(id <TBMHomeModuleInterface>)gridModule;

- (void)dialogDidTap;
@end
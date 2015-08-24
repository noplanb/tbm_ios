//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventsFlowModuleInterface.h"

@protocol TBMGridModuleInterface;

@interface TBMEventsFlowModulePresenter : NSObject <TBMEventsFlowModuleInterface>

@property(nonatomic, weak) id <TBMGridModuleInterface> gridModule;

@end
//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMEventsFlowModuleInterface.h"

@class TBMHintView;
@protocol TBMGridModuleInterface;

@interface TBMEventsFlowModulePresenter : NSObject <TBMEventsFlowModuleInterface>

@property(nonatomic, weak) id <TBMGridModuleInterface> gridModule;

@end
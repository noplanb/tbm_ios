//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMHintPresenter.h"
#import "TBMHintView.h"


@implementation TBMHintPresenter {

}

- (void)setupEventFlowModule:(id <TBMEventsFlowModuleInterface>)eventFlowModule {
    self.eventFlowModule = eventFlowModule;
}

- (void)hintDidDismiss {
    //virtual
}

@end
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMFeaturePresenter.h"


@implementation TBMFeaturePresenter {

}

- (void)setupEventFlowModule:(id <TBMEventsFlowModuleInterface>)eventFlowModule {
    self.eventFlowModule = eventFlowModule;
}

- (void)featureDidDismiss {
    //virtual
}

- (void)showMeButtonDidPress {
    //virtual
}
@end
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMDeleteFriendFeaturePresenter.h"
#import "TBMDeleteFriendFeatureView.h"


@implementation TBMDeleteFriendFeaturePresenter {
    BOOL _isPresented;
}

- (instancetype)init {
    self = [super init];
    [self setFeatureView:[TBMDeleteFriendFeatureView new]];
    self.featureView.presenter = self;
    return self;
}

- (BOOL)isPresented {
    return _isPresented;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSource>)dataSource {
    if (event != TBMEventFlowEventApplicationDidLaunch) {
        return NO;
    }

    return YES;
}

- (void)presentWithDataSource:(id <TBMEventsFlowModuleDataSource>)dataSource gridModule:(id <TBMGridModuleInterface>)gridModule {

    _isPresented = YES;
    [self.featureView showHintInGrid:gridModule];

}

- (NSUInteger)priority {
    return 99;
}

- (void)featureDidDismiss {
    NSLog(@"featureDidDismiss");
}

- (void)showMeButtonDidPress {
    NSLog(@"showMeButtonDidPress");
}
@end
//
// Created by Maksim Bazarov on 20/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMNextFeatureDialogPresenter.h"
#import "TBMNextFeatureDialogView.h"
#import "TBMHomeModuleInterface.h"
#import "TBMEventHandlerDataSource.h"


@interface TBMNextFeatureDialogPresenter ()
@property(nonatomic, strong) id <TBMHomeModuleInterface> homeModule;
@end


@implementation TBMNextFeatureDialogPresenter

- (instancetype)init {
    self = [super init];
    TBMNextFeatureDialogView *view = [[TBMNextFeatureDialogView alloc] initWithFrame:CGRectZero];
    view.presenter = self;
    self.dialogView = view;
    self.dataSource.persistentStateKey = @""; // it means don't store
    return self;
}

- (void)setupHomeModule:(id <TBMHomeModuleInterface>)homeModule {
    self.homeModule = homeModule;
}

- (void)presentWithGridModule:(id <TBMGridModuleInterface>)gridModule {
    [super presentWithGridModule:gridModule];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismiss];
    });
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource {
    if (event != TBMEventFlowEventApplicationDidLaunch) {
        return NO;
    }

    return YES;
}

- (NSUInteger)priority {
    return 1;
}

- (void)dismiss {
    [self.dialogView dismiss];
}

- (void)dialogDidTap {
    [self.homeModule showBench];
}
@end
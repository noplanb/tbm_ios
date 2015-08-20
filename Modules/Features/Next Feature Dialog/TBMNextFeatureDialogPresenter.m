//
// Created by Maksim Bazarov on 20/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMNextFeatureDialogPresenter.h"
#import "TBMNextFeatureDialogView.h"
#import "TBMHomeModuleInterface.h"


@interface TBMNextFeatureDialogPresenter ()
@property(nonatomic, strong) TBMNextFeatureDialogView *dialogView;
@property(nonatomic, strong) id <TBMHomeModuleInterface> homeModule;
@end


@implementation TBMNextFeatureDialogPresenter {
    BOOL _isPresented;
}
- (instancetype)init {
    self = [super init];
    self.dialogView = [[TBMNextFeatureDialogView alloc] initWithFrame:CGRectZero];
    self.dialogView.presenter = self;
    return self;
}

- (BOOL)isPresented {
    return _isPresented;
}

- (void)setupHomeModule:(id <TBMHomeModuleInterface>)homeModule {
    self.homeModule = homeModule;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSource>)dataSource {
    if (event != TBMEventFlowEventApplicationDidLaunch) {
        return NO;
    }

    return YES;
}

- (NSUInteger)priority {
    return 999;
}

- (void)presentWithDataSource:(id <TBMEventsFlowModuleDataSource>)dataSource gridModule:(id <TBMGridModuleInterface>)gridModule {
    _isPresented = YES;
    [self.dialogView showHintInGrid:gridModule];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismiss];
    });
}

- (void)dismiss {
    [self.dialogView dismiss];
}

- (void)dialogDidTap {
    [self.homeModule showBench];
}
@end
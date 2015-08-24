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

- (instancetype)init
{
    self = [super init]; //todo:

    if (self)
    {
        TBMNextFeatureDialogView *view = [TBMNextFeatureDialogView new];
        view.presenter = self;
        self.dialogView = view;
        self.dataSource.persistentStateKey = @""; // it means don't store
    }
    return self;
}

- (void)setupHomeModule:(id <TBMHomeModuleInterface>)homeModule
{
    self.homeModule = homeModule;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
    if (event != TBMEventFlowEventApplicationDidLaunch)
    {
        return NO;
    }

    return YES;
}

- (NSUInteger)priority
{
    return 109;
}

#pragma mark - View Callbacks

- (void)dismiss
{
    [self.dialogView dismiss];
}

- (void)dialogDidTap
{
    [self.homeModule showBench];
}
@end
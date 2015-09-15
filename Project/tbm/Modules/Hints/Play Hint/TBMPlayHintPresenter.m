//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMPlayHintPresenter.h"
#import "TBMHintView.h"
#import "TBMPlayHintView.h"
#import "TBMRecordHintPresenter.h"

@implementation TBMPlayHintPresenter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.dialogView = [TBMPlayHintView new];
    }
    return self;
}

- (NSUInteger)priority
{
    return 1100;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event
{
    
    if (event != TBMEventFlowEventMessageDidReceive
            && event != TBMEventFlowEventMessageDidRecorded
            && event != TBMEventFlowEventApplicationDidLaunch)
    {
        return NO;
    }

    if (self.eventFlowModule.isRecording)
    {
        return NO;
    }

    if ([self sessionState])
    {
        return NO;
    }

    TBMEventsFlowDataSource *dataSource = self.dataSource;
    if ([dataSource unviewedCount] <= 0)
    {
        return NO;
    }

    return ((![dataSource messageEverPlayedState]) && ([dataSource friendsCount] == 1));

}

- (void)presentWithGridModule:(id <TBMGridModuleInterface>)gridModule
{
    if (![self.eventFlowModule isAnyHandlerActive])
    {
        [super present];
        [self setupPlayTip];
        [self didPresented];
    }
    else if ([[self.eventFlowModule currentHandler] respondsToSelector:@selector(addPlayHint)])
    {
        [[self.eventFlowModule currentHandler] performSelector:@selector(addPlayHint)];
        [self didPresented];
    }
}

#pragma mark Add record hint implementation

- (void)addRecordHint
{
    [(TBMPlayHintView *)self.dialogView addRecordTip];
}

- (void)setupPlayTip
{
    [(TBMPlayHintView *)self.dialogView setupPlayTip];
}

@end
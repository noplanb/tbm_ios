//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventsFlowDataSource.h"
#import "TBMFriend.h"
#import "TBMGridElement.h"
#import "TBMEventsFlowModuleEventHandlerInterface.h"
#import "ZZStoredSettingsManager.h"
#import "TBMInviteHintPresenter.h"

@interface TBMEventsFlowDataSource ()

@property(nonatomic, strong) NSDictionary* handlersKeys;

@end

@implementation TBMEventsFlowDataSource

- (BOOL)messageRecordedState
{
    return [[ZZStoredSettingsManager shared] messageEverRecorded];
}

- (void)setMessageRecordedState:(BOOL)state
{
    [[ZZStoredSettingsManager shared] setMessageEverRecorded:state];
}

- (BOOL)messageEverPlayedState
{
    return [[ZZStoredSettingsManager shared] messageEverPlayed];
}

- (void)setMessageEverPlayedState:(BOOL)state
{
    [[ZZStoredSettingsManager shared] setMessageEverPlayed:state];
}


//Other useful data
- (NSUInteger)friendsCount
{
    return [TBMFriend count];
}

- (NSUInteger)unviewedCount
{
    return [TBMFriend allUnviewedCount];
}

- (NSUInteger)unviewedCountForCenterRightBox
{
    return [TBMFriend unviewedCountForGridCellAtIndex:0];
}

- (BOOL)hasSentVideos:(NSUInteger)gridIndex
{
    return [TBMGridElement hasSentVideos:gridIndex];
}

@end
//
// Created by Maksim Bazarov on 16/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMFeatureUnlockModulePresenter.h"
#import "TBMEventHandlerDataSource.h"
#import "TBMFeatureUnlockDialogView.h"
#import "TBMFeatureUnlockDataSource.h"
#import "NSString+NSStringExtensions.h"

@interface TBMFeatureUnlockModulePresenter ()
@property(nonatomic, strong) TBMFeatureUnlockDataSource *featuresUnlockDatasource;

@end

@implementation TBMFeatureUnlockModulePresenter
- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.dialogView = [TBMFeatureUnlockDialogView new];
        self.eventHandlerDataSource.persistentStateKey = @"";
        self.featuresUnlockDatasource = [TBMFeatureUnlockDataSource new];
    }
    return self;
}

#pragma mark - TBMEventsFlowModuleEventHandler

- (NSUInteger)priority
{
    return 1600;
}

- (BOOL)conditionForEvent:(TBMEventFlowEvent)event dataSource:(id <TBMEventsFlowModuleDataSourceInterface>)dataSource
{
    if (event != TBMEventFlowEventMessageDidSend)
    {
        return NO;
    }

    return [self shouldNewFeatureBeUnlocked];
}

#pragma mark - TBMFeatureUnlockModuleInterface

- (BOOL)hasFeaturesForUnlock
{
    return [self.featuresUnlockDatasource lockedFeaturesCount] > 0;
}


#pragma mark - Business logic

- (BOOL)shouldNewFeatureBeUnlocked
{
    [self silentUpdateUnlockedFeaturesCount];
    NSInteger everSentCount = [self.featuresUnlockDatasource everSentCount];
    BOOL isInvitedUser = [self.featuresUnlockDatasource isInvitedUser];
    TBMUnlockedFeature nextFeatureForUnlock;
    nextFeatureForUnlock = isInvitedUser ? (TBMUnlockedFeature) everSentCount : (TBMUnlockedFeature) everSentCount - 1;

    if (nextFeatureForUnlock > TBMUnlockedFeatureNone && self.featuresUnlockDatasource.lastUnlockedFeature < nextFeatureForUnlock)
    {
        [self featureDidUnlock:nextFeatureForUnlock];
        return YES;
    }

    return NO;
}

/**
 * Sets up feature description
 */
- (void)featureDidUnlock:(TBMUnlockedFeature)feature
{
    [self.featuresUnlockDatasource setLastUnlockedFeature:feature];
    NSString *featureHeader = [self.featuresUnlockDatasource featureHeader:feature];
    if (![featureHeader isEmpty])
    {
        [(TBMFeatureUnlockDialogView *) self.dialogView setFeatureDescription:featureHeader];
    }

}

#pragma mark - View Callbacks

- (void)showMeButtonDidSelect
{
    [self dialogDidDismiss];
}

- (void)dialogDidDismiss
{
    [super dialogDidDismiss];
    [self throwLastHintDidDismiss];
}

- (void)throwLastHintDidDismiss
{
    TBMUnlockedFeature lastFeature = [self.featuresUnlockDatasource lastUnlockedFeature];
    id <TBMEventsFlowModuleInterface> eventFlowModule = self.eventFlowModule;

    switch (lastFeature)
    {
        case TBMUnlockedFeatureFrontCamera:
        {
            [eventFlowModule throwEvent:TBMEventFlowEventFrontCameraUnlockDialogDidDismiss];
        }

        case TBMUnlockedFeatureAbortRecord:
        {
            [eventFlowModule throwEvent:TBMEventFlowEventAbortRecordingUnlockDialogDidDismiss];
        }

        case TBMUnlockedFeatureEarpiece:
        {
            [eventFlowModule throwEvent:TBMEventFlowEventEarpieceUnlockDialogDidDismiss];
        }

        case TBMUnlockedFeatureDeleteAFriend:
        {
            [eventFlowModule throwEvent:TBMEventFlowEventDeleteFriendUnlockDialogDidDismiss];
        }

        case TBMUnlockedFeatureSpin:
        {
            [eventFlowModule throwEvent:TBMEventFlowEventSpinUnlockDialogDidDismiss];
        }

        default:
            break;
    }
}

- (void)silentUpdateUnlockedFeaturesCount
{
    TBMFeatureUnlockDataSource *dataSource = self.featuresUnlockDatasource;
    if (![dataSource isFeaturesUnlockedCountSet])
    {

        [dataSource silentUpdateUnlockedFeaturesCount:[self nextFeatureForUnlock]];
    }
}

@end
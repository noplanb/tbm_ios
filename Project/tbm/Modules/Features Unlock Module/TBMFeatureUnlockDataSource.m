//
// Created by Maksim Bazarov on 24/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMFeatureUnlockDataSource.h"
#import "TBMFriend.h"
#import "ZZUserDataProvider.h"
#import "ZZStoredSettingsManager.h"

@interface TBMFeatureUnlockDataSource ()

@property(nonatomic, strong, readonly) NSDictionary* featuresHeaders;

@end

@implementation TBMFeatureUnlockDataSource

- (NSString*)featureHeader:(TBMUnlockedFeature)feature
{
    return self.featuresHeaders[@(feature)];
}

- (TBMUnlockedFeature)lastUnlockedFeature
{
    return (TBMUnlockedFeature) [[ZZStoredSettingsManager shared] lastUnlockedFeature];
}

- (void)setLastUnlockedFeature:(TBMUnlockedFeature)feature
{
    [[ZZStoredSettingsManager shared] setLastUnlockedFeature:(NSUInteger) feature];
}

- (NSDictionary*)featuresHeaders
{
    return @{@(TBMUnlockedFeatureNone) : @"No feature.",
             @(TBMUnlockedFeatureFrontCamera) : @"Use both cameras!",
             @(TBMUnlockedFeatureAbortRecord) : @"Abort a recording!",
             @(TBMUnlockedFeatureEarpiece) : @"Listen from earpiece!",
             @(TBMUnlockedFeatureSpin) : @"Spin your friends!"};
}

- (NSInteger)everSentCount
{
    return [TBMFriend everSentNonInviteeFriendsCount];
}

- (BOOL)isInvitedUser
{
    ZZUserDomainModel* me = [ZZUserDataProvider authenticatedUser];
    return me.isInvitee;
}

- (NSInteger)lockedFeaturesCount
{
    return TBMUnlockedFeatureTotalCount;
}

- (BOOL)isFeaturesUnlockedCountSet
{
    return ([self lastUnlockedFeature] > 0);
}

- (void)silentUpdateUnlockedFeaturesCount:(TBMUnlockedFeature)feature
{
    [self setLastUnlockedFeature:feature];
}

@end
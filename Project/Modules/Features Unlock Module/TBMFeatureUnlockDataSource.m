//
// Created by Maksim Bazarov on 24/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMFeatureUnlockDataSource.h"
#import "TBMFriend.h"
#import "NSNumber+TBMUserDefaults.h"

static NSString *const kLastUnlockedFeatureNSUDKey = @"kLastUnlockedFeatureNSUDKey";

@interface TBMFeatureUnlockDataSource ()

@property(nonatomic, strong, readonly) NSDictionary *featuresHeaders;

@end

@implementation TBMFeatureUnlockDataSource

- (TBMUnlockedFeature)featureToUnlockWithEverSentCount:(NSInteger)count
{
    return TBMUnlockedFeatureNone;
}

- (NSString *)featureHeader:(TBMUnlockedFeature)feature
{
    return self.featuresHeaders[@(feature)];
}

- (TBMUnlockedFeature)lastUnlockedFeature
{
    return (TBMUnlockedFeature) [[NSNumber loadUserDefaultsObjectForKey:kLastUnlockedFeatureNSUDKey] integerValue];
}

- (void)setLastUnlockedFeature:(TBMUnlockedFeature)feature
{
    [@(feature) saveUserDefaultsObjectForKey:kLastUnlockedFeatureNSUDKey];
}

- (NSDictionary *)featuresHeaders
{
    return
            @{
                    @(TBMUnlockedFeatureNone) : @"No feature.",
                    @(TBMUnlockedFeatureFrontCamera) : @"Use both cameras!",
                    @(TBMUnlockedFeatureAbortRecord) : @"Abort a recording!",
                    @(TBMUnlockedFeatureEarpiece) : @"Listen from earpiece!",
                    @(TBMUnlockedFeatureSpin) : @"Spin your friends!",
            };;
}

- (NSInteger)everSentCount
{
    return [TBMFriend everSentNonInviteeFriendsCount];
}

- (BOOL)isInvitedUser
{
    return NO;
}

- (NSInteger)lockedFeaturesCount
{
    return TBMUnlockedFeatureTotalCount;
}
@end
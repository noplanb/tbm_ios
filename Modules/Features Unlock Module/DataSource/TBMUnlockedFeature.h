//
// Created by Maksim Bazarov on 24/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

/**
 * Enum of possible events for throwEvent:
 *
 * if will change: needs to update lockedFeaturesCount in data source
 */
typedef NS_ENUM(NSInteger, TBMUnlockedFeature)
{
    TBMUnlockedFeatureNone,
    TBMUnlockedFeatureFrontCamera,
    TBMUnlockedFeatureAbortRecord,
    TBMUnlockedFeatureEarpiece,
    TBMUnlockedFeatureDeleteAFriend,
    TBMUnlockedFeatureSpin,
};

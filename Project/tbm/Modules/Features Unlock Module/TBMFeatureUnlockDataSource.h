//
// Created by Maksim Bazarov on 24/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//


#import "TBMUnlockedFeature.h"

@interface TBMFeatureUnlockDataSource : NSObject

/**
 * Returns header for feature
 */
- (NSString *)featureHeader:(TBMUnlockedFeature)feature;

/**
 * Last unlocked feature property
 */
- (void)setLastUnlockedFeature:(TBMUnlockedFeature)feature;
- (TBMUnlockedFeature)lastUnlockedFeature;
- (NSInteger)everSentCount;
- (BOOL)isInvitedUser;
- (NSInteger)lockedFeaturesCount;
@end
//
// Created by Maksim Bazarov on 24/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

@protocol TBMFeatureUnlockModuleInterface <NSObject>

/**
 * Returns YES if there are any locked features
 */
- (BOOL)hasFeaturesForUnlock;
- (void)silentUpdateUnlockedFeaturesCount;

@end
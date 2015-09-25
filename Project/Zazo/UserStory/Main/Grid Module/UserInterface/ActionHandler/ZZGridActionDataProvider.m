//
//  ZZGridActionDataProvider.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionDataProvider.h"
#import "ZZGridDataProvider.h"
#import "ZZGridDomainModel.h"
#import "NSObject+ANUserDefaults.h"
#import "ZZStoredSettingsManager.h"
#import "TBMGridElement.h"
#import "ZZGridActionHandlerEnums.h"

@implementation ZZGridActionDataProvider

+ (NSInteger)numberOfUsersOnGrid
{
    NSArray *gridModels = [ZZGridDataProvider loadAllGridsSortByIndex:YES];
    
    __block NSInteger counter = 0;
    [gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!ANIsEmpty(model.relatedUser))
        {
            counter++;
        }
    }];
    return counter;
}


//
////Other useful data
//- (NSUInteger)friendsCount
//{
//
//}
//
//- (NSUInteger)unviewedCount
//{
//    return [TBMFriend allUnviewedCount];
//}
//
//- (NSUInteger)unviewedCountForCenterRightBox
//{
//    return [TBMFriend unviewedCountForGridCellAtIndex:0];
//}
//
//- (BOOL)hasSentVideos:(NSUInteger)gridIndex
//{
//
//}


+ (NSUInteger)friendsCount
{
    return [TBMFriend count];
}

+ (BOOL)messageRecordedState
{
    return [[ZZStoredSettingsManager shared] messageEverRecorded];
}

+ (void)setMessageRecordedState:(BOOL)state
{
    [[ZZStoredSettingsManager shared] setMessageEverRecorded:state];
}

+ (BOOL)messageEverPlayedState
{
    return [[ZZStoredSettingsManager shared] messageEverPlayed];
}

+ (void)setMessageEverPlayedState:(BOOL)state
{
    [[ZZStoredSettingsManager shared] setMessageEverPlayed:state];
}

+ (BOOL)hasSentVideos:(NSUInteger)gridIndex
{
    return [TBMGridElement hasSentVideos:gridIndex];
}

+ (BOOL)hintStateForHintType:(ZZHintsType)type
{
    // TODO: make an converter type to human format
    return [NSObject an_boolForKey:[@(type) stringValue]];
}

+ (void)saveHintState:(BOOL)state forHintType:(ZZHintsType)type
{
    // TODO: make an converter type to human format
    [NSObject an_updateBool:state forKey:[@(type) stringValue]];
}

+ (BOOL)hasFeaturesForUnlock
{
    return (ZZGridActionFeatureTypeTotal -1) < [self lastUnlockedFeature];
}

+ (NSUInteger)lastUnlockedFeature
{
    return [ZZStoredSettingsManager shared].lastUnlockedFeature;
}

/*
 * Return YES if feature was unlocked
 */
+ (BOOL)unlockNextFeature
{
    ZZStoredSettingsManager* manager = [ZZStoredSettingsManager shared];
    NSUInteger lastUnlockedFeature = manager.lastUnlockedFeature;
    NSUInteger nextFeature = lastUnlockedFeature + 1;

    if (nextFeature < ZZGridActionFeatureTypeTotal) {
        manager.lastUnlockedFeature = nextFeature;
        return YES;
    }

    return NO;
}
@end

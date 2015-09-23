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



//- (BOOL)messageRecordedState
//{
//    return [[ZZStoredSettingsManager shared] messageEverRecorded];
//}
//
//- (void)setMessageRecordedState:(BOOL)state
//{
//    [[ZZStoredSettingsManager shared] setMessageEverRecorded:state];
//}
//
//- (BOOL)messageEverPlayedState
//{
//    return [[ZZStoredSettingsManager shared] messageEverPlayed];
//}
//
//- (void)setMessageEverPlayedState:(BOOL)state
//{
//    [[ZZStoredSettingsManager shared] setMessageEverPlayed:state];
//}
//
//
////Other useful data
//- (NSUInteger)friendsCount
//{
//    return [TBMFriend count];
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
//    return [TBMGridElement hasSentVideos:gridIndex];
//}


@end

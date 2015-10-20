//
//  ZZDebugStateInteractor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZDebugStateInteractor.h"
#import "ZZApplicationStateInfoGenerator.h"
#import "ZZFriendDataProvider.h"

@implementation ZZDebugStateInteractor

- (void)loadData
{
    NSArray* friends = [ZZFriendDataProvider loadAllFriends];
    
    NSArray* stateModels = [ZZApplicationStateInfoGenerator loadVideoDataWithFriendsModels:friends];
    NSArray* incomeDandling = [ZZApplicationStateInfoGenerator loadIncomingDandlingItemsFromData:stateModels];
    NSArray* outcomeDandling = [ZZApplicationStateInfoGenerator loadOutgoingDandlingItemsFromData:stateModels];
    
    [self.output dataLoadedWithAllVideos:stateModels incomeDandling:incomeDandling outcomeDandling:outcomeDandling];
}

@end

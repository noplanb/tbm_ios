//
//  ZZEditFriendListInteractor.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEditFriendListInteractor.h"
#import "ZZFriendDomainModel.h"
#import "ZZAddressBookDataProvider.h"
#import "ZZFriendsTransportService.h"
#import "FEMObjectDeserializer.h"
#import "ZZFriendDataProvider.h"
#import "ZZUserDataProvider.h"
#import "ZZFriendDataUpdater.h"
#import "ZZUserFriendshipStatusHandler.h"
#import "ZZGridDataProvider.h"
#import "ZZGridDomainModel.h"


@interface ZZEditFriendListInteractor ()

@end

@implementation ZZEditFriendListInteractor

- (void)loadData
{
    NSArray* friends = [ZZFriendDataProvider loadAllFriends];
    
    
    NSArray* gridModels = [ZZGridDataProvider loadAllGridsSortByIndex:NO];
    
    [gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel*  _Nonnull gridModel, NSUInteger idx, BOOL * _Nonnull stop) {
       [friends enumerateObjectsUsingBlock:^(ZZFriendDomainModel*  _Nonnull friendModel, NSUInteger idx, BOOL * _Nonnull stop) {
           if ([friendModel.mKey isEqualToString:gridModel.relatedUser.mKey])
           {
               friendModel.friendshipStatusValue = ZZFriendshipStatusTypeEstablished;
           }
       }];
    }];
    
//    [friends enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friendObject, NSUInteger idx, BOOL * _Nonnull stop) {
//        
//        friendObject.isFriendshipCreator = ![[ZZUserDataProvider authenticatedUser].mkey isEqualToString:friendObject.friendshipCreatorMkey];
//    }];
    
    [self.output dataLoaded:[self sortArrayByFirstName:friends]];
}

- (void)changeContactStatusTypeForFriend:(ZZFriendDomainModel *)friendModel
{
    friendModel.friendshipStatusValue = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friendModel];
    BOOL shouldBeVisible = [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel];
    
    [[ZZFriendsTransportService changeModelContactStatusForUser:friendModel.mKey
                                                      toVisible:shouldBeVisible] subscribeNext:^(NSDictionary* response) {
        
        [ZZFriendDataUpdater updateConnectionStatusForUserWithID:friendModel.idTbm
                                                         toValue:friendModel.friendshipStatusValue];
        
        [self.output contactSuccessfullyUpdated:friendModel toVisibleState:shouldBeVisible];
        
    } error:^(NSError *error) {
        //TODO: revert status?
    }];
}

- (NSArray *)sortArrayByFirstName:(NSArray *)array
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:ZZUserDomainModelAttributes.firstName
                                                           ascending:YES];
    NSArray* sortedArray = [array sortedArrayUsingDescriptors:@[sort]];
    
    return sortedArray;
}


@end

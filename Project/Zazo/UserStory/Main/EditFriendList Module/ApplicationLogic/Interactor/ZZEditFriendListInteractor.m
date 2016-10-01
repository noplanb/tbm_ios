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
#import "ZZRootStateObserver.h"

@interface ZZEditFriendListInteractor ()

@end

@implementation ZZEditFriendListInteractor

- (void)loadData
{
    NSArray *friends = [ZZFriendDataProvider allFriendsModels];


    NSArray *gridModels = [ZZGridDataProvider loadAllGridsSortByIndex:NO];

    [gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel *_Nonnull gridModel, NSUInteger idx, BOOL *_Nonnull stop) {
        [friends enumerateObjectsUsingBlock:^(ZZFriendDomainModel *_Nonnull friendModel, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([friendModel.mKey isEqualToString:gridModel.relatedUser.mKey])
            {
                NSLog(@"fiend with name:%@ updated to status establishment", friendModel.fullName);
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
    ZZLogEvent(@"EditFriend -- changeContactStatusTypeForFriend: %@ %@", friendModel.fullName, friendModel.mKey);
    friendModel.friendshipStatusValue = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friendModel];
    BOOL shouldBeVisible = [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel];
    [[ZZFriendsTransportService changeModelContactStatusForUser:friendModel.mKey
                                                      toVisible:shouldBeVisible] subscribeNext:^(NSDictionary *response) {
        ANDispatchBlockToMainQueue(^{
            [ZZFriendDataUpdater updateFriendWithID:friendModel.idTbm setConnectionStatus:friendModel.friendshipStatusValue];
            [[ZZRootStateObserver sharedInstance] notifyWithEvent:ZZRootStateObserverEventFriendInContactChangeStauts notificationObject:nil];
            [self.output contactSuccessfullyUpdated:friendModel toVisibleState:shouldBeVisible];
        });
    }                                                                                    error:^(NSError *error) {

        friendModel.friendshipStatusValue = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friendModel];
        [self.output updatedWithError:error friend:friendModel];
    }];
}

- (NSArray *)sortArrayByFirstName:(NSArray *)array
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:ZZUserDomainModelAttributes.firstName
                                                           ascending:YES];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:@[sort]];

    return sortedArray;
}

//- (void)_updateContactDrawerIdNeededWithFriend:(ZZFriendDomainModel*)friendModel
//{
//    NSMutableSet* allFriends = [NSMutableSet setWithArray:[ZZFriendDataProvider allFriendsModels]?:@[]];
//    NSMutableSet* friendsOnGrid = [NSMutableSet setWithArray:[ZZFriendDataProvider friendsOnGrid]?:@[]];
//    [allFriendsModels minusSet:friendsOnGrid];
//    NSArray* ableToUpdateFriends = [allFriendsModels allObjects];
//    if ([ableToUpdateFriends containsObject:friendModel])
//    {
//        NSLog(@"Enable update Drawer after friend change status");
//        [[ZZRootStateObserver sharedInstance] notifyWithEvent:ZZRootStateObserverEventFriendInContactChangeStauts notificationObject:nil];
//    }
//}

@end

//
//  ZZGridUpdateService.m
//  Zazo
//
//  Created by ANODA on 11/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridUpdateService.h"
#import "ZZGridCellViewModel.h"
#import "ZZFriendDataProvider.h"
#import "ZZGridDataProvider.h"
#import "ZZGridDataUpdater.h"
#import "TBMFriend.h"



@implementation ZZGridUpdateService

- (void)updateFriendsIfNeeded
{
    NSMutableSet* gridElementToUpdate = [NSMutableSet set];
    
    [[ZZFriendDataProvider friendsOnGrid] enumerateObjectsUsingBlock:^(ZZFriendDomainModel*  _Nonnull friendModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendModel.idTbm];
        
        if (friend.lastIncomingVideoStatusValue == ZZVideoIncomingStatusViewed ||
            friend.lastIncomingVideoStatusValue == ZZVideoIncomingStatusFailedPermanently ||
            friend.lastIncomingVideoStatusValue == ZZVideoIncomingStatusNew)
        {
            [gridElementToUpdate addObject:friendModel];
        }
        
    }];
    
    if ([gridElementToUpdate allObjects].count > 0)
    {
        [self updateGridIfNeededWithElement:[gridElementToUpdate allObjects]];
    }
}

- (void)updateGridIfNeededWithElement:(NSArray*)update
{
    NSArray* gridFriendAbbleToUpdate = [self friendsAbbleToUpdate];
    __block NSMutableArray* updatedGridModels = [NSMutableArray array];
    
    if (update.count > 0 && gridFriendAbbleToUpdate.count > 0)
    {
        [update enumerateObjectsUsingBlock:^(ZZFriendDomainModel*  _Nonnull friendModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < gridFriendAbbleToUpdate.count)
            {
                ZZFriendDomainModel* updatedFriendModel = gridFriendAbbleToUpdate[idx];
                ZZGridDomainModel* gridModel = [ZZGridDataProvider modelWithRelatedUserID:friendModel.idTbm];
                gridModel.relatedUser = updatedFriendModel;
                [ZZGridDataUpdater updateRelatedUserOnItemID:gridModel.itemID toValue:updatedFriendModel];
                [updatedGridModels addObject:gridModel];
            }
        }];
    }
    
    if (updatedGridModels.count > 0)
    {
        [self.delegate updateGridDataWithModels:updatedGridModels];
    }
}

- (NSArray*)friendsAbbleToUpdate
{
    NSMutableSet* allFriendsSet = [NSMutableSet setWithArray:[ZZFriendDataProvider loadAllFriends]];
    NSMutableSet* gridFriendSet = [NSMutableSet setWithArray:[ZZFriendDataProvider friendsOnGrid]];
    [allFriendsSet minusSet:gridFriendSet];
    
    __block NSMutableArray* friendsToUpdate = [NSMutableArray new];
    
    [[allFriendsSet allObjects] enumerateObjectsUsingBlock:^(ZZFriendDomainModel*  _Nonnull friendModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded)
        {
            [friendsToUpdate addObject:friendModel];
        }
    }];
    
    return [self _sortByFirstName:friendsToUpdate];
}

- (NSArray *)_sortByFirstName:(NSArray *)array
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]; // TODO: constant
    NSArray* sortedArray = [array sortedArrayUsingDescriptors:@[sort]];
    
    return sortedArray;
}

@end

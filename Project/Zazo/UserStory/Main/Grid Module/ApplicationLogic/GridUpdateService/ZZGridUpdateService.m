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
#import "ZZFriendDomainModel.h"

@implementation ZZGridUpdateService

- (void)updateFriendsIfNeeded
{
    NSMutableSet* gridElementToUpdate = [NSMutableSet set];
    
    [[ZZFriendDataProvider friendsOnGrid] enumerateObjectsUsingBlock:^(ZZFriendDomainModel*  _Nonnull friendModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusViewed ||
            friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusFailedPermanently ||
            friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusNew)
        {
            [gridElementToUpdate addObject:friendModel];
        }
        
    }];
    
    if ([gridElementToUpdate allObjects].count > 0)
    {
        [self _updateGridIfNeededWithElement:[gridElementToUpdate allObjects]];
    }
}

/**
 *  Adds to grid friends with unviewed messages on empty cells or instead of passed
 *
 *  @param friendsForReplacement friends that can be removed from grid if needed
 */

- (void)_updateGridIfNeededWithElement:(NSArray *)friendsForReplacement
{
    NSMutableArray* friendsToAdding = [[self _friendsAbleToUpdate] mutableCopy];
    __block NSMutableArray* updatedGridModels = [NSMutableArray array];
    
    
    // 1. Use empty cells if exist
    
    ZZGridDomainModel *gridModel = [ZZGridDataProvider loadFirstEmptyGridElement];
    
    while (gridModel && !ANIsEmpty(friendsToAdding))
    {
        ZZFriendDomainModel *friendModel = friendsToAdding.firstObject;
        [friendsToAdding removeObject:friendModel];
        
        [self _putFriend:friendModel toGridModel:gridModel];
        [updatedGridModels addObject:gridModel];
        
        gridModel = [ZZGridDataProvider loadFirstEmptyGridElement];
    }
    
    // 2. Use cells of passed friends
    
    if (friendsForReplacement.count > 0 && friendsToAdding.count > 0)
    {
        [friendsForReplacement enumerateObjectsUsingBlock:^(ZZFriendDomainModel*  _Nonnull friendModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < friendsToAdding.count)
            {
                ZZFriendDomainModel *updatedFriendModel = friendsToAdding[idx];
                ZZGridDomainModel *gridModel = [ZZGridDataProvider modelWithRelatedUserID:friendModel.idTbm];
                [self _putFriend:updatedFriendModel toGridModel:gridModel];
                [updatedGridModels addObject:gridModel];
            }
        }];
    }
    
    if (updatedGridModels.count > 0)
    {
        [self.delegate updateGridDataWithModels:updatedGridModels];
    }
}

- (void)_putFriend:(ZZFriendDomainModel *)friendModel toGridModel:(ZZGridDomainModel *)gridModel
{
    gridModel.relatedUser = friendModel;
    
    [ZZGridDataUpdater updateRelatedUserOnItemID:gridModel.itemID
                                         toValue:friendModel];

}

#pragma mark - Private

/**
 *  _friendsAbleToUpdate
 *
 *  @return Array of friends with unviewed messages
 */

- (NSArray *)_friendsAbleToUpdate
{
    NSMutableSet* allFriendsSet = [NSMutableSet setWithArray:[ZZFriendDataProvider allFriendsModels]?:@[]];
    NSMutableSet* gridFriendSet = [NSMutableSet setWithArray:[ZZFriendDataProvider friendsOnGrid]?:@[]];
 
    [allFriendsSet minusSet:gridFriendSet];

    NSMutableArray* friendsToUpdate = [NSMutableArray new];
    
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

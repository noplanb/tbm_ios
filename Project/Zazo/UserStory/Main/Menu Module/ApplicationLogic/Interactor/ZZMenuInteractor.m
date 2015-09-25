//
//  ZZMenuInteractor.m
//  zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuInteractor.h"
#import "ZZAddressBookDataProvider.h"
#import "ZZFriendDomainModel.h"
#import "ZZFriendsTransportService.h"
#import "FEMObjectDeserializer.h"
#import "ZZGridDataProvider.h"
#import "ZZFriendDataProvider.h"

@implementation ZZMenuInteractor

- (void)loadDataIncludeAddressBookRequest:(BOOL)shouldRequest
{
    NSArray* friends = [ZZFriendDataProvider loadAllFriends];
    [self _sortFriendsFromArray:friends];
    
    [self _loadAddressBookContactsWithRequestAccess:shouldRequest];
}


#pragma mark - Private

- (void)_updateFriends
{
    [[ZZFriendsTransportService loadFriendList] subscribeNext:^(NSArray *array) {
        
        NSArray *friendsArray = [FEMObjectDeserializer deserializeCollectionExternalRepresentation:array
                                                                                      usingMapping:[ZZFriendDomainModel mapping]];
        
        [friendsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [ZZFriendDataProvider upsertFriendWithModel:obj];
        }];
        
        [self loadDataIncludeAddressBookRequest:NO];
        
    } error:^(NSError *error) {
        
    }];
}

- (void)_loadAddressBookContactsWithRequestAccess:(BOOL)shouldRequest
{
    [[ZZAddressBookDataProvider loadContactsWithContactsRequest:shouldRequest] subscribeNext:^(NSArray *addressBookContactsArray) {
        
        [self.output addressBookDataLoaded:addressBookContactsArray];
        
    } error:^(NSError *error) {
        
        [self.output needsPermissionForAddressBook];
        
    }];
}

- (void)_sortFriendsFromArray:(NSArray *)array
{
    NSMutableArray* friendsHasAppArray = [NSMutableArray new];
    NSMutableArray* otherFriendsArray = [NSMutableArray new];
    
    NSArray* gridUsers = [ZZFriendDataProvider friendsOnGrid];
    if (!gridUsers)
    {
        gridUsers = @[];
    }
    
    [array enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friend, NSUInteger idx, BOOL *stop) {
        
        //check if user is on grid - do not add him
        if (![gridUsers containsObject:friend])
        {
            if (friend.hasApp)
            {
                [friendsHasAppArray addObject:friend];
            }
            else
            {
                [otherFriendsArray addObject:friend];
            }
        }
    }];
    
    NSArray *filteredFriendsHasAppArray = [self _filterFriendByConnectionStatus:friendsHasAppArray];
    NSArray *filteredOtherFriendsArray = [self _filterFriendByConnectionStatus:otherFriendsArray];
    
    [self.output friendsThatHasAppLoaded:[self _sortByFirstName:filteredFriendsHasAppArray]];
    [self.output friendsDataLoaded:[self _sortByFirstName:filteredOtherFriendsArray]];

}


#pragma mark - Private

- (NSArray*)_filterFriendByConnectionStatus:(NSMutableArray*)friendsArray
{
    NSMutableArray* filteredFriends = [NSMutableArray new];
    
    [friendsArray enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friendModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([friendModel isCreator])
        {
            if (friendModel.connectionStatusValue == ZZConnectionStatusTypeEstablished ||
                friendModel.connectionStatusValue == ZZConnectionStatusTypeHiddenByCreator)
            {
                [filteredFriends addObject:friendModel];
            }
        }
        else
        {
            if (friendModel.connectionStatusValue == ZZConnectionStatusTypeEstablished ||
                friendModel.connectionStatusValue == ZZConnectionStatusTypeHiddenByTarget)
            {
                [filteredFriends addObject:friendModel];
            }
        }
    }];
    
    return filteredFriends;
}

- (NSArray *)_sortByFirstName:(NSArray *)array
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]; // TODO: constant
    NSArray* sortedArray = [array sortedArrayUsingDescriptors:@[sort]];
    
    return sortedArray;
}

@end

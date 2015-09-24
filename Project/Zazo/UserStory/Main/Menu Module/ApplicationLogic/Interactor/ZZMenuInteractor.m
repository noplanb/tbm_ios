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

- (void)loadData
{
    [[ZZFriendsTransportService loadFriendList] subscribeNext:^(NSArray *array) {
        
        NSArray *friendsArray = [FEMObjectDeserializer deserializeCollectionExternalRepresentation:array
                                                                                      usingMapping:[ZZFriendDomainModel mapping]];
        [self sortFriendsFromArray:friendsArray];
        
        //TODO: it should be loaded from start VC and saved to data base
        
    } error:^(NSError *error) {
        
    }];
}

- (void)loadAddressBookContactsWithRequestAccess:(BOOL)shouldRequest
{
    [[ZZAddressBookDataProvider loadContactsWithContactsRequest:shouldRequest] subscribeNext:^(NSArray *addressBookContactsArray) {
        
        [self.output addressBookDataLoaded:addressBookContactsArray];
        
    } error:^(NSError *error) {
        
        [self.output needPermissionForAddressBook];
        
    }];
}

- (void)sortFriendsFromArray:(NSArray *)array
{
    NSMutableArray* friendsThaHasAppArray = [NSMutableArray new];
    NSMutableArray* otherFriendsArray = [NSMutableArray new];
    
    NSArray* gridUsers = [ZZFriendDataProvider friendsOnGrid];
    if (!gridUsers)
    {
        gridUsers = @[];
    }
    NSArray* gridUsersIDs = [gridUsers valueForKey:ZZFriendDomainModelAttributes.mKey];
    NSSet* gridUserIDsSet = [NSSet setWithArray:gridUsersIDs];
    
    [array enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friend, NSUInteger idx, BOOL *stop) {
        
        //check if user is on grid - do not add him
        if (!ANIsEmpty(friend.mKey) && ![gridUserIDsSet containsObject:friend.mKey])
        {
            if (friend.hasApp)
            {
                [friendsThaHasAppArray addObject:friend];
            }
            else
            {
                [otherFriendsArray addObject:friend];
            }
        }
    }];
    
    if (friendsThaHasAppArray.count > 0)
    {
        [self.output friendsThatHasAppLoaded:[self _sortByFirstName:friendsThaHasAppArray]];
    }
    
    if (otherFriendsArray.count > 0)
    {
        [self.output friendsDataLoaded:[self _sortByFirstName:otherFriendsArray]];
    }
}


#pragma mark - Private

- (NSArray *)_sortByFirstName:(NSArray *)array
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]; // TODO: constant
    NSArray* sortedArray = [array sortedArrayUsingDescriptors:@[sort]];
    
    return sortedArray;
}

@end

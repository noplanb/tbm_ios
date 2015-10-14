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
#import "ZZUserDataProvider.h"

@interface ZZMenuInteractor ()

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isLoaded;

@end

@implementation ZZMenuInteractor

- (void)resetAddressBookData
{
    [ZZAddressBookDataProvider resetAddressBook];
    self.isLoaded = NO;
}

- (void)loadDataIncludeAddressBookRequest:(BOOL)shouldRequest
{
    ANDispatchBlockToBackgroundQueue(^{
        NSArray* friends = [ZZFriendDataProvider loadAllFriends];
        [self _sortFriendsFromArray:friends];
        
        [self _loadAddressBookContactsWithRequestAccess:shouldRequest];
    });
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
    if (!self.isLoading && !self.isLoaded)
    {
        self.isLoading = YES;
        [[ZZAddressBookDataProvider loadContactsWithContactsRequest:shouldRequest] subscribeNext:^(NSArray *addressBookContactsArray) {
            
            [self.output addressBookDataLoaded:addressBookContactsArray];
            self.isLoading = NO;
            self.isLoaded = YES;
            
        } error:^(NSError *error) {
            
            [self.output needsPermissionForAddressBook];
            self.isLoading = NO;
            
        } completed:^{
            self.isLoading = NO;
        }];
    }
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
        
//        friendModel.isFriendshipCreator = ![[ZZUserDataProvider authenticatedUser].mkey isEqualToString:friendModel.friendshipCreatorMkey];
        //TODO:
        if ([friendModel isCreator])
        {
            if (friendModel.friendshipStatusValue == ZZFriendshipStatusTypeEstablished ||
                friendModel.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByCreator)
            {
                [filteredFriends addObject:friendModel];
            }
        }
        else
        {
            if (friendModel.friendshipStatusValue == ZZFriendshipStatusTypeEstablished ||
                friendModel.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByTarget)
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

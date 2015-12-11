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
#import "ZZGridDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZUserDataProvider.h"
#import "ZZStoredSettingsManager.h"

#import "FEMObjectDeserializer.h"

static const NSInteger kDelayBetweenFriendUpdate = 30;

@interface ZZMenuInteractor ()

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, assign) BOOL wasSetuped;
@property (nonatomic, assign) BOOL isNeedUpdate;
@property (nonatomic, assign) BOOL isForceUpdate;

@property (nonatomic, assign) NSTimeInterval startUpdateTime;
@property (nonatomic, assign) NSTimeInterval endUpdateTime;
@property (nonatomic, strong) NSArray* sortedFriends;

@end

@implementation ZZMenuInteractor

- (void)resetAddressBookData
{
    [ZZAddressBookDataProvider resetAddressBook];
    self.isLoaded = NO;
}

- (void)loadDataIncludeAddressBookRequest:(BOOL)shouldRequest shouldOpenDrawer:(BOOL)shouldOpen
{
    self.startUpdateTime = [[NSDate date] timeIntervalSince1970];
    
    if (!self.wasSetuped)
    {
        [self _setupDataAfterFirstLaunchWithAddressBookRequest:shouldRequest shouldOpenDrawer:shouldOpen];
    }
    else
    {
        [self _setupDataWithAddressBookRequest:shouldRequest shouldOpenDrawer:shouldOpen];
    }
}

- (void)enableUpdateContactData
{
    self.isForceUpdate = YES;
}


#pragma mark - Private

- (void)_setupDataAfterFirstLaunchWithAddressBookRequest:(BOOL)shouldRequest shouldOpenDrawer:(BOOL)shouldOpen
{
    self.wasSetuped = YES;
    ANDispatchBlockToBackgroundQueue(^{
        [self _loadFriends];
        [self _loadAddressBookContactsWithRequestAccess:shouldRequest shouldOpenDrawer:shouldOpen];
    });
}

- (void)_setupDataWithAddressBookRequest:(BOOL)shouldRequest shouldOpenDrawer:(BOOL)shouldOpen
{
    ANDispatchBlockToMainQueue(^{
        if (self.isForceUpdate)
        {
            [self _loadFriends];
            self.isForceUpdate = NO;
        }
        else
        {
            if ([self _isNeedToUpdate])
            {
                [self _loadFriends];
            }
            else
            {
                [self.output friendsThatHasAppLoaded:self.sortedFriends];
            }
        }
        
        [self _loadAddressBookContactsWithRequestAccess:shouldRequest shouldOpenDrawer:shouldOpen];
    });
}

- (BOOL)_isNeedToUpdate
{
    BOOL isNeedUpdate = NO;
    
    NSTimeInterval interval = fabs(self.startUpdateTime - self.endUpdateTime);
    
    if (interval > kDelayBetweenFriendUpdate)
    {
        isNeedUpdate = YES;
    }
    
    return isNeedUpdate;
}

- (void)_loadFriends
{
    ANDispatchBlockToMainQueue(^{
        NSArray* friends = [ZZFriendDataProvider loadAllFriends];
        [self _sortFriendsFromArray:friends];
    });
}

- (void)_loadAddressBookContactsWithRequestAccess:(BOOL)shouldRequest shouldOpenDrawer:(BOOL)shouldOpen
{
    if (!self.isLoading && !self.isLoaded)
    {
        self.isLoading = YES;
        [ZZStoredSettingsManager shared].wasPermissionAccess = shouldRequest;
        [[ZZAddressBookDataProvider loadContactsWithContactsRequest:shouldRequest] subscribeNext:^(NSArray *addressBookContactsArray) {
            
            [self.output addressBookDataLoaded:addressBookContactsArray];
            [self.output openDrawerIfEnabled:shouldOpen];
            
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
    
    NSArray* gridUsers = [ZZFriendDataProvider friendsOnGrid];
    if (!gridUsers)
    {
        gridUsers = @[];
    }
    
    [array enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friend, NSUInteger idx, BOOL *stop) {
        
        if (![gridUsers containsObject:friend])
        {
                [friendsHasAppArray addObject:friend];
        }
    }];
    
    NSArray *filteredFriendsHasAppArray = [self _filterFriendByConnectionStatus:friendsHasAppArray];
    
    self.sortedFriends = [self _sortByFirstName:filteredFriendsHasAppArray];
    [self.output friendsThatHasAppLoaded:self.sortedFriends];
     self.endUpdateTime = [[NSDate date] timeIntervalSince1970];
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
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:ZZFriendDomainModelAttributes.firstName ascending:YES];
    NSArray* sortedArray = [array sortedArrayUsingDescriptors:@[sort]];
    
    return sortedArray;
}

@end

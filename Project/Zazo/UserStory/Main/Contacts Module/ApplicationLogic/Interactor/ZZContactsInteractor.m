//
//  ZZContactsInteractor.m
//  zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactsInteractor.h"
#import "ZZAddressBookDataProvider.h"
#import "ZZFriendDomainModel.h"
#import "ZZFriendsTransportService.h"
#import "FEMObjectDeserializer.h"
#import "ZZGridDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZUserDataProvider.h"
#import "ZZStoredSettingsManager.h"

static const NSInteger kDelayBetweenFriendUpdate = 30;

@interface ZZContactsInteractor ()

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, assign) BOOL wasSetuped;
@property (nonatomic, assign) BOOL isNeedUpdate;
@property (nonatomic, assign) BOOL isForceUpdate;

@property (nonatomic, assign) NSTimeInterval startUpdateTime;
@property (nonatomic, assign) NSTimeInterval endUpdateTime;
@property (nonatomic, strong) NSArray *sortedFriends;

@end

@implementation ZZContactsInteractor

- (void)resetAddressBookData
{
    [ZZAddressBookDataProvider resetAddressBook];
    self.isLoaded = NO;
}

- (void)requestAddressBookPermission:(void (^)(BOOL success))completion;
{
    PermissionScope *permissionScope =
            [[PermissionScope alloc] initWithBackgroundTapCancels:NO];

    permissionScope.headerLabel.text = @"Permissions";
    permissionScope.headerLabel.font = [UIFont zz_boldFontWithSize:21];
    permissionScope.bodyLabel.text = @"We need your contacts to show you a list of friends you can send Zazo's to. We only upload a contact's phone number and email to our servers to deliver your message when you send them a Zazo.";
    permissionScope.bodyLabel.font = [UIFont zz_regularFontWithSize:13];
    permissionScope.bodyLabel.numberOfLines = 6;
    [permissionScope.bodyLabel sizeToFit];
    [permissionScope addPermission:[ContactsPermission new] message:@""];

    permissionScope.bodyLabel.transform = CGAffineTransformMakeTranslation(0, 13);
    
    @weakify(permissionScope);
    permissionScope.configureBlock = ^{
        @strongify(permissionScope);
        permissionScope.permissionButtons.firstObject.transform = CGAffineTransformMakeTranslation(0, 40);
    };
    
    [permissionScope show:^(BOOL completed, NSArray<PermissionResult *> *_Nonnull result) {
        if (completed && completion)
        {
            completion(YES);
        }
    }           cancelled:^(NSArray<PermissionResult *> *_Nonnull result) {
        if (completion)
        {
            completion(NO);
        }
    }];
    
    
    
}

- (void)loadData
{
    self.startUpdateTime = [[NSDate date] timeIntervalSince1970];

    if (!self.wasSetuped)
    {
        [self _setupDataAfterFirstLaunchWithAddressBookRequest];
    }
    else
    {
        [self _setupDataWithAddressBookRequest];
    }
}

- (void)enableUpdateContactData
{
    self.isForceUpdate = YES;
}

#pragma mark - Private

- (void)_setupDataAfterFirstLaunchWithAddressBookRequest
{
    self.wasSetuped = YES;
    ANDispatchBlockToBackgroundQueue(^{
        [self _loadFriends];
        [self _loadAddressBookContactsWithRequestAccess];
    });
}

- (void)_setupDataWithAddressBookRequest
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
                [self.output filteredFriendsThatHasAppLoaded:self.sortedFriends];
            }
        }

        [self _loadAddressBookContactsWithRequestAccess];
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
    NSArray *friends = [ZZFriendDataProvider allFriendsModels];
    [self.output allFriendsThatHasAppLoaded:[self _sortByFirstName:friends]];
    [self _sortFriendsFromArray:friends];
}

- (void)_loadAddressBookContactsWithRequestAccess
{
    if (!self.isLoading && !self.isLoaded)
    {
        self.isLoading = YES;

        [[ZZAddressBookDataProvider loadContacts] subscribeNext:^(NSArray *addressBookContactsArray) {

            [self.output addressBookDataLoaded:addressBookContactsArray];

            self.isLoading = NO;
            self.isLoaded = YES;

        }                                                 error:^(NSError *error) {

            [self.output needsPermissionForAddressBook];
            self.isLoading = NO;

        }                                             completed:^{
            self.isLoading = NO;
        }];
    }
}

- (void)_sortFriendsFromArray:(NSArray *)array
{
#ifdef MAKING_SCREENSHOTS
    return;
#endif

    ANDispatchBlockToMainQueue(^{
        NSMutableArray *friendsHasAppArray = [NSMutableArray new];

        NSArray *gridUsers = [ZZFriendDataProvider friendsOnGrid];
        if (!gridUsers)
        {
            gridUsers = @[];
        }

        [array enumerateObjectsUsingBlock:^(ZZFriendDomainModel *friend, NSUInteger idx, BOOL *stop) {

            if (![gridUsers containsObject:friend])
            {
                [friendsHasAppArray addObject:friend];
            }
        }];

        NSArray *filteredFriendsHasAppArray = [self _filterFriendByConnectionStatus:[friendsHasAppArray copy]];

        self.sortedFriends = [self _sortByFirstName:filteredFriendsHasAppArray];
        [self.output filteredFriendsThatHasAppLoaded:self.sortedFriends];
        self.endUpdateTime = [[NSDate date] timeIntervalSince1970];
    });
}


#pragma mark - Private

- (NSArray *)_filterFriendByConnectionStatus:(NSArray *)friendsArray
{
    NSMutableArray *filteredFriends = [NSMutableArray new];

    [friendsArray enumerateObjectsUsingBlock:^(ZZFriendDomainModel *friendModel, NSUInteger idx, BOOL *_Nonnull stop) {

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
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:@[sort]];

    return sortedArray;
}

@end

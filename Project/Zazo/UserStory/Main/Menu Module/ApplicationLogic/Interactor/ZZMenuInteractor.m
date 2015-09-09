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

@implementation ZZMenuInteractor

- (void)loadData
{
    [[ZZAddressBookDataProvider loadContacts] subscribeNext:^(NSArray *addressBookContactsArray) {
        
        [self.output addressBookDataLoaded:addressBookContactsArray];
    }];
    
    [[ZZFriendsTransportService loadFriendList] subscribeNext:^(NSArray *array) {
        
        NSArray *friendsArray = [FEMObjectDeserializer deserializeCollectionExternalRepresentation:array
                                                                                      usingMapping:[ZZFriendDomainModel mapping]];
        [self sortFriendsFromArray:friendsArray];
        
    } error:^(NSError *error) {
        
    }];
}

- (void)sortFriendsFromArray:(NSArray *)array
{
    NSMutableArray* friendsThaHasAppArray = [NSMutableArray new];
    NSMutableArray* otherFriendsArray = [NSMutableArray new];
    
    [array enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friend, NSUInteger idx, BOOL *stop) {
        if (friend.hasApp)
        {
            [friendsThaHasAppArray addObject:friend];
        }
        else
        {
            [otherFriendsArray addObject:friend];
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
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSArray* sortedArray = [array sortedArrayUsingDescriptors:@[sort]];
    
    return sortedArray;
}

@end

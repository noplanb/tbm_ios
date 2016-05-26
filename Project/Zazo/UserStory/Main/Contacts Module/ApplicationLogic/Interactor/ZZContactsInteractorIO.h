//
//  ZZMenuInteractorIO.h
//  zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZFriendDomainModel;

@protocol ZZContactsInteractorInput <NSObject>

- (void)loadData;

- (void)requestAddressBookPermission:(void (^)(BOOL success))completion;

- (void)resetAddressBookData;

- (void)enableUpdateContactData;

@end


@protocol ZZContactsInteractorOutput <NSObject>

- (void)addressBookDataLoaded:(NSArray *)data;

- (void)addressBookDataLoadingDidFailWithError:(NSError *)error;

- (void)filteredFriendsThatHasAppLoaded:(NSArray *)friendsData; // not on grid, not disabled...

- (void)allFriendsThatHasAppLoaded:(NSArray *)friendsData;

- (void)friendsDataLoaded:(NSArray *)friendsData;

- (void)friendsDataLoadingDidFailWithError:(NSError *)error;

- (void)needsPermissionForAddressBook;

@end
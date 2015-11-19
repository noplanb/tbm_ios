//
//  ZZMenuPresenter.m
//  zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import AddressBookUI;

#import "ZZMenuPresenter.h"
#import "ZZMenuDataSource.h"
#import "ZZContactsPermissionAlertBuilder.h"

@interface ZZMenuPresenter ()

@property (nonatomic, strong) ZZMenuDataSource* dataSource;

@end

@implementation ZZMenuPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZMenuViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    self.dataSource = [ZZMenuDataSource new];
    [self.userInterface updateDataSource:self.dataSource];
    
    [self.interactor loadDataIncludeAddressBookRequest:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationWillEnterInBackground)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Output

- (void)addressBookDataLoaded:(NSArray*)data
{
    [self.dataSource setupAddressbookItems:data];
}

- (void)friendsThatHasAppLoaded:(NSArray*)friendsData
{
    [self.dataSource setupFriendsThatHaveAppItems:friendsData];
}

- (void)friendsDataLoaded:(NSArray*)friendsData
{
        [self.dataSource setupFriendsItems:friendsData];
}

- (void)friendsDataLoadingDidFailWithError:(NSError *)error
{
    // TODO:
}

- (void)addressBookDataLoadingDidFailWithError:(NSError *)error
{
    // TODO:
}

- (void)menuToggled
{
    [self.interactor loadDataIncludeAddressBookRequest:YES];
}

- (void)needsPermissionForAddressBook
{
    [ZZContactsPermissionAlertBuilder showNeedAccessForAddressBookAlert];
}

#pragma mark - Module Interface

- (void)itemSelected:(id)item
{   
    ZZMenuCellViewModel* model = (ZZMenuCellViewModel*)item;
    [self.menuModuleDelegate userSelectedOnMenu:model.item];
    [self.wireframe closeMenu];
    [self.interactor enableContactData];
}

#pragma mark - Private

- (void)_applicationWillEnterInBackground
{
    [self.interactor resetAddressBookData];
    [self.wireframe closeMenu];
}

@end

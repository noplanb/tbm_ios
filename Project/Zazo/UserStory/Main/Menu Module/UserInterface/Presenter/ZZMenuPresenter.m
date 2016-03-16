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
#import "ZZRootStateObserver.h"

@interface ZZMenuPresenter ()
<
    ZZRootStateObserverDelegate
>

@property (nonatomic, strong) ZZMenuDataSource* dataSource;

@end

@implementation ZZMenuPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZMenuViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    self.dataSource = [ZZMenuDataSource new];
    [self.userInterface updateDataSource:self.dataSource];
    
    [self.interactor loadDataIncludeAddressBookRequest:NO shouldOpenDrawer:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationWillEnterInBackground)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[ZZRootStateObserver sharedInstance] addRootStateObserver:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadContactMenuData
{
    [self.interactor loadDataIncludeAddressBookRequest:YES shouldOpenDrawer:NO];
    [self.userInterface reloadContactView];
}

- (void)reloadContacts
{
    [self.userInterface reloadContactView];
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
    [self.interactor loadDataIncludeAddressBookRequest:YES shouldOpenDrawer:YES];
}

- (void)needsPermissionForAddressBook
{
    [ZZContactsPermissionAlertBuilder showNeedAccessForAddressBookAlert];
}

#pragma mark ANDrawerNCDelegate

- (void)drawerControllerWillAppearFromPanGesture:(ANDrawerNC *)controller;
{
    [self.interactor loadDataIncludeAddressBookRequest:YES shouldOpenDrawer:YES];
}

#pragma mark - Root state observer delegate

- (void)handleEvent:(ZZRootStateObserverEvents)event notificationObject:(id)notificationObject
{
    if (event == ZZRootStateObserverEventFriendWasAddedToGridWithVideo ||
        event == ZZRootStateObserverEventFriendInContactChangeStauts)
    {
        [self.interactor enableUpdateContactData];
    }
}


#pragma mark - Module Interface

- (void)itemSelected:(id)item
{   
    ZZMenuCellViewModel* model = (ZZMenuCellViewModel*)item;
    [self.menuModuleDelegate userSelectedOnMenu:model.item];
//    [self.wireframe closeMenu];
    [self.interactor enableUpdateContactData];
}

#pragma mark - Private

- (void)_applicationWillEnterInBackground
{
    [self.interactor resetAddressBookData];
//    [self.wireframe closeMenu];
}


#pragma mark - DataSource delegate

- (void)reloadView
{
    [self reloadContactMenuData];
}

@end

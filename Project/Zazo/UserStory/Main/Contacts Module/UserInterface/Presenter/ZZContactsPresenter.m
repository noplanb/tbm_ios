//
//  ZZContactsPresenter.m
//  zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import AddressBookUI;

#import "ZZContactsPresenter.h"
#import "ZZContactsDataSource.h"
#import "ZZContactsPermissionAlertBuilder.h"
#import "ZZRootStateObserver.h"
#import "ZZMainWireframe.h"
#import "ANMemoryStorage.h"
#import "ZZContactsDataSource.h"

@interface ZZContactsPresenter () <ZZRootStateObserverDelegate>

@property (nonatomic, strong) ZZContactsDataSource *dataSource;

@end

@implementation ZZContactsPresenter

@synthesize menuModuleDelegate = _menuModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController <ZZContactsViewInterface> *)userInterface
{
    self.userInterface = userInterface;
    self.dataSource = [ZZContactsDataSource new];
    [self.userInterface updateDataSource:self.dataSource];

    [self.interactor loadData];

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
    [self.interactor loadData];
    [self.userInterface reloadContactView];
}

- (void)reloadContacts
{
    [self.userInterface reloadContactView];
}

#pragma mark - Output

- (void)addressBookDataLoaded:(NSArray *)data
{
    [self.dataSource setupAddressbookItems:data];
    [self.userInterface reloadContactView];
}

- (void)filteredFriendsThatHasAppLoaded:(NSArray *)friendsData
{
    [self.dataSource setupFriendsThatHaveAppItems:friendsData];
}

- (void)allFriendsThatHasAppLoaded:(NSArray *)friendsData
{
    [self.dataSource setupAllFriendItems:friendsData];
}

- (void)friendsDataLoaded:(NSArray *)friendsData
{
//    [self.dataSource setupFriendsItems:friendsData];
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
    [self.interactor loadData];
    [self.userInterface reloadContactView];
}

- (void)needsPermissionForAddressBook
{
    [ZZContactsPermissionAlertBuilder showNeedAccessForAddressBookAlert];
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

- (void)viewDidAppear
{
    [self.interactor requestAddressBookPermission:^(BOOL success) {

        if (success)
        {
            [self.interactor enableUpdateContactData];
            [self.interactor loadData];
            [self.userInterface reloadContactView];

        }
        else
        {
            self.wireframe.mainWireframe.activeTab = ZZMainWireframeTabGrid;
        }
    }];
}

- (void)itemSelected:(id)item
{
    ZZLogEvent(@"item selected: %@", item);
    
    ZZContactCellViewModel *model = item;
    [self.menuModuleDelegate userSelectedOnMenu:model.item];
    self.wireframe.mainWireframe.activeTab = ZZMainWireframeTabGrid;
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

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

@interface ZZMenuPresenter ()

@property (nonatomic, strong) ZZMenuDataSource* dataSource;

@end

@implementation ZZMenuPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZMenuViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    self.dataSource = [ZZMenuDataSource new];
    [self.userInterface updateDataSource:self.dataSource];
    
    [self.interactor loadData];
}


#pragma mark - Output

- (void)addressBookDataLoaded:(NSArray*)data
{
    ANDispatchBlockToMainQueue(^{
        [self.dataSource setupAddressbookItems:data];
    });
}

- (void)friendsThatHasAppLoaded:(NSArray*)friendsData
{
    ANDispatchBlockToMainQueue(^{
        [self.dataSource setupFriendsThatHaveAppItems:friendsData];
    });
}

- (void)friendsDataLoaded:(NSArray*)friendsData
{
    ANDispatchBlockToMainQueue(^{
        [self.dataSource setupFriendsItems:friendsData];
    });
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
    [self.interactor loadAddressBookContactsWithRequestAccess:YES];
}

#pragma mark - Module Interface

- (void)itemSelected:(id)item
{   
    ZZMenuCellViewModel* model = (ZZMenuCellViewModel*)item;
    [self.menuModuleDelegate selectedUser:model.item];
    [self.wireframe closeMenu];
}

@end

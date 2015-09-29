//
//  ZZEditFriendListPresenter.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEditFriendListPresenter.h"
#import "ZZEditFriendListDataSource.h"
#import "ZZEditFriendCellViewModel.h"

@interface ZZEditFriendListPresenter () <ZZEditFriendListDataSourceDelegate>

@property (nonatomic, strong) ZZEditFriendListDataSource* tableDataSource;
@property (nonatomic, strong) ZZEditFriendCellViewModel* selectedViewModel;

@end

@implementation ZZEditFriendListPresenter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.tableDataSource = [ZZEditFriendListDataSource new];
        self.tableDataSource.delegate = self;
    }
    return self;
}

- (void)configurePresenterWithUserInterface:(UIViewController<ZZEditFriendListViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    [self.userInterface updateDataSource:self.tableDataSource];
    [self.interactor loadData];
}

#pragma mark - Output

- (void)dataLoaded:(NSArray*)friends
{
    ANDispatchBlockToMainQueue(^{
        [self.tableDataSource setupStorageWithModels:[self _convertToViewModels:friends]];
        [self.userInterface updateDataSource:self.tableDataSource];
    });
}

- (void)contactSuccessfullyUpdated:(ZZFriendDomainModel *)model toVisibleState:(BOOL)isVisible
{
    self.selectedViewModel.item = model;
    [self.tableDataSource updateViewModel:self.selectedViewModel];
    if (isVisible)
    {
        [self.editFriendListModuleDelegate friendWasUnblockedFromContacts:model];
    }
    else
    {
        [self.editFriendListModuleDelegate friendWasRemovedFromContacts:model];
    }
}

- (void)updatedWithError:(NSError *)error
{
    
}

- (NSArray *)_convertToViewModels:(NSArray *)models
{
    return [[models.rac_sequence map:^id(ZZFriendDomainModel* friendModel) {
        
        ZZEditFriendCellViewModel* viewModel = [ZZEditFriendCellViewModel new];
        viewModel.item = friendModel;
        return viewModel;
    }] array];
}

#pragma mark - Module Interface

- (void)dismissController
{
    [self.wireframe dismissEditFriendListController];
}

#pragma mark - ZZEditFriendListDataSourceDelegate

- (void)changeContactStatusTypeForModel:(ZZEditFriendCellViewModel *)model
{
    self.selectedViewModel = model;
    [self.interactor changeContactStatusTypeForFriend:model.item];
}

@end

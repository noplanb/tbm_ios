//
//  ZZGridInteractor.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridInteractor.h"
#import "ZZGridCenterCellViewModel.h"
#import "ZZGridDomainModel.h"
#import "ZZMenuCellViewModel.h"
#import "ZZContactDomainModel.h"
#import "ZZFriendDomainModel.h"

static NSInteger const kGridCellCount = 9;
static NSInteger const kGridCenterCellIndex = 4;

@interface ZZGridInteractor ()

@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) NSIndexPath* selectedIndexPath;
@property (nonatomic, strong) id selectedUserModel;

@end

@implementation ZZGridInteractor

- (void)loadData
{
    self.dataArray = [NSMutableArray array];
    
    for (NSInteger count = 0;count<kGridCellCount;count++)
    {
        id model;
        if (count == kGridCenterCellIndex)
        {
            model = [ZZGridCenterCellViewModel new];
        }
        else
        {
            model = [ZZGridDomainModel new];
        }
        [self.dataArray addObject:model];
    }
    
    [self.output dataLoadedWithArray:self.dataArray];
}

- (NSInteger)centerCellIndex
{
    return self.dataArray.count/2;
}

- (void)selectedPlusCellWithIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
}

- (void)selectedUserWithModel:(id)model
{
    self.selectedUserModel = model;
    [self _updateSelectedModelWithUser];
}

- (void)_updateSelectedModelWithUser
{
    id dataModel = self.dataArray[self.selectedIndexPath.row];
    ZZGridDomainModel* model = (ZZGridDomainModel*)dataModel;
    model.relatedUser = [self friendModelFromMenuModel:self.selectedUserModel];
   
    [self.output modelUpdatedWithUserWithModel:model];
}

- (ZZFriendDomainModel*)friendModelFromMenuModel:(ZZMenuCellViewModel*)model
{
    ZZFriendDomainModel* friendModel;
    
    if ([model.item isMemberOfClass:[ZZContactDomainModel class]])
    {
        ZZContactDomainModel* contactModel = (ZZContactDomainModel*)model.item;
        friendModel = [ZZFriendDomainModel new];
        friendModel.firstName = contactModel.firstName;
        friendModel.lastName = contactModel.lastName;
        friendModel.mobileNumber = [[contactModel.phones allObjects] firstObject];
    }
    else
    {
        friendModel = (ZZFriendDomainModel*)model.item;
    }
    
    return friendModel;
}

@end

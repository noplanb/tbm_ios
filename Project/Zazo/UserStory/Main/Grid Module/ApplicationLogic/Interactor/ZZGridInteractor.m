 //
//  ZZGridInteractor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridInteractor.h"
#import "ZZGridCenterCellViewModel.h"
#import "ZZMenuCellViewModel.h"
#import "ZZContactDomainModel.h"
#import "ZZFriendDomainModel.h"
#import "ZZGridCellViewModel.h"
#import "ZZGridDomainModel.h"
#import "ZZGridDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZPhoneHelper.h"
#import "ZZUserDataProvider.h"
#import "ZZFriendsTransportService.h"
#import "ZZUserFriendshipStatusHandler.h"
#import "TBMFriend.h"
#import "ZZCommonModelsGenerator.h"
#import "ZZGridTransportService.h"
#import "ZZCommunicationDomainModel.h"
#import "ZZGridUIConstants.h"

static NSInteger const kGridFriendsCellCount = 8;

@interface ZZGridInteractor ()

@property (nonatomic, strong) NSArray* gridModels;

@end

@implementation ZZGridInteractor

- (void)loadData
{
    NSArray *friendArrayForSorting = [ZZFriendDataProvider loadAllFriends];
    [friendArrayForSorting sortedArrayUsingComparator:^NSComparisonResult(ZZFriendDomainModel* obj1, ZZFriendDomainModel* obj2) {
        return [obj1.lastActionTimestamp compare:obj2.lastActionTimestamp];
    }];
    
    NSArray* gridStoredModels = [ZZGridDataProvider loadAllGridsSortByIndex:YES];
    
    NSMutableArray* gridModels = [NSMutableArray array];
    for (NSInteger count = 0; count < kGridFriendsCellCount; count++)
    {
        ZZGridDomainModel* model;
        if (gridStoredModels.count > count)
        {
            model = gridStoredModels[count];
        }
        else
        {
            model = [ZZGridDomainModel new];
        }
        model.index = @(kNextGridElementIndexFromCount(count));
        if (friendArrayForSorting.count > count)
        {
            ZZFriendDomainModel *aFriend = friendArrayForSorting[count];
            model.relatedUser = aFriend;
        }

        model = [ZZGridDataProvider upsertModel:model];
        [gridModels addObject:model];
    }
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    NSArray* descriptorsArray = @[sort];
    self.gridModels = [gridModels sortedArrayUsingDescriptors:descriptorsArray];
    [self.output dataLoadedWithArray:self.gridModels];
}






#pragma mark - Add Friend to Grid

- (void)addUserToGrid:(id)friendModel
{
    if (!ANIsEmpty(friendModel))
    {
        if ([friendModel isKindOfClass:[ZZFriendDomainModel class]])
        {
            [self _addUserAsFriendToGrid:(ZZFriendDomainModel*)friendModel];
        }
        else if ([friendModel isKindOfClass:[ZZContactDomainModel class]])
        {
            [self _addUserAsContactToGrid:(ZZContactDomainModel*)friendModel];
        }
    }
}

- (void)_addUserAsFriendToGrid:(ZZFriendDomainModel*)friendModel
{
    ZZFriendDomainModel* containedUser;
    if (![self _isFriendsOnGridContainFriendModel:friendModel withContainedFriend:&containedUser])
    {
        BOOL shouldBeVisible = [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel];
        if (!shouldBeVisible)
        {
            friendModel.contactStatusValue = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friendModel];
            [ZZFriendDataProvider upsertFriendWithModel:friendModel];
            
            [[ZZFriendsTransportService changeModelContactStatusForUser:friendModel.mKey
                                                              toVisible:!shouldBeVisible] subscribeNext:^(NSDictionary* response) {
            }];
        }
        
        ZZGridDomainModel* model = [ZZGridDataProvider loadFirstEmptyGridElement];
        
        if (ANIsEmpty(model))
        {
            model = [self _loadGridModelWithLatestAction];
            model.relatedUser = friendModel;
        }
        else
        {
            model.relatedUser = friendModel;
        }
        [ZZGridDataProvider upsertModel:model];
        [self.output updateGridWithModel:model];
    }
    else
    {
        [self.output gridContainedFriend:containedUser];
    }
}

- (void)_addUserAsContactToGrid:(ZZContactDomainModel*)model
{
    ZZFriendDomainModel* containedUser;
    if ([self _isFriendsOnGridContainContactFriendModel:model withContainedFriend:&containedUser])
    {
        //implement check friend logic
        [self.output gridContainedFriend:containedUser];
    }
    else
    {
        model.phones = [ZZPhoneHelper validatePhonesFromContactModel:model];
        if (!ANIsEmpty(model.phones))
        {
            if (ANIsEmpty(model.primaryPhone))
            {
                [self.output userNeedsToPickPrimaryPhone:model];
            }
            else
            {
                //send has app and invitation requests
                [self _checkIsContactHasApp:model];
            }
        }
        else
        {
            [self.output userHasNoValidNumbers:model];
        }
    }
}





- (void)removeUserFromContacts:(ZZFriendDomainModel*)model
{
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* gridModel, NSUInteger idx, BOOL *stop) {
        
        if ([gridModel.relatedUser.idTbm isEqualToString:model.idTbm]) {
            gridModel.relatedUser = nil;
            [ZZGridDataProvider upsertModel:gridModel];
            [self.output updateGridWithModel:gridModel];
            *stop = YES;
        }
    }];
}


- (void)userSelectedPrimaryPhoneNumber:(ZZContactDomainModel*)phoneNumber
{
    [self _checkIsContactHasApp:phoneNumber];
}

- (void)inviteUserInApplication:(ZZContactDomainModel*)contact
{
    [self _loadFriendModelFromContact:contact];
}

- (void)updateLastActionForFriend:(ZZFriendDomainModel*)friendModel
{
    friendModel.lastActionTimestamp = [NSDate date];
    [ZZFriendDataProvider upsertFriendWithModel:friendModel];
}

- (void)handleNotificationForFriend:(TBMFriend *)friendEntity
{
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider modelFromEntity:friendEntity];
    
    __block ZZGridDomainModel *modelThatContainCurrentFriend;
    
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
        if ([obj.relatedUser.mKey isEqualToString:friendModel.mKey])
        {
            modelThatContainCurrentFriend = obj;
            *stop = YES;
        }
    }];
    
    if (ANIsEmpty(modelThatContainCurrentFriend))
    {
            ZZGridDomainModel* model = [ZZGridDataProvider loadFirstEmptyGridElement];
        
            if (ANIsEmpty(model))
            {
                model = [self _loadGridModelWithLatestAction];
                model.relatedUser = friendModel;
            }
            else
            {
                model.relatedUser = friendModel;
            }
            [ZZGridDataProvider upsertModel:model];
            [self.output updateGridWithModelFromNotification:modelThatContainCurrentFriend];
    }
    else
    {
        modelThatContainCurrentFriend.relatedUser = friendModel;
        id model = [ZZGridDataProvider upsertModel:modelThatContainCurrentFriend];
        [self.output updateGridWithModelFromNotification:model];
    }
}

- (void)loadFeedbackModel
{
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
    [self.output feedbackModelLoadedSuccessfully:[ZZCommonModelsGenerator feedbackModelWithUser:user]];
}

- (BOOL)_isFriendsOnGridContainFriendModel:(ZZFriendDomainModel*)friendModel withContainedFriend:(ZZFriendDomainModel**)containtedUser
{
    __block BOOL isContainModel = NO;
    
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
        if ([obj.relatedUser isEqual:friendModel])
        {
            *containtedUser = obj.relatedUser;
            isContainModel = YES;
            *stop = YES;
        }
    }];
    return isContainModel;
}

- (BOOL)_isFriendsOnGridContainContactFriendModel:(ZZContactDomainModel*)contactModel
                              withContainedFriend:(ZZFriendDomainModel**)containtedUser
{
    __block BOOL isContainModel = NO;
    
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
        if ([[obj.relatedUser fullName] isEqualToString:[contactModel fullName]])
        {
            *containtedUser = obj.relatedUser;
            isContainModel = YES;
            *stop = YES;
        }
    }];
    
    if (!isContainModel)
    {
        NSArray* validNumbers = [ZZPhoneHelper validatePhonesFromContactModel:contactModel];
        if (!ANIsEmpty(validNumbers))
        {
            [validNumbers enumerateObjectsUsingBlock:^(ZZCommunicationDomainModel* communicationModel, NSUInteger idx, BOOL *stop) {
                NSString *trimmedNumber = [communicationModel.contact stringByReplacingOccurrencesOfString:@" " withString:@""];
                [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
                    if ([[obj.relatedUser mobileNumber] isEqualToString:trimmedNumber])
                    {
                        *containtedUser = obj.relatedUser;
                        isContainModel = YES;
                        *stop = YES;
                    }
                }];
            }];
        }
    }
    
    return isContainModel;
}



#pragma mark - Private

- (ZZGridDomainModel*)_loadGridModelWithLatestAction
{
    NSArray *sortingByLastAction = [NSArray arrayWithArray:self.gridModels];
    
    [sortingByLastAction sortedArrayUsingComparator:^NSComparisonResult(ZZGridDomainModel* obj1, ZZGridDomainModel* obj2) {
        return [obj1.relatedUser.lastActionTimestamp compare:obj2.relatedUser.lastActionTimestamp];
    }];
    
    return [sortingByLastAction firstObject];
}


#pragma mark - Transport 

- (void)_checkIsContactHasApp:(ZZContactDomainModel*)contact
{
    [self.output loadedStateUpdatedTo:YES];
    [[ZZGridTransportService checkIsUserHasApp:contact] subscribeNext:^(id x) {
        if ([x boolValue])
        {
            [self _loadFriendModelFromContact:contact];
        }
        else
        {
            [self.output loadedStateUpdatedTo:NO];
            [self.output userHasNoAppInstalled:contact];
        }
    } error:^(NSError *error) {
        [self.output loadedStateUpdatedTo:NO];
    }];
}

- (void)_loadFriendModelFromContact:(ZZContactDomainModel*)contact
{
    [[ZZGridTransportService inviteUserToApp:contact] subscribeNext:^(ZZFriendDomainModel* x) {
        [self.output friendRecievedFromServer:x];
        [self.output loadedStateUpdatedTo:NO];

    } error:^(NSError *error) {
        [self.output loadedStateUpdatedTo:NO];
    }];
}

@end

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
#import "TBMUser.h"
#import "ZZGridDomainModel.h"
#import "ZZGridDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZPhoneHelper.h"
#import "ZZUserDataProvider.h"
#import "FEMObjectDeserializer.h"
#import "ZZFriendsTransportService.h"
#import "ZZUserFriendshipStatusHandler.h"
#import "TBMFriend.h"
#import "ZZCommonNetworkTransportService.h"
#import "ZZCommonModelsGenerator.h"
#import "ZZGridTransportService.h"

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
        model.index = @(count);
        if (friendArrayForSorting.count > count)
        {
            ZZFriendDomainModel *aFriend = friendArrayForSorting[count];
            model.relatedUser = aFriend;
        }

        model = [ZZGridDataProvider upsertModel:model];
        [gridModels addObject:model];
    }
    self.gridModels = [NSArray arrayWithArray:gridModels];
    [self.output dataLoadedWithArray:self.gridModels];
    
    //#pragma mark - Old // TODO:
    [[ZZCommonNetworkTransportService loadS3Credentials] subscribeNext:^(id x) {}];
}


#pragma mark - Add Friend to Grid

- (void)addUserToGrid:(id)friendModel
{
    if (!ANIsEmpty(friendModel))
    {
        if ([friendModel isKindOfClass:[ZZFriendDomainModel class]])
        {
            ZZFriendDomainModel* newFriend = friendModel;
            
            ZZFriendDomainModel* containedUser;
            if (![self _isFriendsOnGridContainFriendModel:newFriend withContainedFriend:&containedUser])
            {
                [self _friendSelectedFromMenu:newFriend];
            }
            else
            {
                [self.output gridContainedFriend:containedUser];
            }
        }
        else if ([friendModel isKindOfClass:[ZZContactDomainModel class]])
        {
            ZZContactDomainModel* newContact = friendModel;
            
            ZZFriendDomainModel* containedUser;
            if ([self _isFriendsOnGridContainContactFriendModel:newContact withContainedFriend:&containedUser])
            {
                //implement check friend logic
                [self.output gridContainedFriend:containedUser];
            }
            else
            {
                newContact.phones = [ZZPhoneHelper validatePhonesFromContactModel:newContact];
                if (!ANIsEmpty(newContact.phones))
                {
                    if (ANIsEmpty(newContact.primaryPhone))
                    {
                        [self.output userNeedsToPickPrimaryPhone:newContact];
                    }
                    else
                    {
                        //send has app and invitation requests
                        [self _checkIfAnInvitedUserHasApp:newContact];
                    }
                }
                else
                {
                    [self.output userHasNoValidNumbers:newContact];
                }
            }

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
    [self _checkIfAnInvitedUserHasApp:phoneNumber];
}

- (void)inviteUserInApplication:(ZZContactDomainModel*)contact
{
    [self getInvitedFriendFromServer:contact];
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



- (ZZFriendDomainModel*)_friendModelFromMenuModel:(id)model
{
    ZZFriendDomainModel* friendModel;
    
    if ([model isMemberOfClass:[ZZContactDomainModel class]])
    {
        ZZContactDomainModel* contactModel = (ZZContactDomainModel*)model;
        friendModel = [ZZFriendDomainModel new];
        friendModel.firstName = contactModel.firstName;
        friendModel.lastName = contactModel.lastName;
        friendModel.mobileNumber = [contactModel.phones firstObject];
    }
    else
    {
        friendModel = (ZZFriendDomainModel*)model;
    }
    
    return friendModel;
}

- (BOOL)_isFriendsOnGridContainFriendModel:(ZZFriendDomainModel *)friendModel withContainedFriend:(ZZFriendDomainModel**)containtedUser
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

- (BOOL)_isFriendsOnGridContainContactFriendModel:(ZZContactDomainModel*)contactModel withContainedFriend:(ZZFriendDomainModel**)containtedUser
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
            [validNumbers enumerateObjectsUsingBlock:^(NSString* number, NSUInteger idx, BOOL *stop) {
                NSString *trimmedNumber = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
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


#pragma mark - User Selection

- (void)_friendSelectedFromMenu:(ZZFriendDomainModel*)friend
{
    BOOL shouldBeVisible = [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friend];
    if (!shouldBeVisible)
    {
        friend.contactStatusValue = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friend];
        [ZZFriendDataProvider upsertFriendWithModel:friend];
        
        [[ZZFriendsTransportService changeModelContactStatusForUser:friend.mKey
                                                          toVisible:!shouldBeVisible] subscribeNext:^(NSDictionary* response) {
        }];
    }
    
    
    // TODO: check if we have empty elements on grid and place to specified index new friend
    
    // retrive grid item releva
    
    
    //TODO: 
//    if (self.selectedFromGrid)
//    {
//        self.selectedModel.relatedUser = friend;
//        
//        [ZZGridDataProvider upsertModel:self.selectedModel];
//        [self.output modelUpdatedWithUserWithModel:self.selectedModel];
//    }
//    else
//    {
//        ZZGridDomainModel* model = [ZZGridDataProvider loadFirstEmptyGridElement];
//        
//        if (ANIsEmpty(model))
//        {
//            model = [self _loadGridModelWithLatestAction];
//            model.relatedUser = friend;
//        }
//        else
//        {
//            model.relatedUser = friend;
//        }
//        
//        [ZZGridDataProvider upsertModel:model];
//        
//        [self.output updateGridWithModel:model];
//    }
}



#pragma mark - Transport 

- (void)_checkIfAnInvitedUserHasApp:(ZZContactDomainModel*)contact
{
    [[ZZGridTransportService checkIsUserHasApp:contact] subscribeNext:^(id x) {
        if ([x boolValue])
        {
            [self getInvitedFriendFromServer:contact];
        }
        else
        {
            [self.output userHasNoAppInstalled:contact];
        }
    }];
}

- (void)getInvitedFriendFromServer:(ZZContactDomainModel*)contact
{
    [[ZZGridTransportService inviteUserToApp:contact] subscribeNext:^(ZZFriendDomainModel* x) {
        [self.output friendRecievedFromServer:x];
    }];
}

@end

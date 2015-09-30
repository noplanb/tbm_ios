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
#import "NSObject+ANRACAdditions.h"
#import "ZZGridDataUpdater.h"

static NSInteger const kGridFriendsCellCount = 8;

@interface ZZGridInteractor () <TBMVideoStatusNotificationProtocol>

@property (nonatomic, strong) NSArray* gridModels;

@end

@implementation ZZGridInteractor

- (void)loadData
{
    self.gridModels = [self _generateGridModels];
    [self.output dataLoadedWithArray:self.gridModels];
    
    [TBMFriend addVideoStatusNotificationDelegate:self];
}


#pragma mark - Grid Updates

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

- (void)removeUserFromContacts:(ZZFriendDomainModel*)model
{
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* gridModel, NSUInteger idx, BOOL *stop) {
        
        if ([gridModel.relatedUser isEqual:model])
        {
            gridModel.relatedUser = nil;
            [self _upsertGridModel:gridModel];
            [self.output updateGridWithModel:gridModel];
            *stop = YES;
        }
    }];
    
    //TODO: copy paste from menu interactor

    ZZFriendDomainModel *newFriendForEpmtyGridViewModel = [self _loadFirstFriendFromMenu:[ZZFriendDataProvider loadAllFriends]];
    if (!ANIsEmpty(newFriendForEpmtyGridViewModel))
    {
        [self addUserToGrid:newFriendForEpmtyGridViewModel];
    }
    
}

- (ZZFriendDomainModel*)_loadFirstFriendFromMenu:(NSArray *)array
{
    NSMutableArray* friendsHasAppArray = [NSMutableArray new];
    NSMutableArray* otherFriendsArray = [NSMutableArray new];
    
    NSArray* gridUsers = [ZZFriendDataProvider friendsOnGrid];
    if (!gridUsers)
    {
        gridUsers = @[];
    }
    
    [array enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friend, NSUInteger idx, BOOL *stop) {
        
        //check if user is on grid - do not add him
        if (![gridUsers containsObject:friend])
        {
            if (friend.hasApp)
            {
                [friendsHasAppArray addObject:friend];
            }
            else
            {
                [otherFriendsArray addObject:friend];
            }
        }
    }];
    
    NSArray *filteredFriendsHasAppArray = [self _filterFriendByConnectionStatus:friendsHasAppArray];
    NSArray *filteredOtherFriendsArray = [self _filterFriendByConnectionStatus:otherFriendsArray];
    
    NSArray* allFilteredFriendsArray = [filteredFriendsHasAppArray arrayByAddingObjectsFromArray:filteredOtherFriendsArray];
    NSArray* sortedByFirstNameArray = [self _sortByFirstName:allFilteredFriendsArray];
    
    if (!ANIsEmpty(sortedByFirstNameArray))
    {
        return [sortedByFirstNameArray firstObject];
    }
    else
    {
        return nil;
    }
}

- (NSArray*)_filterFriendByConnectionStatus:(NSMutableArray*)friendsArray
{
    NSMutableArray* filteredFriends = [NSMutableArray new];
    
    [friendsArray enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friendModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([friendModel isCreator])
        {
            if (friendModel.connectionStatusValue == ZZConnectionStatusTypeEstablished ||
                friendModel.connectionStatusValue == ZZConnectionStatusTypeHiddenByCreator)
            {
                [filteredFriends addObject:friendModel];
            }
        }
        else
        {
            if (friendModel.connectionStatusValue == ZZConnectionStatusTypeEstablished ||
                friendModel.connectionStatusValue == ZZConnectionStatusTypeHiddenByTarget)
            {
                [filteredFriends addObject:friendModel];
            }
        }
    }];
    
    return filteredFriends;
}

- (NSArray *)_sortByFirstName:(NSArray *)array
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]; // TODO: constant
    NSArray* sortedArray = [array sortedArrayUsingDescriptors:@[sort]];
    
    return sortedArray;
}



#pragma mark - User Invitation

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
    
    NSMutableArray* array = [self.gridModels mutableCopy];
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.relatedUser isEqual:friendModel])
        {
            obj.relatedUser = friendModel;
        }
    }];
    
    self.gridModels = [array copy];
    [ZZFriendDataProvider upsertFriendWithModel:friendModel];
}



#pragma mark - Update after stoppedVideo

- (void)updateFriendAfterVideoStopped:(ZZFriendDomainModel *)model
{
//    [self updateLastActionForFriend:model];
//    
//    
//    __block ZZGridDomainModel* gridModel = nil;;
//    NSMutableArray* array = [self.gridModels mutableCopy];
//    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj.relatedUser.mKey isEqualToString:model.mKey])
//        {
//            obj.relatedUser = model;
//            gridModel = obj;
//        }
//    }];
//    self.gridModels = [array copy];
//    
//    if (!ANIsEmpty(gridModel))
//    {
//        [self.output updateGridWithGridDomainModel:gridModel];
//    }
    [self updateLastActionForFriend:model];
    [self.output reloadGridWithData:[self _generateGridModels]];
}


#pragma mark - Notifications

- (void)handleNotificationForFriend:(TBMFriend *)friendEntity
{
    if (!ANIsEmpty(friendEntity))
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
            [self _upsertGridModel:model];
            [self.output updateGridWithModelFromNotification:model isNewFriend:YES];
        }
        else
        {
            modelThatContainCurrentFriend.relatedUser = friendModel;
            id model = [self _upsertGridModel:modelThatContainCurrentFriend];
            [self.output updateGridWithModelFromNotification:model isNewFriend:NO];
        }
    }
}


#pragma mark - Feedback

- (void)loadFeedbackModel
{
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
    [self.output feedbackModelLoadedSuccessfully:[ZZCommonModelsGenerator feedbackModelWithUser:user]];
}

- (void)showDownloadAniamtionForFriend:(TBMFriend *)friend
{
    __block ZZGridDomainModel* modelForDownloadAnimation = nil;
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel*  obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.relatedUser.mKey isEqualToString:friend.mkey])
        {
            modelForDownloadAnimation = obj;
            *stop = YES;
        }
    }];
    if (!ANIsEmpty(modelForDownloadAnimation))
    {
        [self.output updateGridWithDownloadAnimationModel:modelForDownloadAnimation];
    }
//    [self.output reloadGridWithData:[self _generateGridModels]];
}

#pragma mark - Private

- (ZZFriendDomainModel*)_friendModelOnGridMatchedToFriendModel:(ZZFriendDomainModel*)friendModel
{
    __block ZZFriendDomainModel* containedModel = nil;
    
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
        if ([obj.relatedUser isEqual:friendModel])
        {
            containedModel = obj.relatedUser;
            *stop = YES;
        }
    }];
    return containedModel;
}

- (ZZFriendDomainModel*)_friendOnGridMatchedToContact:(ZZContactDomainModel*)contactModel
{
    __block ZZFriendDomainModel* containtedUser = nil;
    
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
        if ([[obj.relatedUser fullName] isEqualToString:[contactModel fullName]])
        {
            containtedUser = obj.relatedUser;
            *stop = YES;
        }
    }];
    
    if (!containtedUser)
    {
        NSArray* validNumbers = [ZZPhoneHelper validatePhonesFromContactModel:contactModel];
        if (!ANIsEmpty(validNumbers))
        {
            [validNumbers enumerateObjectsUsingBlock:^(ZZCommunicationDomainModel* communicationModel, NSUInteger idx, BOOL *stop) {
                
                NSString *trimmedNumber = [communicationModel.contact stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
                    if ([[obj.relatedUser mobileNumber] isEqualToString:trimmedNumber])
                    {
                        containtedUser = obj.relatedUser;
                        *stop = YES;
                    }
                }];
            }];
        }
    }
    return containtedUser;
}



#pragma mark - Private

- (ZZGridDomainModel*)_loadGridModelWithLatestAction
{
    NSArray *sortingByLastAction = [NSArray arrayWithArray:self.gridModels];
    
    NSSortDescriptor* secriptor = [NSSortDescriptor sortDescriptorWithKey:@"relatedUser.lastActionTimestamp" ascending:YES];
    sortingByLastAction = [sortingByLastAction sortedArrayUsingDescriptors:@[secriptor]];
    
    return [sortingByLastAction firstObject];
}

- (void)_addUserAsFriendToGrid:(ZZFriendDomainModel*)friendModel
{
    ZZFriendDomainModel* containedUser = [self _friendModelOnGridMatchedToFriendModel:friendModel];
    if (ANIsEmpty(containedUser))
    {
        BOOL shouldBeVisible = [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel];
        if (!shouldBeVisible)
        {
            friendModel.connectionStatusValue = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friendModel];
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
        
        [self _upsertGridModel:model];
        [self.output updateGridWithModel:model];
    }
    else
    {
        [self.output gridContainedFriend:containedUser];
    }
}

- (ZZGridDomainModel*)_upsertGridModel:(ZZGridDomainModel*)model
{
    NSMutableArray* array = [self.gridModels mutableCopy];
    [self.gridModels enumerateObjectsUsingBlock:^(ZZGridDomainModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.index == model.index)
        {
            [array replaceObjectAtIndex:idx withObject:model];
        }
    }];
    
    self.gridModels = [array copy];
    return [ZZGridDataUpdater upsertGridModelWithModel:model];
}

- (void)_addUserAsContactToGrid:(ZZContactDomainModel*)model
{
    ZZFriendDomainModel* containedUser = [self _friendOnGridMatchedToContact:model];
    if (!ANIsEmpty(containedUser))
    {
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
                [self _checkIsContactHasApp:model];
            }
        }
        else
        {
            [self.output userHasNoValidNumbers:model];
        }
    }
}


#pragma mark - TBMFriend Delegate 

- (void)videoStatusDidChange:(TBMFriend*)model
{
    [self.output reloadGridWithData:[self _generateGridModels]];
    
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
        [self.output addingUserToGridDidFailWithError:error forUser:contact];
    }];
}

- (void)_loadFriendModelFromContact:(ZZContactDomainModel*)contact
{
    [[ZZGridTransportService inviteUserToApp:contact] subscribeNext:^(ZZFriendDomainModel* x) {
        [self.output friendRecievedFromServer:x];
        [self.output loadedStateUpdatedTo:NO];

    } error:^(NSError *error) {
        [self.output loadedStateUpdatedTo:NO];
        [self.output addingUserToGridDidFailWithError:error forUser:contact];
    }];
}


#pragma mark - Loading

- (NSArray*)_generateGridModels
{
    NSArray* allfriends = [ZZFriendDataProvider loadAllFriends];
    NSMutableArray* filteredFriends = [NSMutableArray new];
    
    [allfriends enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friendModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([friendModel isCreator])
        {
            if (friendModel.connectionStatusValue == ZZConnectionStatusTypeEstablished ||
                friendModel.connectionStatusValue == ZZConnectionStatusTypeHiddenByCreator)
            {
                [filteredFriends addObject:friendModel];
            }
        }
        else
        {
            if (friendModel.connectionStatusValue == ZZConnectionStatusTypeEstablished ||
                friendModel.connectionStatusValue == ZZConnectionStatusTypeHiddenByTarget)
            {
                [filteredFriends addObject:friendModel];
            }
        }
    }];
    
    [filteredFriends sortedArrayUsingComparator:^NSComparisonResult(ZZFriendDomainModel* obj1, ZZFriendDomainModel* obj2) {
        return [obj1.lastActionTimestamp compare:obj2.lastActionTimestamp];
    }];
    
    NSArray* gridStoredModels = [ZZGridDataProvider loadAllGridsSortByIndex:YES];
    NSMutableArray* gridModels = [NSMutableArray array];
    
    if (gridStoredModels.count != kGridFriendsCellCount)
    {
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
            model.index = count;
            if (filteredFriends.count > count)
            {
                ZZFriendDomainModel *aFriend = filteredFriends[count];
                model.relatedUser = aFriend;
            }
            
            model = [ZZGridDataUpdater upsertGridModelWithModel:model];
            [gridModels addObject:model];
        }
    }
    else
    {
        gridModels = [gridStoredModels mutableCopy];
    }
    
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"indexPathIndexForItem" ascending:YES];
    return [gridModels sortedArrayUsingDescriptors:@[sort]];
}


@end

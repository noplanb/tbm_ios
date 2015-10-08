//
//  ZZGridInteractor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridInteractor.h"
#import "ZZContactDomainModel.h"
#import "ZZFriendDomainModel.h"
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
#import "ZZGridDataUpdater.h"
#import "ZZFriendDataUpdater.h"

static NSInteger const kGridFriendsCellCount = 8;

@interface ZZGridInteractor () <TBMVideoStatusNotificationProtocol>

@end

@implementation ZZGridInteractor

- (void)loadData
{
    [self.output dataLoadedWithArray:[self _gridModels]];
    [TBMFriend addVideoStatusNotificationDelegate:self];
}

- (void)addUserToGrid:(id)friendModel
{
    if (!ANIsEmpty(friendModel))
    {
        if ([friendModel isKindOfClass:[ZZFriendDomainModel class]])
        {
            [self _addUserAsFriendToGrid:(ZZFriendDomainModel*)friendModel fromNotification:NO];
        }
        else if ([friendModel isKindOfClass:[ZZContactDomainModel class]])
        {
            [self _addUserAsContactToGrid:(ZZContactDomainModel*)friendModel];
        }
    }
}

- (void)removeUserFromContacts:(ZZFriendDomainModel*)model
{
    BOOL isContainedOnGrid = [ZZGridDataProvider isRelatedUserOnGridWithID:model.idTbm];
    if (isContainedOnGrid)
    {
        ZZGridDomainModel* gridModel = [ZZGridDataProvider modelWithRelatedUserID:model.idTbm];
        gridModel = [ZZGridDataUpdater updateRelatedUserOnItemID:gridModel.itemID toValue:nil];
        [self updateLastActionForFriend:model];
        [self.output updateGridWithModel:gridModel isNewFriend:NO];
        
        ZZFriendDomainModel *fillHoleOnGrid = [self _loadFirstFriendFromMenu:[ZZFriendDataProvider loadAllFriends]];
        if (!ANIsEmpty(fillHoleOnGrid))
        {
            [self addUserToGrid:fillHoleOnGrid];
        }
    }
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
    ANDispatchBlockToBackgroundQueue(^{
       [ZZFriendDataUpdater updateLastTimeActionFriendWithID:friendModel.idTbm];
    });
}


#pragma mark - Update after stoppedVideo

- (void)updateFriendAfterVideoStopped:(ZZFriendDomainModel *)model
{
    ZZGridDomainModel* gridModel = [ZZGridDataProvider modelWithRelatedUserID:model.idTbm];
    gridModel.isDownloadAnimationViewed = YES;
    [self.output reloadGridModel:gridModel];
    [self updateLastActionForFriend:model];
//    NSArray* gridModels = [self gridModelsWithoutDownloadAnimation];
//    [self.output reloadGridWithData:gridModels];
//    [self updateLastActionForFriend:model];
    
}

- (NSArray*)gridModelsWithoutDownloadAnimation
{
    NSArray* gridModels = [[[self _gridModels].rac_sequence map:^id(ZZGridDomainModel* value) {
        value.isDownloadAnimationViewed = YES;
        return value;
    }] array];
    
    return gridModels;
}


#pragma mark - Feedback

- (void)loadFeedbackModel
{
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
    [self.output feedbackModelLoadedSuccessfully:[ZZCommonModelsGenerator feedbackModelWithUser:user]];
}


#pragma mark - Private

- (NSArray*)_gridModels
{
    NSArray* gridModels = [ZZGridDataProvider loadAllGridsSortByIndex:NO];
    if (gridModels.count != kGridFriendsCellCount)
    {
        gridModels = [ZZGridDataProvider loadOrCreateGridModelsWithCount:kGridFriendsCellCount];
    }
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"indexPathIndexForItem" ascending:YES];
    return [gridModels sortedArrayUsingDescriptors:@[sort]];
}

- (ZZFriendDomainModel*)_loadFirstFriendFromMenu:(NSArray*)array
{
    NSArray* gridUsers = [ZZFriendDataProvider friendsOnGrid];
    gridUsers = gridUsers ? : @[];
    
    NSMutableArray* friendsArray = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friend, NSUInteger idx, BOOL *stop) {
        if (![gridUsers containsObject:friend] && [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friend])
        {
            [friendsArray addObject:friend];
        }
    }];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSArray* sortedByFirstNameArray = [friendsArray sortedArrayUsingDescriptors:@[sort]];
    
    return [sortedByFirstNameArray firstObject];
}

- (void)_addUserAsFriendToGrid:(ZZFriendDomainModel*)friendModel fromNotification:(BOOL)isFromNotification
{
    BOOL isUserAlreadyOnGrid = [ZZGridDataProvider isRelatedUserOnGridWithID:friendModel.idTbm];
   
    if (!isUserAlreadyOnGrid)
    {
        BOOL shouldBeVisible = [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel];
        if (!shouldBeVisible)
        {
            ZZFriendshipStatusType status = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friendModel];
            friendModel = [ZZFriendDataUpdater updateConnectionStatusForUserWithID:friendModel.idTbm toValue:status];
            
            [[ZZFriendsTransportService changeModelContactStatusForUser:friendModel.mKey
                                                              toVisible:!shouldBeVisible] subscribeNext:^(NSDictionary* response) {
            }];
        }
        
        ZZGridDomainModel* model = [ZZGridDataProvider loadFirstEmptyGridElement];
        if (ANIsEmpty(model))
        {
            model = [ZZGridDataProvider modelWithEarlierLastActionFriend];
        }
        
        model = [ZZGridDataUpdater updateRelatedUserOnItemID:model.itemID toValue:friendModel];
        
        [self updateLastActionForFriend:model.relatedUser];
        if (isFromNotification)
        {
            [self.output updateGridWithModelFromNotification:model isNewFriend:!isUserAlreadyOnGrid];
        }
        else
        {
            [self.output updateGridWithModel:model isNewFriend:!isUserAlreadyOnGrid];
        }
    }
    else
    {
        ZZGridDomainModel* gridModel = [ZZGridDataProvider modelWithRelatedUserID:friendModel.idTbm];
        if (isFromNotification)
        {
            [self.output updateGridWithModelFromNotification:gridModel isNewFriend:!isUserAlreadyOnGrid];
        }
        else
        {
            [self.output gridAlreadyContainsFriend:gridModel];
        }
    }
}

- (void)_addUserAsContactToGrid:(ZZContactDomainModel*)model
{
    ZZGridDomainModel* gridModel = [ZZGridDataProvider modelWithContact:model];
    if (!ANIsEmpty(gridModel))
    {
        [self.output gridAlreadyContainsFriend:gridModel];
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
    ZZGridDomainModel* gridModel = [ZZGridDataProvider modelWithRelatedUserID:model.idTbm];
    if (!gridModel)
    {
        if (model.lastVideoStatusEventTypeValue == INCOMING_VIDEO_STATUS_EVENT_TYPE &&
            model.lastIncomingVideoStatusValue == INCOMING_VIDEO_STATUS_DOWNLOADING)
        {
            [self addUserToGrid:[ZZFriendDataProvider modelFromEntity:model]];
        }
    }
    else
    {
        [self.output reloadGridModel:gridModel];
    }
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
        
        [ZZFriendDataUpdater upsertFriend:x];
        
        [self.output friendRecievedFromServer:x];
        [self.output loadedStateUpdatedTo:NO];

    } error:^(NSError *error) {
        [self.output loadedStateUpdatedTo:NO];
        [self.output addingUserToGridDidFailWithError:error forUser:contact];
    }];
}

@end

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
#import "ZZGridInteractor+ActionHandler.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZVideoStatusHandler.h"
#import "ZZRootStateObserver.h"
#import "ZZGridUpdateService.h"
#import <NSString+ANAdditions.h>


static NSInteger const kGridFriendsCellCount = 8;

@interface ZZGridInteractor ()
<
    ZZVideoStatusHandlerDelegate,
    ZZRootStateObserverDelegate,
    ZZGridUpdateServiceDelegate
>

@property (nonatomic, strong) ZZGridUpdateService* gridUpdateService;

@end

@implementation ZZGridInteractor

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[ZZVideoStatusHandler sharedInstance] addVideoStatusHandlerObserver:self];
        [[ZZRootStateObserver sharedInstance] addRootStateObserver:self];
        self.gridUpdateService = [ZZGridUpdateService new];
        self.gridUpdateService.delegate = self;
    }
    
    return self;
}

- (void)dealloc
{
    [[ZZVideoStatusHandler sharedInstance] removeVideoStatusHandlerObserver:self];
    [[ZZRootStateObserver sharedInstance] removeRootStateObserver:self];
}

- (void)loadData
{
    [self.output dataLoadedWithArray:[self _gridModels]];
    [self _configureFeatureObserver];
}

- (void)reloadDataAfterResetUserData
{
    [self.output reloadGridAfterClearUserDataWithData:[self _gridModels]];
}

- (void)_configureFeatureObserver
{
    [RACObserve([ZZGridActionStoredSettings shared], frontCameraHintWasShown) subscribeNext:^(NSNumber* x) {
        [self.output updateSwithCameraFeatureIsEnabled:[x boolValue]];
    }];
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

- (void)updateGridViewModels:(NSArray *)models
{
    [ZZGridDataUpdater upsertGridModels:models];
}


#pragma mark - User Invitation

- (void)userSelectedPrimaryPhoneNumber:(ZZContactDomainModel*)phoneNumber
{
    ZZGridDomainModel* gridModel = [ZZGridDataProvider modelWithContact:phoneNumber];
    
    if ([self _isContactExistAsFriendAndAbleAddToGrid:phoneNumber])
    {
        [self _addFriendFromDrawerToGirdWithContact:phoneNumber];
    }
    else if (!ANIsEmpty(gridModel))
    {
        [self.output gridAlreadyContainsFriend:gridModel];
    }
    else if (!ANIsEmpty(phoneNumber.primaryPhone.contact))
    {
        [self _checkIsContactHasApp:phoneNumber];
    }
    else
    {
        [self.output userHasNoValidNumbers:phoneNumber];
    }
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
}

- (void)updateGridWithModel:(ZZGridDomainModel *)model
{
    [self.output reloadGridModel:model];
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


#pragma mark - Edit Friends

- (void)friendWasUpdatedFromEditContacts:(ZZFriendDomainModel*)friendModel toVisible:(BOOL)isVisible
{
    if (isVisible)
    {
        ZZGridDomainModel* model = [ZZGridDataProvider loadFirstEmptyGridElement];
        if (ANIsEmpty(model))
        {
            model = [ZZGridDataProvider modelWithEarlierLastActionFriend];
        }
        
        model = [ZZGridDataUpdater updateRelatedUserOnItemID:model.itemID toValue:friendModel];
        [self updateLastActionForFriend:model.relatedUser];
        [self.output updateGridWithModel:model isNewFriend:NO];
    }
    else
    {
        [self removeUserFromContacts:friendModel];
    }
}


#pragma mark - Private

- (NSArray*)_gridModels
{
    NSArray* gridModels = [ZZGridDataProvider loadAllGridsSortByIndex:NO];
    gridModels = [ZZGridDataProvider loadOrCreateGridModelsWithCount:kGridFriendsCellCount];
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"indexPathIndexForItem" ascending:YES];
    NSArray* sortedArray = [gridModels sortedArrayUsingDescriptors:@[sort]];
    
    return sortedArray;
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
        ZZGridDomainModel* model = [ZZGridDataProvider loadFirstEmptyGridElement];
        if (ANIsEmpty(model))
        {
            model = [ZZGridDataProvider modelWithEarlierLastActionFriend];
        }
        
        model = [ZZGridDataUpdater updateRelatedUserOnItemID:model.itemID toValue:friendModel];
        
        [self updateLastActionForFriend:model.relatedUser];
        [self.output updateGridWithModel:model isNewFriend:!isUserAlreadyOnGrid];
    }
    else
    {
        ZZGridDomainModel* gridModel = [ZZGridDataProvider modelWithRelatedUserID:friendModel.idTbm];
        if (isFromNotification)
        {
            [self.output updateGridWithModel:gridModel isNewFriend:!isUserAlreadyOnGrid];
        }
    }
}

- (void)_addUserAsContactToGrid:(ZZContactDomainModel*)model
{
    model.phones = [ZZPhoneHelper validatePhonesFromContactModel:model];
    
    if (!ANIsEmpty(model.phones))
    {
        if (ANIsEmpty(model.primaryPhone) ||
            (!ANIsEmpty(model.primaryPhone) && model.phones.count > 1))
        {
            [self.output userNeedsToPickPrimaryPhone:model];
        }
        else if ([self _isContactExistAsFriendAndAbleAddToGrid:model])
        {
            [self _addFriendFromDrawerToGirdWithContact:model];
        }
        else
        {
            [self userSelectedPrimaryPhoneNumber:model];
        }
    }
    else
    {
        [self.output userHasNoValidNumbers:model];
    }
}

- (BOOL)_isContactOnGrid:(ZZContactDomainModel*)model
{
    BOOL isOnGrid = NO;
    TBMFriend* friend = [self _friendFromContact:model];
    TBMGridElement* gridElement = [ZZGridDataProvider findWithFriend:friend];
    isOnGrid = !(gridElement == nil);
    
    return isOnGrid;
}

- (BOOL)_isFriendExistWithContact:(ZZContactDomainModel*)model
{
    BOOL friendExist = NO;
    TBMFriend* friend = [self _friendFromContact:model];
    friendExist = !(friend == nil);
    
    return friendExist;
}

- (TBMFriend*)_friendFromContact:(ZZContactDomainModel*)model
{
    NSString* mobilePhone =
    [[[model primaryPhone] contact] stringByReplacingOccurrencesOfString:@" "
                                                              withString:@""];

    TBMFriend* friend = [ZZFriendDataProvider friendWithMobileNumber:mobilePhone];
    
    return friend;
}


#pragma mark - Add friend from drawer to grid if contact is already friend

- (BOOL)_isContactExistAsFriendAndAbleAddToGrid:(ZZContactDomainModel*)model
{
    return ([self _isFriendExistWithContact:model] && ![self _isContactOnGrid:model]);
}

- (void)_addFriendFromDrawerToGirdWithContact:(ZZContactDomainModel*)model
{
    TBMFriend* friend = [self _friendFromContact:model];
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithItemID:friend.idTbm];
    [self.output showAlreadyContainFriend:friendModel compeltion:^{
        [self addUserToGrid:friendModel];
    }];
}


#pragma mark - Video Status Handler delegate

- (void)videoStatusChangedWithFriendID:(NSString *)friendID
{
    TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];
    ZZGridDomainModel* gridModel = [ZZGridDataProvider modelWithRelatedUserID:friendID];

    if (!gridModel)
    {
        ZZFriendDomainModel* friendModel = [ZZFriendDataProvider modelFromEntity:friend];
        //TODO:
        BOOL shouldBeVisible = [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel];
        
        if (!shouldBeVisible)
        {
            BOOL isUserSendsUsAVideo = ((friend.lastVideoStatusEventTypeValue == ZZVideoStatusEventTypeIncoming) &&
                                        (friend.lastIncomingVideoStatusValue  == ZZVideoIncomingStatusDownloading ||
                                         friend.lastIncomingVideoStatusValue == ZZVideoIncomingStatusFailedPermanently));
            
            BOOL isUserViewedOurVideo = ((friend.lastVideoStatusEventTypeValue == ZZVideoStatusEventTypeOutgoing) &&
                                         (friend.outgoingVideoStatusValue  == ZZVideoOutgoingStatusViewed));
            
            if (isUserSendsUsAVideo | isUserViewedOurVideo)
            {
                ZZFriendshipStatusType status = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friendModel];
                friendModel = [ZZFriendDataUpdater updateConnectionStatusForUserWithID:friendModel.idTbm toValue:status];
                
                [[ZZFriendsTransportService changeModelContactStatusForUser:friendModel.mKey
                                                                  toVisible:!shouldBeVisible] subscribeNext:^(NSDictionary* response) {
                }];
                
                [self _addUserAsFriendToGrid:friendModel fromNotification:YES];
            }
            else
            {
                [self _addUserAsFriendToGrid:friendModel fromNotification:YES];
            }
        }
        if (shouldBeVisible)
        {
            [self _addUserAsFriendToGrid:friendModel fromNotification:YES];
        }
    }
    else if (gridModel &&
             !ANIsEmpty(gridModel.relatedUser) &&
             !gridModel.isDownloadAnimationViewed)
    {
        [self.output reloadAfterVideoUpdateGridModel:gridModel];
    }
//    else
//    {
//        // if friend addded after delete from grid
//        ZZFriendDomainModel* friendModel = [ZZFriendDataProvider modelFromEntity:model];
//        [self friendWasUpdatedFromEditContacts:friendModel toVisible:YES];
//    }
    
    
    [self _handleModel:gridModel];
    
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
        
        if (x.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByCreator ||
            x.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByTarget ||
            x.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByBoth)
        {
            [self changeContactStatusTypeForFriend:x];
        }
        else
        {
            if (!ANIsEmpty(contact.emails))
            {
                [[ZZGridTransportService updateContactEmails:contact friend:x] subscribeNext:^(id x) {}];
            }
            
            [ZZFriendDataUpdater upsertFriend:x];
            
            [self.output friendRecievedFromServer:x];
            [self.output loadedStateUpdatedTo:NO];
        }
        

    } error:^(NSError *error) {
        [self.output loadedStateUpdatedTo:NO];
        [self.output addingUserToGridDidFailWithError:error forUser:contact];
    }];
}

- (void)changeContactStatusTypeForFriend:(ZZFriendDomainModel *)friendModel
{
    friendModel.friendshipStatusValue = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friendModel];
    
    BOOL shouldBeVisible = [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel];
    
    [[ZZFriendsTransportService changeModelContactStatusForUser:friendModel.mKey
                                                      toVisible:shouldBeVisible] subscribeNext:^(NSDictionary* response) {
        
        [ZZFriendDataUpdater updateConnectionStatusForUserWithID:friendModel.idTbm
                                                         toValue:friendModel.friendshipStatusValue];
        
        [self friendWasUpdatedFromEditContacts:friendModel toVisible:YES];
        [self.output updateFriendThatPrevouslyWasOnGridWithModel:friendModel];
        [self.output loadedStateUpdatedTo:NO];
    } error:^(NSError *error) {
        //TODO: revert status?
        [self.output loadedStateUpdatedTo:NO];
    }];
}


#pragma mark - Update grid 

- (void)updateGridIfNeeded
{
    [self.gridUpdateService updateFriendsIfNeeded];
}

- (void)updateGridDataWithModels:(NSArray *)models
{
    [models enumerateObjectsUsingBlock:^(ZZGridDomainModel*  _Nonnull gridModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.output updateGridWithModel:gridModel isNewFriend:NO];
    }];
}


#pragma mark - Root State Observer Delegate

- (void)handleEvent:(ZZRootStateObserverEvents)event notificationObject:(id)notificationObject
{
    if (event == ZZRootStateObserverEventDonwloadedMkeys)
    {
        if (!ANIsEmpty(notificationObject))
        {
            [self.output updatedFeatureWithFriendMkeys:notificationObject];
        }
    }
}

@end

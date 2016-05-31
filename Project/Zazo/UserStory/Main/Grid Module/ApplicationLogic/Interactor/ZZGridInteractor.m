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
#import "ZZFriendsTransportService.h"
#import "ZZUserFriendshipStatusHandler.h"
#import "ZZGridTransportService.h"
#import "ZZGridDataUpdater.h"
#import "ZZFriendDataUpdater.h"
#import "ZZGridInteractor+ActionHandler.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZVideoStatusHandler.h"
#import "ZZRootStateObserver.h"
#import "ZZGridUpdateService.h"
#import "ZZVideoDataProvider.h"
#import "ZZRemoteUnlockedFeaturesUpdater.h"


static NSInteger const kGridFriendsCellCount = 8;

@interface ZZGridInteractor ()
        <
        ZZVideoStatusHandlerDelegate,
        ZZRootStateObserverDelegate,
        ZZGridUpdateServiceDelegate
        >

@property (nonatomic, strong) ZZGridUpdateService *gridUpdateService;

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
    [RACObserve([ZZGridActionStoredSettings shared], switchCameraFeatureEnabled) subscribeNext:^(NSNumber *x) {
        [self.output updateSwithCameraFeatureIsEnabled:[x boolValue]];
    }];
}

- (void)addUserToGrid:(id)model
{
    if (!ANIsEmpty(model))
    {
        if ([model isKindOfClass:[ZZFriendDomainModel class]])
        {
            [self _addUserAsFriendToGrid:(ZZFriendDomainModel *)model fromNotification:NO];
        }
        else if ([model isKindOfClass:[ZZContactDomainModel class]])
        {
            [self _addUserAsContactToGrid:(ZZContactDomainModel *)model];
        }
    }
}

- (void)removeUserFromContacts:(ZZFriendDomainModel *)model
{
    BOOL isContainedOnGrid = [ZZGridDataProvider isRelatedUserOnGridWithID:model.idTbm];
    if (isContainedOnGrid)
    {
        ZZGridDomainModel *gridModel = [ZZGridDataProvider modelWithRelatedUserID:model.idTbm];
        gridModel = [ZZGridDataUpdater updateRelatedUserOnItemID:gridModel.itemID toValue:nil];
        [self updateLastActionForFriend:model];
        [self.output updateGridWithModel:gridModel isNewFriend:NO];

        ZZFriendDomainModel *fillHoleOnGrid = [self _loadFirstFriendFromMenu:[ZZFriendDataProvider allFriendsModels]];
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

- (void)userSelectedPrimaryPhoneNumber:(ZZContactDomainModel *)phoneNumber
{
    ZZGridDomainModel *gridModel = [ZZGridDataProvider modelWithContact:phoneNumber];

    if ([self _isContactExistAsFriendAndAbleAddToGrid:phoneNumber])
    {
        [self _addFriendFromDrawerToGridWithContact:phoneNumber];
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

- (void)inviteUserInApplication:(ZZContactDomainModel *)contact
{
    [self _loadFriendModelFromContact:contact];
}

- (void)updateLastActionForFriend:(ZZFriendDomainModel *)friendModel
{
    ANDispatchBlockToBackgroundQueue(^{
        [ZZFriendDataUpdater updateLastTimeActionFriendWithID:friendModel.idTbm];
    });
}


#pragma mark - Update after stoppedVideo

- (void)updateFriendAfterVideoStopped:(ZZFriendDomainModel *)model
{
    ZZGridDomainModel *gridModel = [ZZGridDataProvider modelWithRelatedUserID:model.idTbm];
    gridModel.isDownloadAnimationViewed = YES;
    [self.output reloadGridModel:gridModel];
    [self updateLastActionForFriend:model];
}

#pragma mark - Edit Friends

- (void)friendWasUpdatedFromEditContacts:(ZZFriendDomainModel *)friendModel toVisible:(BOOL)isVisible
{
    if (isVisible)
    {
        ZZGridDomainModel *model = [ZZGridDataProvider loadFirstEmptyGridElement];
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

- (NSArray *)_gridModels
{
    NSArray *gridModels = [ZZGridDataProvider loadOrCreateGridModelsWithCount:kGridFriendsCellCount];

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"indexPathIndexForItem" ascending:YES];
    NSArray *sortedArray = [gridModels sortedArrayUsingDescriptors:@[sort]];

    return sortedArray;
}

- (ZZFriendDomainModel *)_loadFirstFriendFromMenu:(NSArray *)array
{
    NSArray *gridUsers = [ZZFriendDataProvider friendsOnGrid];
    gridUsers = gridUsers ?: @[];

    NSMutableArray *friendsArray = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(ZZFriendDomainModel *friendModel, NSUInteger idx, BOOL *stop) {

        if (![gridUsers containsObject:friendModel] && [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel])
        {
            [friendsArray addObject:friendModel];
        }
    }];

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSArray *sortedByFirstNameArray = [friendsArray sortedArrayUsingDescriptors:@[sort]];

    return [sortedByFirstNameArray firstObject];
}

- (void)_addUserAsFriendToGrid:(ZZFriendDomainModel *)friendModel fromNotification:(BOOL)isFromNotification
{
    BOOL isUserAlreadyOnGrid = [ZZGridDataProvider isRelatedUserOnGridWithID:friendModel.idTbm];

    if (isUserAlreadyOnGrid)
    {
        ZZGridDomainModel *gridModel = [ZZGridDataProvider modelWithRelatedUserID:friendModel.idTbm];
        
        if (isFromNotification)
        {
            [self.output updateGridWithModel:gridModel isNewFriend:NO];
        }
    }
    else
    {
        ZZGridDomainModel *gridModel = [ZZGridDataProvider loadFirstEmptyGridElement];
        if (ANIsEmpty(gridModel))
        {
            gridModel = [ZZGridDataProvider modelWithEarlierLastActionFriend];
        }

        gridModel = [ZZGridDataUpdater updateRelatedUserOnItemID:gridModel.itemID toValue:friendModel];
        
        [self updateLastActionForFriend:gridModel.relatedUser];
        [self.output updateGridWithModel:gridModel isNewFriend:YES];
    }
    
}

- (void)_addUserAsContactToGrid:(ZZContactDomainModel *)contactModel
{
    contactModel.phones = [ZZPhoneHelper validatePhonesFromContactModel:contactModel];

    if (!ANIsEmpty(contactModel.phones))
    {
        if (ANIsEmpty(contactModel.primaryPhone) ||
                (!ANIsEmpty(contactModel.primaryPhone) && contactModel.phones.count > 1))
        {
            [self.output userNeedsToPickPrimaryPhone:contactModel];
        }
        else if ([self _isContactExistAsFriendAndAbleAddToGrid:contactModel])
        {
            [self _addFriendFromDrawerToGridWithContact:contactModel];

        }
        else
        {
            [self userSelectedPrimaryPhoneNumber:contactModel];
        }
    }
    else
    {
        [self.output userHasNoValidNumbers:contactModel];
    }
}

- (BOOL)_isContactOnGrid:(ZZContactDomainModel *)contactModel
{
    ZZGridDomainModel *gridElement = [ZZGridDataProvider modelWithContact:contactModel];

    return gridElement != nil;
}

- (BOOL)_isFriendExistWithContact:(ZZContactDomainModel *)contactModel
{
    ZZFriendDomainModel *friend = [self _friendFromContact:contactModel];

    return friend != nil;
}

- (ZZFriendDomainModel *)_friendFromContact:(ZZContactDomainModel *)contactModel
{
    NSString *mobilePhone =
            [[[contactModel primaryPhone] contact] stringByReplacingOccurrencesOfString:@" "
                                                                             withString:@""];

    ZZFriendDomainModel *friend = [ZZFriendDataProvider friendWithMobileNumber:mobilePhone];

    return friend;
}


#pragma mark - Add friend from drawer to grid if contact is already friend

- (BOOL)_isContactExistAsFriendAndAbleAddToGrid:(ZZContactDomainModel *)contactModel
{
    return ([self _isFriendExistWithContact:contactModel] && ![self _isContactOnGrid:contactModel]);
}

- (void)_addFriendFromDrawerToGridWithContact:(ZZContactDomainModel *)contactModel
{
    ZZFriendDomainModel *friend = [self _friendFromContact:contactModel];
    [self.output showAlreadyContainFriend:friend compeltion:^{
        [self addUserToGrid:friend];
    }];
}


#pragma mark - Video Status Handler delegate

- (void)videoID:(NSString *)videoID downloadProgress:(CGFloat)progress
{
    ZZVideoDomainModel *videoModel = [ZZVideoDataProvider itemWithID:videoID];

    if (videoModel.incomingStatusValue != ZZVideoIncomingStatusDownloading)
    {
        return;
    }

    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:videoModel.relatedUserID];

    if (friendModel)
    {
        [self.output updateDownloadProgress:progress forModel:friendModel];
    }
}

- (void)videoStatusChangedWithFriendID:(NSString *)friendID
{
    ZZGridDomainModel *gridModel = [ZZGridDataProvider modelWithRelatedUserID:friendID];

    if (!gridModel)
    {
        ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:friendID];

        //TODO:
        BOOL shouldBeVisible = [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel];

        if (!shouldBeVisible)
        {
            BOOL isUserSendsUsAVideo = ((friendModel.lastVideoStatusEventType == ZZVideoStatusEventTypeIncoming) &&
                    (friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading ||
                            friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusFailedPermanently));

            BOOL isUserViewedOurVideo = ((friendModel.lastVideoStatusEventType == ZZVideoStatusEventTypeOutgoing) &&
                    (friendModel.lastOutgoingVideoStatus == ZZVideoOutgoingStatusViewed));

            if (isUserSendsUsAVideo | isUserViewedOurVideo)
            {
                ZZFriendshipStatusType status = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friendModel];
                [ZZFriendDataUpdater updateFriendWithID:friendModel.idTbm setConnectionStatus:status];
                friendModel = [ZZFriendDataProvider friendWithItemID:friendID];

                [[ZZFriendsTransportService changeModelContactStatusForUser:friendModel.mKey
                                                                  toVisible:!shouldBeVisible] subscribeNext:^(NSDictionary *response) {
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
    else if (!ANIsEmpty(gridModel.relatedUser) &&
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

- (void)_checkIsContactHasApp:(ZZContactDomainModel *)contactModel
{
    [self.output loadingStateUpdatedTo:YES];
    [[ZZGridTransportService checkIsUserHasApp:contactModel] subscribeNext:^(id x) {
        if ([x boolValue])
        {
            [self _loadFriendModelFromContact:contactModel];
        }
        else
        {
            [self.output loadingStateUpdatedTo:NO];
            [self.output userHasNoAppInstalled:contactModel];
        }
    }                                                                error:^(NSError *error) {
        [self.output loadingStateUpdatedTo:NO];
        [self.output addingUserToGridDidFailWithError:error forUser:contactModel];
    }];
}

- (void)_loadFriendModelFromContact:(ZZContactDomainModel *)contactModel
{
    [[ZZGridTransportService inviteUserToApp:contactModel] subscribeNext:^(ZZFriendDomainModel *friendModel) {

        if (friendModel.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByCreator ||
                friendModel.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByTarget ||
                friendModel.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByBoth)
        {
            [self changeContactStatusTypeForFriend:friendModel];
        }
        else
        {
            if (!ANIsEmpty(contactModel.emails))
            {
                [[ZZGridTransportService updateContactEmails:contactModel friend:friendModel] subscribeNext:^(id x) {
                }];
            }

            [ZZFriendDataUpdater upsertFriend:friendModel];

            [self.output friendRecievedFromServer:friendModel];
            [self.output loadingStateUpdatedTo:NO];
        }


    }                                                              error:^(NSError *error) {
        [self.output loadingStateUpdatedTo:NO];
        [self.output addingUserToGridDidFailWithError:error forUser:contactModel];
    }];
}

- (void)changeContactStatusTypeForFriend:(ZZFriendDomainModel *)friendModel
{
    friendModel.friendshipStatusValue = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friendModel];

    BOOL shouldBeVisible = [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel];

    [[ZZFriendsTransportService changeModelContactStatusForUser:friendModel.mKey
                                                      toVisible:shouldBeVisible] subscribeNext:^(NSDictionary *response) {

        [ZZFriendDataUpdater updateFriendWithID:friendModel.idTbm
                            setConnectionStatus:friendModel.friendshipStatusValue];

        [self friendWasUpdatedFromEditContacts:friendModel toVisible:YES];
        [self.output updateFriendThatPrevouslyWasOnGridWithModel:friendModel];
        [self.output loadingStateUpdatedTo:NO];
    }                                                                                    error:^(NSError *error) {
        //TODO: revert status?
        [self.output loadingStateUpdatedTo:NO];
    }];
}


#pragma mark - Update grid 

- (void)updateGridIfNeeded
{
    [self.gridUpdateService updateFriendsIfNeeded];
}

- (void)updateGridDataWithModels:(NSArray *)models
{
    [models enumerateObjectsUsingBlock:^(ZZGridDomainModel *_Nonnull gridModel, NSUInteger idx, BOOL *_Nonnull stop) {
        [self.output updateGridWithModel:gridModel isNewFriend:NO];
    }];
}


#pragma mark - Root State Observer Delegate

- (void)handleEvent:(ZZRootStateObserverEvents)event notificationObject:(id)notificationObject
{
    if (event == ZZRootStateObserverEventDownloadedMkeys)
    {
        if (!ANIsEmpty(notificationObject))
        {
            [self _updatedFeatureWithFriendMkeys:notificationObject];
        }
    }
    else if (event == ZZRootStateObserverEventDownloadedSettings)
    {
        if (!ANIsEmpty(notificationObject))
        {
            [self _updateSettingWithDictionary:notificationObject];
        }
    }
}

- (void)_updateSettingWithDictionary:(NSDictionary *)settings
{
    if (![settings isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    NSArray *openedFeatures = settings[@"openedFeatures"];
    
    if (ANIsEmpty(openedFeatures))
    {
        return;
    }
    
    openedFeatures = [openedFeatures filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lenght > 0"]];
    
    [[ZZRemoteUnlockedFeaturesUpdater sharedInstance] unlockFeaturesWithNames:openedFeatures];
}

- (void)_updatedFeatureWithFriendMkeys:(NSArray *)keys
{
    EverSentHelper *helper = [EverSentHelper sharedInstance];
    
    NSMutableArray *keysM = [keys mutableCopy];
    
    [keysM removeObject:@""];
    
    [keysM enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]])
        {
            [helper addToEverSent:obj];
        }
    }];
    
    [[ZZRemoteUnlockedFeaturesUpdater sharedInstance] unlockFeaturesWithMKeys:keys];

}

@end

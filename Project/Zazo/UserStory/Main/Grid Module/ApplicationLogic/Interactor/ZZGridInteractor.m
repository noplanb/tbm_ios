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
#import "ZZSettingsManager.h"
#import "ZZApplicationRootService.h"
#import "ZZMessageDomainModel.h"
#import "ZZThumbnailGenerator.h"

static NSInteger const kGridFriendsCellCount = 8;

@interface ZZGridInteractor ()
        <
        ZZVideoStatusHandlerDelegate,
        ZZRootStateObserverDelegate,
        ZZGridUpdateServiceDelegate,
        MessageEventsObserver,
        FriendsAvatarsServiceDelegate
        >

@property (nonatomic, strong) ZZGridUpdateService *gridUpdateService;
@property (nonatomic, strong) FriendsAvatarsService *avatarsService;


@end

@implementation ZZGridInteractor

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[ZZVideoStatusHandler sharedInstance] addVideoStatusHandlerObserver:self];
        [[ZZRootStateObserver sharedInstance] addRootStateObserver:self];
        [[MessageHandler sharedInstance] addMessageEventsObserver:self];

        self.gridUpdateService = [ZZGridUpdateService new];
        self.gridUpdateService.delegate = self;
        
        self.avatarsService = [FriendsAvatarsService new];
        self.avatarsService.delegate = self;
        [[ZZRootStateObserver sharedInstance] addRootStateObserver:self.avatarsService];
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
    ZZLogDebug(@"addUserToGrid");
    
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
        [self.output updateGridWithModel:gridModel animated:YES];

        ZZFriendDomainModel *fillGapOnGrid = [self _loadFirstFriendFromMenu:[ZZFriendDataProvider allFriendsModels]];
        
        if (!ANIsEmpty(fillGapOnGrid))
        {
            ZZLogDebug(@"Filling a gap");
            [self addUserToGrid:fillGapOnGrid];
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
    ZZLogDebug(@"updateLastActionForFriend: %@", friendModel);

    ANDispatchBlockToBackgroundQueue(^{
        [ZZFriendDataUpdater updateLastTimeActionFriendWithID:friendModel.idTbm];
    });
}


#pragma mark - Update after stoppedVideo

- (void)updateFriendAfterVideoStopped:(ZZFriendDomainModel *)model
{
    ZZGridDomainModel *gridModel = [ZZGridDataProvider modelWithRelatedUserID:model.idTbm];
//    gridModel.isDownloadAnimationViewed = YES;
    [self.output reloadGridModel:gridModel];
    [self updateLastActionForFriend:model];
}

#pragma mark - Edit Friends

- (void)friendWasUpdatedFromEditContacts:(ZZFriendDomainModel *)friendModel toVisible:(BOOL)isVisible
{
    ZZLogDebug(@"friendWasUpdatedFromEditContacts: %@", friendModel.fullName);
    
    if (isVisible)
    {
        ZZGridDomainModel *gridModel = [ZZGridDataProvider loadFirstEmptyGridElement];
        
        if (ANIsEmpty(gridModel))
        {
            gridModel = [ZZGridDataProvider modelWithEarlierLastActionFriend];
        }

        gridModel = [ZZGridDataUpdater updateRelatedUserOnItemID:gridModel.itemID toValue:friendModel];
        
        [self updateLastActionForFriend:gridModel.relatedUser];
        [self.output updateGridWithModel:gridModel animated:YES];
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
    ZZLogEvent(@"add user: %@", friendModel);
    ZZLogDebug(@"from notification = %d", isFromNotification);
    
    BOOL isUserAlreadyOnGrid = [ZZGridDataProvider isRelatedUserOnGridWithID:friendModel.idTbm];
    ZZLogDebug(@"already on grid = %d", isUserAlreadyOnGrid);
    
    if (isUserAlreadyOnGrid)
    {
        ZZGridDomainModel *gridModel = [ZZGridDataProvider modelWithRelatedUserID:friendModel.idTbm];
        gridModel =
            [ZZGridDataUpdater updateRelatedUserOnItemID:gridModel.itemID
                                                 toValue:friendModel];
        [self.output updateGridWithModel:gridModel animated:YES];
        return;
    }
    
    ZZGridDomainModel *gridModel = [ZZGridDataProvider loadFirstEmptyGridElement];
    ZZLogDebug(@"first empty grid model: %@", gridModel);
    ZZGridDomainModel *gridModelToSwap = nil;

    if (ANIsEmpty(gridModel) && !isFromNotification)
    {
        gridModel = [ZZGridDataProvider modelWithEarlierLastActionFriend];
        ZZLogDebug(@"no empty cell, use cell with earliest last action: %@", gridModel);
        NSUInteger indexToReplace = [self.output indexOfBottomMiddleCell];

        if (gridModel.index != indexToReplace)
        {
            NSArray *allGridModels = [ZZGridDataProvider loadAllGridsSortByIndex:YES];
            gridModelToSwap = allGridModels[indexToReplace];
            ZZLogDebug(@"swapping with bottom middle friend: %@", gridModelToSwap);
            ZZFriendDomainModel *friendToSwap = gridModelToSwap.relatedUser;
            
            gridModelToSwap =
                [ZZGridDataUpdater updateRelatedUserOnItemID:gridModelToSwap.itemID
                                                     toValue:friendModel];
            gridModel =
                [ZZGridDataUpdater updateRelatedUserOnItemID:gridModel.itemID
                                                     toValue:friendToSwap];
        }
        else
        {
            ZZLogDebug(@"cell with earliest last action already in bottom middle cell -- no need in swapping");
            gridModel =
                [ZZGridDataUpdater updateRelatedUserOnItemID:gridModel.itemID
                                                     toValue:friendModel];
        }
    }
    else
    {
        ZZLogDebug(@"there are free cell or isFromNotification -- no need in swapping");

        if (ANIsEmpty(gridModel))
        {
            gridModel = [ZZGridDataProvider modelWithEarlierLastActionFriend];
        }
        
        gridModel =
            [ZZGridDataUpdater updateRelatedUserOnItemID:gridModel.itemID
                                                 toValue:friendModel];
    }
    
    [self updateLastActionForFriend:friendModel];
    
    if (gridModelToSwap)
    {
        [self.output updateGridWithModel:gridModelToSwap animated:YES];
        [self.output updateGridWithModel:gridModel animated:NO];
    }
    else
    {
        [self.output updateGridWithModel:gridModel animated:YES];
    }

    
}

- (void)_addUserAsContactToGrid:(ZZContactDomainModel *)contactModel
{
    ZZLogEvent(@"Add friend as contact: %@", contactModel);
    
    contactModel.phones = [ZZPhoneHelper validatePhonesFromContactModel:contactModel];

    if (!ANIsEmpty(contactModel.phones))
    {
        if (ANIsEmpty(contactModel.primaryPhone) ||  (!ANIsEmpty(contactModel.primaryPhone) && contactModel.phones.count > 1))
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
    ZZLogDebug(@"_addFriendFromDrawerToGridWithContact: %@", contactModel.fullName);
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
    ZZLogInfo(@"GridInteractor - videoStatusChangedWithFriendID: %@", friendID);
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

                ZZLogInfo(@"case 1");
                [self _addUserAsFriendToGrid:friendModel fromNotification:YES];
            }
            else
            {
                ZZLogInfo(@"case 2");
                [self _addUserAsFriendToGrid:friendModel fromNotification:YES];
            }
        }
        if (shouldBeVisible)
        {
            ZZLogInfo(@"case 3");
            [self _addUserAsFriendToGrid:friendModel fromNotification:YES];
        }
    }
    else if (!ANIsEmpty(gridModel.relatedUser))
//             && !gridModel.isDownloadAnimationViewed)
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
    ZZLogEvent(@"GridInteractor -- changeContactStatusTypeForFriend: %@ %@", friendModel.fullName, friendModel.mKey);
    
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
        [self.output updateGridWithModel:gridModel animated:YES];
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
    else if(event == ZZRootStateObserverEventFriendAbilitiesChanged)
    {
        if (!ANIsEmpty(notificationObject))
        {
            [self _updatedAbilitiesOfFriend:notificationObject];
        }
    }
}

- (void)_updatedAbilitiesOfFriend:(ZZFriendDomainModel *)friendModel
{
    ZZGridDomainModel *gridModel = [ZZGridDataProvider modelWithRelatedUserID:friendModel.idTbm];
    [self.output reloadGridModel:gridModel];
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
    
    [[ZZSettingsManager sharedInstance] unlockFeaturesWithEverSentCount:keys.count];

}

#pragma mark MessageEventsObserver

- (void)messageStatusChanged:(ZZMessageDomainModel *)messageModel
{
    ZZLogDebug(@"messageStatusChanged: friendID = %@", messageModel.friendID);
    ZZGridDomainModel *gridModel = [ZZGridDataProvider modelWithRelatedUserID:messageModel.friendID];
    
    if (!gridModel)
    {
        ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:messageModel.friendID];
        
        //TODO:
        BOOL shouldBeVisible = [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel];
        
        if (!shouldBeVisible)
        {
            BOOL isUserSendsUsVideo = messageModel.status == ZZMessageStatusNew;

            if (isUserSendsUsVideo)
            {
                ZZFriendshipStatusType status = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friendModel];
                [ZZFriendDataUpdater updateFriendWithID:friendModel.idTbm setConnectionStatus:status];
                
                [[ZZFriendsTransportService changeModelContactStatusForUser:friendModel.mKey
                                                                  toVisible:!shouldBeVisible] subscribeNext:^(NSDictionary *response) {
                }];
                
                ZZLogDebug(@"Case 1");
                [self _addUserAsFriendToGrid:friendModel fromNotification:YES];
            }
        }
        
        if (shouldBeVisible)
        {
            ZZLogDebug(@"Case 2");
            [self _addUserAsFriendToGrid:friendModel fromNotification:YES];
        }
    }
    else if (!ANIsEmpty(gridModel.relatedUser))
//              && !gridModel.isDownloadAnimationViewed)
    {
        [self.output reloadAfterMessageUpdateGridModel:gridModel];
    }

}

#pragma mark ZZThumbnailProvider

- (UIImage *)thumbnailForFriend:(ZZFriendDomainModel *)friendModel
{
    return [self.avatarsService avatarForFriendForFriend: friendModel] ?: [self _videoThumbnailForFriend:friendModel];
}

- (UIImage *)_videoThumbnailForFriend:(ZZFriendDomainModel *)friendModel
{
    NSSortDescriptor *sortDescriptor =
    [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"%K = %@", ZZVideoDomainModelAttributes.status, @(ZZVideoIncomingStatusDownloaded)];
    
    NSArray *videoModels = friendModel.videos;
    
    videoModels = [videoModels filteredArrayUsingPredicate:predicate];
    videoModels = [videoModels sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    ZZVideoDomainModel *lastModel = [videoModels lastObject];
    
    if (![ZZThumbnailGenerator hasThumbForVideo:lastModel])
    {
        [ZZThumbnailGenerator generateThumbVideo:lastModel];
    }
    
    return [ZZThumbnailGenerator lastThumbImageForFriendID :friendModel.idTbm];
}

#pragma mark FriendsAvatarsServiceDelegate

- (void)didDownloadAvatarForFriend:(ZZFriendDomainModel * _Nonnull)friendModel
{
    ZZGridDomainModel *gridModel = [ZZGridDataProvider modelWithRelatedUserID:friendModel.idTbm];
    
    if (gridModel)
    {
        [self.output reloadGridModel:gridModel];
    }
}

@end

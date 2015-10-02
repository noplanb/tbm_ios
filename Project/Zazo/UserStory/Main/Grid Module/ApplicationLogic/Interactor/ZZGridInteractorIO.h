//
//  ZZGridInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridCellViewModel;
@class ZZFriendDomainModel;
@class ANMessageDomainModel;
@class ZZGridDomainModel;
@class ZZContactDomainModel;
@class TBMFriend;

@protocol ZZGridInteractorInput <NSObject>

- (void)loadData;
- (void)addUserToGrid:(id)friendModel;

- (void)userSelectedPrimaryPhoneNumber:(ZZContactDomainModel*)contact;
- (void)inviteUserInApplication:(ZZContactDomainModel*)contact;

- (void)removeUserFromContacts:(ZZFriendDomainModel*)model;
- (void)updateLastActionForFriend:(ZZFriendDomainModel*)friendModel;
- (void)handleNotificationForFriend:(TBMFriend*)friendEntity;

- (void)loadFeedbackModel;
//- (void)showDownloadAnimationForFriend:(TBMFriend*)friend;
- (void)updateFriendAfterVideoStopped:(ZZFriendDomainModel*)model;


@end


@protocol ZZGridInteractorOutput <NSObject>

- (void)dataLoadedWithArray:(NSArray*)data;
- (void)dataLoadingDidFailWithError:(NSError*)error;

- (void)gridAlreadyContainsFriend:(ZZGridDomainModel*)model;
- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel*)model;

- (void)userHasNoValidNumbers:(ZZContactDomainModel*)model;
- (void)userNeedsToPickPrimaryPhone:(ZZContactDomainModel*)model;
- (void)userHasNoAppInstalled:(ZZContactDomainModel*)model;
- (void)friendRecievedFromServer:(ZZFriendDomainModel*)model;

- (void)updateGridWithModel:(ZZGridDomainModel*)model isNewFriend:(BOOL)isNewFriend;
- (void)updateGridWithModelFromNotification:(ZZGridDomainModel*)model isNewFriend:(BOOL)isNewFriend;

- (void)loadedStateUpdatedTo:(BOOL)isLoading;
- (void)addingUserToGridDidFailWithError:(NSError *)error forUser:(ZZContactDomainModel*)contact;
- (void)updateGridWithDownloadAnimationModel:(ZZGridDomainModel*)model;
//- (void)updateGridWithGridDomainModel:(ZZGridDomainModel*)model;
- (void)reloadGridModel:(ZZGridDomainModel*)model;

- (void)reloadGridWithData:(NSArray*)data;

@end
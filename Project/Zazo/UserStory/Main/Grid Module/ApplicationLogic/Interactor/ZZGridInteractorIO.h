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
- (void)showDownloadAniamtionForFriend:(TBMFriend*)friend;


@end


@protocol ZZGridInteractorOutput <NSObject>

- (void)dataLoadedWithArray:(NSArray*)data;
- (void)dataLoadingDidFailWithError:(NSError *)error;
- (void)modelUpdatedWithUserWithModel:(ZZGridDomainModel *)model;
- (void)gridContainedFriend:(ZZFriendDomainModel*)friendModel;
- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel*)model;

- (void)userHasNoValidNumbers:(ZZContactDomainModel*)model;
- (void)userNeedsToPickPrimaryPhone:(ZZContactDomainModel*)contacts;
- (void)userHasNoAppInstalled:(ZZContactDomainModel*)contact;
- (void)friendRecievedFromServer:(ZZFriendDomainModel*)friendModel;

- (void)updateGridWithModel:(ZZGridDomainModel*)model;
- (void)updateGridWithModelFromNotification:(ZZGridDomainModel*)model;

- (void)loadedStateUpdatedTo:(BOOL)isLoading;
- (void)addingUserToGridDidFailWithError:(NSError *)error forUser:(ZZContactDomainModel*)contact;
- (void)updateGridWithDownloadAnimationModel:(ZZGridDomainModel*)model;
@end
//
//  ZZGridInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridActionHandlerEnums.h"

@class ZZGridCellViewModel;
@class ZZFriendDomainModel;
@class ANMessageDomainModel;
@class ZZGridDomainModel;
@class ZZContactDomainModel;
@class TBMFriend;
@class ZZGridDomainModel;

@protocol ZZGridInteractorInput <NSObject>

- (void)loadData;
- (void)addUserToGrid:(id)friendModel;

- (void)userSelectedPrimaryPhoneNumber:(ZZContactDomainModel*)contact;
- (void)inviteUserInApplication:(ZZContactDomainModel*)contact;

- (void)removeUserFromContacts:(ZZFriendDomainModel*)model;
- (void)updateLastActionForFriend:(ZZFriendDomainModel*)friendModel;

- (void)loadFeedbackModel;
- (void)updateFriendAfterVideoStopped:(ZZFriendDomainModel*)model;

- (void)friendWasUpdatedFromEditContacts:(ZZFriendDomainModel*)model toVisible:(BOOL)isVisible;
- (void)reloadDataAfterResetUserData;

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

- (void)loadedStateUpdatedTo:(BOOL)isLoading;
- (void)addingUserToGridDidFailWithError:(NSError *)error forUser:(ZZContactDomainModel*)contact;
- (void)updateGridWithDownloadAnimationModel:(ZZGridDomainModel*)model;
//- (void)updateGridWithGridDomainModel:(ZZGridDomainModel*)model;
- (void)reloadGridModel:(ZZGridDomainModel*)model;
- (void)reloadAfterVideoUpdateGridModel:(ZZGridDomainModel*)model;
- (void)reloadGridWithData:(NSArray*)data;

- (void)reloadGridAfterClearUserDataWithData:(NSArray*)data; // For secret screen option

- (void)updatedFeatureWithFriendMkeys:(NSArray*)friendsMkeys;
- (void)updateSwithCameraFeatureIsEnabled:(BOOL)isEnabled;
- (void)updateFriendThatPrevouslyWasOnGridWithModel:(ZZFriendDomainModel*)model;

@end

@protocol ZZGridInteractorOutputActionHandler <NSObject>

- (NSInteger)friendsNumberOnGrid;
- (void)handleModel:(ZZGridDomainModel*)model withEvent:(ZZGridActionEventType)event;

@end


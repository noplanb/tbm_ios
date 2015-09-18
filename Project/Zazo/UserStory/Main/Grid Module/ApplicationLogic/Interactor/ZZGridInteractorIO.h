//
//  ZZGridInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridCellViewModel, ZZFriendDomainModel, ANMessageDomainModel, ZZGridDomainModel, ZZContactDomainModel, TBMFriend;

@protocol ZZGridInteractorInput <NSObject>

- (void)loadData;
- (void)selectedPlusCellWithModel:(id)model;
- (void)selectedUserWithModel:(id)model;
- (void)loadFeedbackModel;

- (void)userSelectedPhoneNumber:(NSString*)phoneNumber;
- (void)inviteUserThatHasNoAppInstalled;
- (void)addNewFriendToGridModelsArray;

- (void)removeUserFromContacts:(ZZFriendDomainModel*)model;
- (void)updateLastActionForFriend:(ZZFriendDomainModel*)friendModel;
- (void)handleNotificationForFriend:(TBMFriend *)friendEntity;

- (NSUInteger)lastAddedFriendIndex;
- (NSString*)lastAddedFriendName;
@end


@protocol ZZGridInteractorOutput <NSObject>

- (void)dataLoadedWithArray:(NSArray*)data;
- (void)dataLoadingDidFailWithError:(NSError *)error;
- (void)modelUpdatedWithUserWithModel:(ZZGridDomainModel *)model;
- (void)gridContainedFriend:(ZZFriendDomainModel*)friendModel;
- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel*)model;

- (void)userHasNoValidNumbers:(ZZContactDomainModel*)model;
- (void)userHaSeveralValidNumbers:(NSArray*)phoneNumbers;
- (void)userHasNoAppInstalled:(NSString*)firsName;
- (void)friendRecievedFromeServer:(ZZFriendDomainModel*)friendModel;

- (void)updateGridWithModel:(ZZGridDomainModel *)model;
- (void)updateGridWithModelFromNotification:(ZZGridDomainModel *)model;

@end
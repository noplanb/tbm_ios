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

- (void)userSelectedPrimaryPhoneNumber:(ZZContactDomainModel *)contact;

- (void)inviteUserInApplication:(ZZContactDomainModel *)contact;

- (void)removeUserFromContacts:(ZZFriendDomainModel *)model;

- (void)updateLastActionForFriend:(ZZFriendDomainModel *)friendModel;

- (void)updateFriendAfterVideoStopped:(ZZFriendDomainModel *)model;

- (void)friendWasUpdatedFromEditContacts:(ZZFriendDomainModel *)model toVisible:(BOOL)isVisible;

- (void)reloadDataAfterResetUserData;

- (void)updateGridViewModels:(NSArray *)models;

- (void)updateGridIfNeeded;

@end


@protocol ZZGridInteractorOutput <NSObject>

- (void)dataLoadedWithArray:(NSArray *)data;

- (void)dataLoadingDidFailWithError:(NSError *)error;

- (void)gridAlreadyContainsFriend:(ZZGridDomainModel *)model;

- (void)userHasNoValidNumbers:(ZZContactDomainModel *)model;

- (void)userNeedsToPickPrimaryPhone:(ZZContactDomainModel *)model;

- (void)userHasNoAppInstalled:(ZZContactDomainModel *)model;

- (void)friendRecievedFromServer:(ZZFriendDomainModel *)model;

- (void)updateGridWithModel:(ZZGridDomainModel *)model animated:(BOOL)animated;

- (void)loadingStateUpdatedTo:(BOOL)isLoading;

- (void)addingUserToGridDidFailWithError:(NSError *)error forUser:(ZZContactDomainModel *)contact;

- (void)reloadGridModel:(ZZGridDomainModel *)model;

- (void)reloadAfterVideoUpdateGridModel:(ZZGridDomainModel *)model;

- (void)reloadGridWithData:(NSArray *)data;

- (void)reloadGridAfterClearUserDataWithData:(NSArray *)data; // For secret screen option

- (void)updateSwithCameraFeatureIsEnabled:(BOOL)isEnabled;

- (void)updateFriendThatPrevouslyWasOnGridWithModel:(ZZFriendDomainModel *)model;

- (void)updateDownloadProgress:(CGFloat)progree forModel:(ZZFriendDomainModel *)friendModel;

- (void)showAlreadyContainFriend:(ZZFriendDomainModel *)friendModel compeltion:(ANCodeBlock)completion;

- (NSInteger)indexOfBottomMiddleCell;

@end

@protocol ZZGridInteractorOutputActionHandler <NSObject>

- (NSInteger)friendsNumberOnGrid;

- (void)handleModel:(ZZGridDomainModel *)model withEvent:(ZZGridActionEventType)event;

@end


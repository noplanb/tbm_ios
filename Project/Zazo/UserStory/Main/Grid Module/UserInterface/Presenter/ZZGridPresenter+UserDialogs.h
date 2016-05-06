//
//  ZZGridPresenter+UserDialogs.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/29/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridPresenter.h"
#import "ZZInviteType.h"

@interface ZZGridPresenter (UserDialogs)

- (void)_showSendInvitationDialogForUser:(ZZContactDomainModel *)user;

- (void)_showConnectedDialogForModel:(ZZFriendDomainModel *)friendModel;

- (void)_showCantSendSmsErrorForModel:(ZZFriendDomainModel *)friendModel;

- (void)_nudgeUser:(ZZFriendDomainModel *)userModel;

- (void)_showNoValidPhonesDialogFromModel:(ZZContactDomainModel *)model;

- (void)_addingUserToGridDidFailWithError:(NSError *)error forUser:(ZZContactDomainModel *)contact;

- (void)_showChooseNumberDialogForUser:(ZZContactDomainModel *)user;

- (void)_showInvitationFormForModel:(ZZFriendDomainModel *)friendModel isNudge:(BOOL)isNudge;

@end

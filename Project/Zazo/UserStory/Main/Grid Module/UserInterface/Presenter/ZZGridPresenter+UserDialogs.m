//
//  ZZGridPresenter+UserDialogs.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/29/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridPresenter+UserDialogs.h"
#import "ZZGridAlertBuilder.h"
#import "ZZUserDataProvider.h"
#import "ZZFriendDomainModel.h"
#import "ZZContactDomainModel.h"
#import "TBMPhoneUtils.h"
#import "ZZAPIRoutes.h"

@implementation ZZGridPresenter (UserDialogs)

- (void)_showSendInvitationDialogForUser:(ZZContactDomainModel*)user
{
    [ZZGridAlertBuilder showSendInvitationDialogForUser:user.firstName completion:^ {
        [self.interactor inviteUserInApplication:user];
    }];
}

- (void)_showConnectedDialogForModel:(ZZFriendDomainModel*)friendModel
{
    [self.interactor updateLastActionForFriend:friendModel];
    
    [ZZGridAlertBuilder showConnectedDialogForUser:friendModel.firstName completion:^{
        [self.interactor addUserToGrid:friendModel];
    }];
}

- (void)_showSmsDialogForModel:(ZZFriendDomainModel*)friendModel
{
    ANMessageDomainModel* model = [ANMessageDomainModel new];
    NSString* formattedNumber = [TBMPhoneUtils phone:friendModel.mobileNumber withFormat:NBEPhoneNumberFormatE164];
    model.recipients = @[[NSObject an_safeString:formattedNumber]];
    
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    model.message = [NSString stringWithFormat:@"I sent you a message on %@. Get the app: %@%@", appName, kInviteFriendBaseURL, [ZZUserDataProvider authenticatedUser].idTbm];
    
    [self.wireframe presentSMSDialogWithModel:model success:^{
        [self _showConnectedDialogForModel:friendModel];
    } fail:^{
        [self _showCantSendSmsErrorForModel:friendModel];
    }];
}

- (void)_showCantSendSmsErrorForModel:(ZZFriendDomainModel*)friendModel
{
    [ZZGridAlertBuilder showCannotSendSmsErrorToUser:[friendModel fullName] completion:^{
        [self _showConnectedDialogForModel:friendModel];
    }];
}


@end

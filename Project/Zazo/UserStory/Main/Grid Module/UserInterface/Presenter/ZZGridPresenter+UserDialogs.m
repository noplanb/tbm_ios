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
#import "TBMAlertController.h"
#import "TBMTableModal.h"
#import "ZZGridPresenter+ActionHandler.h"
#import "ZZGridDataSource.h"

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
        
        if ([[self dataSource] frindsOnGridNumber] == 1)
        {
            [self _handleRecordHintWithCellViewModel:friendModel];
        }
        else //if ([[self dataSource] frindsOnGridNumber] == 2)
        {
            [self _handleSentWelcomeHintWithFriendDomainModel:friendModel];
        }
    }];
}

- (void)_showSmsDialogForModel:(ZZFriendDomainModel*)friendModel isNudgeAction:(BOOL)isNudge
{
    ANMessageDomainModel* model = [ANMessageDomainModel new];
    NSString* formattedNumber = [TBMPhoneUtils phone:friendModel.mobileNumber withFormat:NBEPhoneNumberFormatE164];
    model.recipients = @[[NSObject an_safeString:formattedNumber]];
    
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    model.message = [NSString stringWithFormat:@"I sent you a message on %@. Get the app: %@%@", appName, kInviteFriendBaseURL, friendModel.cKey];
    
    [self.wireframe presentSMSDialogWithModel:model success:^{
        if (!isNudge)
        {
            [self _showConnectedDialogForModel:friendModel];
        }
        else
        {
            [self _handleSentWelcomeHintWithFriendDomainModel:friendModel];
        }
    } fail:^{
        
        [self _showCantSendSmsErrorForModel:friendModel];
    }];
}

- (void)_showCantSendSmsErrorForModel:(ZZFriendDomainModel*)friendModel
{
    [ZZGridAlertBuilder showCannotSendSmsErrorToUser:[friendModel fullName] completion:^{
        [self _handleSentWelcomeHintWithFriendDomainModel:friendModel];
    }];
}

- (void)_nudgeUser:(ZZFriendDomainModel*)userModel
{
    [ZZGridAlertBuilder showPreNudgeAlertWithFriendFirstName:userModel.firstName completion:^{
        [self _showSmsDialogForModel:userModel isNudgeAction:YES];
    }];
}

- (void)_showNoValidPhonesDialogFromModel:(ZZContactDomainModel*)model
{
    [ZZGridAlertBuilder showNoValidPhonesDialogForUserWithFirstName:model.firstName fullName:model.fullName];
}

- (void)_addingUserToGridDidFailWithError:(NSError *)error forUser:(ZZContactDomainModel*)contact
{
    TBMAlertController *alert = [TBMAlertController badConnectionAlert];
    
    [alert addAction:[SDCAlertAction actionWithTitle:@"Cancel" style:SDCAlertActionStyleRecommended handler:^(SDCAlertAction *action) {
        [alert dismissWithCompletion:nil];
    }]];
    
    
    [alert addAction:[SDCAlertAction actionWithTitle:@"Try Again" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        [self.interactor addUserToGrid:contact];
    }]];
    
    [alert presentWithCompletion:nil];
}

- (void)_showChooseNumberDialogForUser:(ZZContactDomainModel*)user
{
    ANDispatchBlockToMainQueue(^{
        [[TBMTableModal shared] setupViewWithParentView:self.userInterface.view
                                                  title:@"Choose phone number"
                                                contact:user
                                               delegate:(id<TBMTableModalDelegate>)self];
        [[TBMTableModal shared] show];
    });
}


@end

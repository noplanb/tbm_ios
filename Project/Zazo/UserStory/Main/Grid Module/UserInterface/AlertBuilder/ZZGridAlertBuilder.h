//
//  ZZGridAlertBuilder.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/11/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZInviteType.h"

@interface ZZGridAlertBuilder : NSObject

+ (void)showCannotSendSmsErrorToUser:(NSString *)username completion:(ANCodeBlock)completion;

+ (void)showSendInvitationDialogForUser:(NSString *)firsName completion:(void (^)(ZZInviteType inviteType))completion;

+ (void)showConnectedDialogForUser:(NSString *)userName completion:(ANCodeBlock)completion;

+ (void)showAlreadyConnectedDialogForUser:(NSString *)userName completion:(ANCodeBlock)completion;

+ (void)showNoValidPhonesDialogForUserWithFirstName:(NSString *)firstName fullName:(NSString *)fullName;

+ (void)showHintalertWithMessage:(NSString *)message;

+ (void)showPreNudgeAlertWithFriendFirstName:(NSString *)firstName completion:(ANCodeBlock)completion;

+ (void)showInvitationMethodDialogWithText:(NSString *)text completion:(void (^)(ZZInviteType selectedType, NSString *text))competion;

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
        actionButtonTitlte:(NSString *)actionButtonTitle
                    action:(ANCodeBlock)completion;

@end

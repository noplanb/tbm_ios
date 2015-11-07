//
//  ZZGridAlertBuilder.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/11/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@interface ZZGridAlertBuilder : NSObject

+ (void)showOneTouchRecordViewHint;
+ (void)showCannotSendSmsErrorToUser:(NSString*)username completion:(ANCodeBlock)completion;
+ (void)showSendInvitationDialogForUser:(NSString*)firsName completion:(ANCodeBlock)completion;
+ (void)showConnectedDialogForUser:(NSString*)userName completion:(ANCodeBlock)completion;
+ (void)showAlreadyConnectedDialogForUser:(NSString*)userName completion:(ANCodeBlock)completion;
+ (void)showNoValidPhonesDialogForUserWithFirstName:(NSString*)firstName fullName:(NSString*)fullName;
+ (void)showPreNudgeAlertWithFriendFirstName:(NSString*)firstName completion:(ANCodeBlock)completion;
+ (void)showHintalertWithMessage:(NSString*)message;
+ (void)showAlertWithTitle:(NSString*)title
                   message:(NSString*)message
         cancelButtonTitle:(NSString*)cancelButtonTitle
        actionButtonTitlte:(NSString*)actionButtonTitle
                    action:(ANCodeBlock)completion;

@end

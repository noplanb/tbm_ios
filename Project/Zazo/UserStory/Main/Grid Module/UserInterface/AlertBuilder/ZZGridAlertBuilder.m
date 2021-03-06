//
//  ZZGridAlertBuilder.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/11/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridAlertBuilder.h"
#import "ZZAlertBuilder.h"
#import "ZZFriendDomainModel.h"
#import "SDCAlertControllerVisualStyle.h"

typedef NS_ENUM(NSInteger, ZZAlertViewType)
{
    ZZAlertViewTypeNone,
    ZZAlertViewTypeCantSendSms
};

@interface ZZGridAlertBuilder () <UIAlertViewDelegate>

@property (nonatomic, copy) ANCodeBlock completionBlock;

@end

@implementation ZZGridAlertBuilder

+ (void)showCannotSendSmsErrorToUser:(NSString *)username completion:(ANCodeBlock)completion
{
    NSString *format = @"It looks like you can't or didn't send a link by text. Perhaps you can just call or email %@ and tell them about %@.";
    NSString *msg = [NSString stringWithFormat:format, [NSObject an_safeString:username], [self _appName]];

    [ZZAlertBuilder presentAlertWithTitle:@"Didn't Send Link" details:msg cancelButtonTitle:nil actionButtonTitle:@"OK" action:completion];
}

+ (void)showSendInvitationDialogForUser:(NSString *)firsName completion:(void (^)(ZZInviteType inviteType))completion
{
    NSString *msg = [NSString stringWithFormat:@"%@ has not installed %@ yet. Send a link!", firsName, [self _appName]];
    
    UIAlertAction *smsAction =
    [UIAlertAction actionWithTitle:@"Via SMS"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {

                               completion(ZZInviteTypeSMS);
                           }];

    UIAlertAction *sharingAction =
    [UIAlertAction actionWithTitle:@"Via another app"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {
                              completion(ZZInviteTypeSharing);
                           }];

    
    [ZZAlertBuilder presentAlertWithTitle:@"Invite"
                                  details:msg
                        cancelButtonTitle:@"Cancel"
                       cancelButtonAction:nil
                                  actions:@[smsAction, sharingAction]];
    
}

+ (void)showConnectedDialogForUser:(NSString *)userName completion:(ANCodeBlock)completion
{
    userName = [NSObject an_safeString:userName];
    NSString *format = @"You and %@ are connected.\n\nRecord a welcome %@ to %@ now.";
    NSString *msg = [NSString stringWithFormat:format, userName, [self _appName], userName];

    [ZZAlertBuilder presentAlertWithTitle:@"Send a Zazo" details:msg cancelButtonTitle:nil actionButtonTitle:@"OK" action:completion];
}

+ (void)showAlreadyConnectedDialogForUser:(NSString *)userName completion:(ANCodeBlock)completion
{
    userName = [NSObject an_safeString:userName];

    NSString *msg = [NSString stringWithFormat:@"It seems that %@ is already connected with you.\n\nRecord Zazo to %@ now.", userName, userName];
    NSString *title = @"Send a Zazo";
    NSString *actionButtonTitle = @"Ok";

    [ZZAlertBuilder presentAlertWithTitle:title details:msg cancelButtonTitle:nil actionButtonTitle:actionButtonTitle action:completion];
}

+ (void)showNoValidPhonesDialogForUserWithFirstName:(NSString *)firstName fullName:(NSString *)fullName
{
    firstName = [NSObject an_safeString:firstName];
    fullName = [NSObject an_safeString:fullName];
    NSString *title = @"No Mobile Number";
//    NSString *msg = [NSString stringWithFormat:@"I could not find a valid mobile number for %@.\n\nPlease add a mobile number for %@ in your device contacts, kill %@, then try again.", fullName, firstName, [self _appName]];

    NSString *msg = [NSString stringWithFormat:@"I could not find a valid mobile number for %@.\n\nPlease add a mobile number for %@ in your device contacts and try again.", fullName, firstName];

    [ZZAlertBuilder presentAlertWithTitle:title details:msg cancelButtonTitle:@"OK"];
}

+ (void)showPreNudgeAlertWithFriendFirstName:(NSString *)firstName completion:(void (^)(ZZInviteType inviteType))completion
{
    firstName = [NSObject an_safeString:firstName];
    
    NSString *msg = [NSString stringWithFormat:@"%@ still hasn't installed %@.\n Send the link again.", firstName, [self _appName]];
    NSString *title = [NSString stringWithFormat:@"Remind %@", firstName];

    UIAlertAction *smsAction =
    [UIAlertAction actionWithTitle:@"Via SMS"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {
                               
                               completion(ZZInviteTypeSMS);
                           }];
    
    UIAlertAction *sharingAction =
    [UIAlertAction actionWithTitle:@"Via another app"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {
                               completion(ZZInviteTypeSharing);
                           }];
    
    
    [ZZAlertBuilder presentAlertWithTitle:title
                                  details:msg
                        cancelButtonTitle:@"Cancel"
                       cancelButtonAction:nil
                                  actions:@[smsAction, sharingAction]];

}

+ (NSAttributedString *)_boldStringWithText:(NSString *)text
{
    if (ANIsEmpty(text))
    {
        return nil;
    }

    NSDictionary<NSString *, id> *attributes = @{
            NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:20.0f]
    };

    NSAttributedString *result = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    return result;
}

+ (void)showHintalertWithMessage:(NSString *)message
{
    message = [NSObject an_safeString:message];
    [ZZAlertBuilder presentAlertWithTitle:@"Hint" details:message cancelButtonTitle:@"OK"];
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
        actionButtonTitlte:(NSString *)actionButtonTitle
                    action:(ANCodeBlock)completion
{
    [ZZAlertBuilder presentAlertWithTitle:title
                                  details:message
                        cancelButtonTitle:cancelButtonTitle
                        actionButtonTitle:actionButtonTitle
                                   action:completion];
}

//+ (void)showOneTouchRecordViewHint
//{
//    NSString* title = NSLocalizedString(@"hint.record.view.one.touch.title", nil);
//    NSString* message = NSLocalizedString(@"hint.record.view.one.touch.message", nil);
//    NSString* activeButtonTitle = NSLocalizedString(@"hint.record.view.one.touch.button.title", nil);
//    
//    [ZZAlertBuilder presentAlertWithTitle:title
//                                  details:message
//                        cancelButtonTitle:nil
//                        actionButtonTitle:activeButtonTitle
//                                   action:nil];

//}


#pragma mark - UIAlertView part

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case ZZAlertViewTypeCantSendSms:
        {
            if (self.completionBlock)
            {
                self.completionBlock();
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - Private

+ (NSString *)_appName
{
    NSString *appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    return [NSObject an_safeString:appName];
}


@end

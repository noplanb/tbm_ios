//
//  ZZActionSheetController.m
//  Zazo
//
//  Created by ANODA on 9/18/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZActionSheetController.h"
#import "ZZGridActionStoredSettings.h"

@implementation ZZActionSheetController

+ (void)actionSheetWithPresentedView:(UIView*)presentedView
                               frame:(CGRect)frame
                     completionBlock:(void(^)(ZZEditMenuButtonType selectedType))completionBlock;
{
    UIActionSheet* actionSheet = [ZZActionSheetController _currentActionSheet];
    if (IS_IPAD)
    {
        ANDispatchBlockToMainQueue(^{
            [actionSheet showFromRect:frame inView:presentedView animated:YES];
        });
    }
    else
    {
        ANDispatchBlockToMainQueue(^{
            [actionSheet showInView:presentedView];
        });
    }
    
    @weakify(actionSheet);
    [[actionSheet.rac_buttonClickedSignal take:1] subscribeNext:^(NSNumber* x) {
        @strongify(actionSheet);
        
        if (x.integerValue != actionSheet.cancelButtonIndex)
        {
            
            
            if (completionBlock)
            {
                NSInteger buttonType;
                if (![ZZGridActionStoredSettings shared].deleteFriendHintWasShown)
                {
                    buttonType = ZZEditMenuButtonTypeSendFeedback;
                }
                else
                {
                    buttonType = [x integerValue];
                }
                
                completionBlock(buttonType);
            }
        }

    }];
}

+ (UIActionSheet*)_currentActionSheet
{
    NSString *editFriendsButtonTitle = NSLocalizedString(@"grid-controller.menu.edit-friends.button.title", nil);
    NSString *sendFeedbackButtonTitle = NSLocalizedString(@"grid-controller.menu.send-feedback.button.title", nil);
    
    UIActionSheet* actionSheet;

    
    if ([ZZGridActionStoredSettings shared].deleteFriendHintWasShown)
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:nil
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:editFriendsButtonTitle, sendFeedbackButtonTitle, nil];
    }
    else
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:nil
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:sendFeedbackButtonTitle, nil];
    
    }
    return actionSheet;
}

@end

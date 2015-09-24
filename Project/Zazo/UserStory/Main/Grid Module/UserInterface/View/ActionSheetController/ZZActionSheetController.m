//
//  ZZActionSheetController.m
//  Zazo
//
//  Created by ANODA on 9/18/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZActionSheetController.h"
#import "ZZFeatureObserver.h"


@implementation ZZActionSheetController

+ (void)actionSheetWithPresentedView:(UIView*)presentedView
                     completionBlock:(void(^)(ZZEditMenuButtonType selectedType))completionBlock;
{
    UIActionSheet* actionSheet = [ZZActionSheetController _currentActionSheet];
    [actionSheet showInView:presentedView];
    
    @weakify(actionSheet);
    [actionSheet.rac_buttonClickedSignal subscribeNext:^(NSNumber* x) {
        
        @strongify(actionSheet);
        if (x.integerValue != actionSheet.cancelButtonIndex)
        {
            if (completionBlock)
            {
                completionBlock([ZZActionSheetController _selectedWithSelectedIndex:x]);
            }
        }
    }];
}

+ (UIActionSheet*)_currentActionSheet
{
    NSString *editFriendsButtonTitle = NSLocalizedString(@"grid-controller.menu.edit-friends.button.title", nil);
    NSString *sendFeedbackButtonTitle = NSLocalizedString(@"grid-controller.menu.send-feedback.button.title", nil);
    
    
    UIActionSheet* actionSheet;
    

    if (YES) // ([ZZFeatureObserver sharedInstance].isDeleteFriendsEnabled)
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

+ (ZZEditMenuButtonType)_selectedWithSelectedIndex:(NSNumber*)selectedIndex
{
    ZZEditMenuButtonType type;
    
    if (YES) //([ZZFeatureObserver sharedInstance].isDeleteFriendsEnabled)
    {
        type = ZZEditMenuButtonTypeEditFriends;
    }
    else
    {
        type = ZZEditMenuButtonTypeSendFeedback;
    }
    
    return type;
}


@end

//
//  ZZActionSheetController.h
//  Zazo
//
//  Created by ANODA on 9/18/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

typedef NS_ENUM(NSInteger, ZZEditMenuButtonType)
{
    ZZEditMenuButtonTypeEditFriends,
    ZZEditMenuButtonTypeSendFeedback,
    ZZEditMenuButtonTypeCancel,
};

@interface ZZActionSheetController : NSObject

+ (void)actionSheetWithPresentedView:(UIView*)presentedView
                               frame:(CGRect)frame
                     completionBlock:(void(^)(ZZEditMenuButtonType selectedType))completionBlock;

@end

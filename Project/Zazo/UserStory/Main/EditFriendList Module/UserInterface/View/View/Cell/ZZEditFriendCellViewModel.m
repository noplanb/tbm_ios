//
//  ZZEditFriendCellViewModel.m
//  Zazo
//
//  Created by ANODA on 8/25/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

typedef NS_ENUM(NSInteger, ZZContactActionButtonState)
{
    ZZContactActionButtonStateDelete = 0,
    ZZContactActionButtonStateRestore = 1,
};

#import "ZZEditFriendCellViewModel.h"

@implementation ZZEditFriendCellViewModel

#pragma mark - Actions

- (void)deleteAndRestoreButtonSelected
{
    [self.delegate deleteAndRestoreButtonSelectedWithModel:self];
}

- (void)updateDeleteButton:(UIButton *)button
{
    if ([self.item isCreator])
    {
        if (self.item.contactStatusValue == ZZContactStatusTypeEstablished ||
            self.item.contactStatusValue == ZZContactStatusTypeHiddenByCreator)
        {
            [self _updateButton:button toState:ZZContactActionButtonStateDelete];
        }
        else
        {
            [self _updateButton:button toState:ZZContactActionButtonStateRestore];
        }
    }
    else
    {
        if (self.item.contactStatusValue == ZZContactStatusTypeEstablished ||
            ZZContactStatusTypeEstablished == ZZContactStatusTypeHiddenByTarget)
        {
            [self _updateButton:button toState:ZZContactActionButtonStateDelete];
        }
        else
        {
            [self _updateButton:button toState:ZZContactActionButtonStateRestore];
        }
    }
}

- (void)_updateButton:(UIButton *)button toState:(ZZContactActionButtonState)state
{
    if (state == ZZContactActionButtonStateDelete)
    {
        [button setBackgroundColor:[UIColor colorWithRed:0.6 green:0.76 blue:0.22 alpha:1]];
        [button setTitle:NSLocalizedString(@"edit-friend.delete.button.title", nil) forState:UIControlStateNormal];
    }
    else
    {
        [button setBackgroundColor:[UIColor colorWithRed:0.96 green:0.54 blue:0.17 alpha:1]];
        [button setTitle:NSLocalizedString(@"edit-friend.restore.button.title", nil) forState:UIControlStateNormal];
    }
}

- (void)updatePhotoImageView:(UIImageView *)imageView
{
    if (self.item.isHasApp)
    {
        imageView.image = [UIImage imageNamed:@"zazo-type-1x"];
    }
}

- (NSString *)username
{
    return [self.item fullName];
}

- (NSString *)phoneNumber
{
    return [NSObject an_safeString:self.item.mobileNumber];
}

- (UIColor *)cellBackgroundColor
{
    UIColor *cellColor;
    
    if ([self.item isCreator])
    {
        if (self.item.contactStatusValue == ZZContactStatusTypeEstablished ||
            self.item.contactStatusValue == ZZContactStatusTypeHiddenByCreator)
        {
            cellColor = [UIColor an_colorWithHexString:@"EFEFE7"];
        }
        else
        {
            cellColor = [UIColor an_colorWithHexString:@"DAD7CE"];
        }
    }
    else
    {
        if (self.item.contactStatusValue == ZZContactStatusTypeEstablished ||
            ZZContactStatusTypeEstablished == ZZContactStatusTypeHiddenByTarget)
        {
            cellColor = [UIColor an_colorWithHexString:@"EFEFE7"];
        }
        else
        {
            cellColor = [UIColor an_colorWithHexString:@"DAD7CE"];
        }
    }
    
    return cellColor;
}

@end

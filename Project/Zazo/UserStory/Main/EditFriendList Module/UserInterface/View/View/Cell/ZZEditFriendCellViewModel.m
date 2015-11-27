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

static UIImage* kImagePlaceholder = nil;

#import "ZZEditFriendCellViewModel.h"
#import "ZZThumbnailGenerator.h"

@interface ZZEditFriendCellViewModel ()

@property (nonatomic, strong) UIImage* image;

@end

@implementation ZZEditFriendCellViewModel

#pragma mark - Actions

- (void)deleteAndRestoreButtonSelected
{
    [self.delegate deleteAndRestoreButtonSelectedWithModel:self];
}

- (void)updateDeleteButton:(UIButton *)button
{
//    if ([self.item isCreator])
//    {
//        if (self.item.friendshipStatusValue == ZZFriendshipStatusTypeEstablished ||
//            self.item.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByCreator)
//        {
//            [self _updateButton:button toState:ZZContactActionButtonStateDelete];
//        }
//        else
//        {
//            [self _updateButton:button toState:ZZContactActionButtonStateRestore];
//        }
//    }
//    else
//    {
//        if (self.item.friendshipStatusValue == ZZFriendshipStatusTypeEstablished ||
//            self.item.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByTarget)
//        {
//            [self _updateButton:button toState:ZZContactActionButtonStateDelete];
//        }
//        else
//        {
//            [self _updateButton:button toState:ZZContactActionButtonStateRestore];
//        }
//    }
    
    if (self.item.friendshipStatusValue == ZZFriendshipStatusTypeEstablished)
    {
        [self _updateButton:button toState:ZZContactActionButtonStateDelete];
    }
    else
    {
        [self _updateButton:button toState:ZZContactActionButtonStateRestore];
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


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kImagePlaceholder = [UIImage imageNamed:@"zazo_color"];
        });
    }
    return self;
}

- (void)setItem:(id<ZZUserInterface>)item
{
    _item = item;
    
    if (_item.isHasApp)
    {
        UIImage* image = [ZZThumbnailGenerator thumbImageForUser:(id)_item];
        self.image = image ? : kImagePlaceholder;
    }
}


- (void)updatePhotoImageView:(UIImageView*)imageView
{
    imageView.image = self.image;
}

- (NSString*)username
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
        if (self.item.friendshipStatusValue == ZZFriendshipStatusTypeEstablished ||
            self.item.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByCreator)
        {
            cellColor = [UIColor an_colorWithHexString:@"f1efe9"];
        }
        else
        {
            cellColor = [UIColor an_colorWithHexString:@"ddd9ce"];
        }
    }
    else
    {
        if (self.item.friendshipStatusValue == ZZFriendshipStatusTypeEstablished ||
            self.item.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByTarget)
        {
            cellColor = [UIColor an_colorWithHexString:@"f1efe9"];
        }
        else
        {
            cellColor = [UIColor an_colorWithHexString:@"ddd9ce"];
        }
    }
    
    return cellColor;
}

@end

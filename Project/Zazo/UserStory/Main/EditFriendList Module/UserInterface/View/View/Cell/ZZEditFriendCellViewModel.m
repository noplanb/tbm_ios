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
    self.isUpdating = YES;
    [self.delegate deleteAndRestoreButtonSelectedWithModel:self];
}

- (void)updateSwitch:(UISwitch *)aSwitch
{
    aSwitch.enabled = !self.isUpdating;
    
    if ([self.item isCreator])
    {
        if (self.item.friendshipStatusValue == ZZFriendshipStatusTypeEstablished ||
            self.item.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByCreator)
        {
            [self _updateSwitch:aSwitch toState:ZZContactActionButtonStateDelete];
        }
        else
        {
            [self _updateSwitch:aSwitch toState:ZZContactActionButtonStateRestore];
        }
    }
    else
    {
        if (self.item.friendshipStatusValue == ZZFriendshipStatusTypeEstablished ||
            self.item.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByTarget)
        {
            [self _updateSwitch:aSwitch toState:ZZContactActionButtonStateDelete];
        }
        else
        {
            [self _updateSwitch:aSwitch toState:ZZContactActionButtonStateRestore];
        }
    }
}

- (void)_updateSwitch:(UISwitch *)aSwitch toState:(ZZContactActionButtonState)state
{
    [aSwitch setOn:state animated:NO];
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
            cellColor = [UIColor an_colorWithHexString:@"ffffff"];
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
            cellColor = [UIColor an_colorWithHexString:@"ffffff"];
        }
        else
        {
            cellColor = [UIColor an_colorWithHexString:@"ddd9ce"];
        }
    }
    
    return cellColor;
}

@end

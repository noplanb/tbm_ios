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
#import "ZZThumbnailGenerator.h"
#import "ZZUserPresentationHelper.h"

@interface ZZEditFriendCellViewModel ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong, readonly) UIImage *placeholderImage;
@property (nonatomic, strong, readonly) ZZColorPair *colorPair;

@end

@implementation ZZEditFriendCellViewModel

#pragma mark - Actions

- (void)switchStateChanged
{
    self.isUpdating = YES;
    [self.delegate switchValueChangedWithModel:self];
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
    [aSwitch setOn:!state animated:NO];
}

- (void)setItem:(id <ZZUserInterface>)item
{
    _item = item;

    if (_item.isHasApp)
    {
        self.image = [ZZThumbnailGenerator thumbImageForUser:(id)_item];
    }
}

- (void)updatePhotoImageView:(UIImageView *)imageView
{
    imageView.image = self.image ?: self.placeholderImage;
    imageView.backgroundColor = self.colorPair.backgroundColor;
    imageView.tintColor = self.colorPair.tintColor;
}

- (NSString *)username
{
    return [self.item fullName];
}

- (NSString *)abbreviation
{
    if (!self.image)
    {
        return [ZZUserPresentationHelper abbreviationWithFullname:self.username];
    }

    return nil;
}

@synthesize colorPair = _colorPair;

- (ZZColorPair *)colorPair
{
    if (!_colorPair)
    {
        _colorPair = [ZZColorPair randomPair];
    }

    return _colorPair;
}

@synthesize placeholderImage = _placeholderImage;

- (UIImage *)placeholderImage
{
    if (!_placeholderImage)
    {
        _placeholderImage = [ZZThumbnailGenerator thumbnailPlaceholderImageForName:self.username];
    }

    return _placeholderImage;
}

- (NSString *)phoneNumber
{
    return [NSObject an_safeString:self.item.mobileNumber];
}

@end

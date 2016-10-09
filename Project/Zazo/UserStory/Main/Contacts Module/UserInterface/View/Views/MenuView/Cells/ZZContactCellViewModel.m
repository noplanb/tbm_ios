//
//  ZZContactCellViewModel.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactCellViewModel.h"
#import "ZZUserPresentationHelper.h"
#import "ZZThumbnailGenerator.h"
#import "ZZFriendDomainModel.h"
#import "ZZFriendDataProvider.h"

static UIImage *kImagePlaceholder = nil;

@interface ZZContactCellViewModel ()

@property (nonatomic, strong, readwrite) NSString *abbreviation;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong, readonly) UIImage *placeholderImage;
@property (nonatomic, strong, readonly) ZZColorPair *colorPair;

@end

@implementation ZZContactCellViewModel

+ (instancetype)viewModelWithItem:(id <ZZUserInterface>)item
{
    ZZContactCellViewModel *model = [self new];
    model.item = item;

    return model;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.username=%@", self.username];
    [description appendString:@">"];
    return description;
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kImagePlaceholder = [UIImage imageNamed:@"icon-no-pic"];
        });
    }
    return self;
}

- (void)setItem:(id <ZZUserInterface>)item
{
    _item = item;
    self.username = [ZZUserPresentationHelper fullNameWithFirstName:[_item firstName] lastName:[_item lastName]];

    self.image = [item thumbnail];

    if (!self.image && [_item isKindOfClass:[ZZFriendDomainModel class]])
    {
        ZZFriendDomainModel *friendModel = (id)item;

        if (friendModel.isHasApp)
        {
            self.image = [ZZFriendDataProvider avatarOfFriendWithID:friendModel.idTbm] ?: [ZZThumbnailGenerator thumbImageForUser:(id)_item];
        }
    }

    if (!self.image)
    {
        self.abbreviation = [ZZUserPresentationHelper abbreviationWithFullname:self.username];
    }
}

- (void)updateImageView:(UIImageView *)imageView
{
    UIImage *image = self.image;

    if (!image)
    {
        image = self.placeholderImage;
        imageView.backgroundColor = self.colorPair.backgroundColor;
        imageView.tintColor = self.colorPair.tintColor;
    }

    imageView.image = image;
}

@synthesize colorPair = _colorPair;

- (ZZColorPair *)colorPair
{
    if (!_colorPair)
    {
        _colorPair = [ZZColorPair colorForUsername:self.username];
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

@end

//
//  ZZMenuCellViewModel.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuCellViewModel.h"
#import "NSString+ZZAdditions.h"
#import "ZZUserPresentationHelper.h"
#import "ZZThumbnailGenerator.h"

static UIImage* kImagePlaceholder = nil;

@interface ZZMenuCellViewModel ()

@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) UIImage* image;

@end

@implementation ZZMenuCellViewModel

+ (instancetype)viewModelWithItem:(id<ZZUserInterface>)item
{
    ZZMenuCellViewModel* model = [self new];
    model.item = item;
    
    return model;
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

- (void)setItem:(id<ZZUserInterface>)item
{
    _item = item;
    self.username = [ZZUserPresentationHelper fullNameWithFirstName:[_item firstName] lastName:[_item lastName]];
    if ([_item contactType] == ZZMenuContactTypeAddressbook)
    {
        self.image = nil;
    }
    else
    {
        UIImage* image = [ZZThumbnailGenerator thumbImageForUser:(id)_item];
        self.image = image ? : kImagePlaceholder;
    }
}

- (void)updateImageView:(UIImageView*)imageView
{
    imageView.image = self.image;
}

@end

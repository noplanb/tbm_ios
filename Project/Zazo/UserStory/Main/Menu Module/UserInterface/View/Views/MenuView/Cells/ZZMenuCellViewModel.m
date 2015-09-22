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

- (void)setItem:(id<ZZUserInterface>)item
{
    _item = item;
    self.username = [ZZUserPresentationHelper fullNameWithFirstName:[self.item firstName] lastName:[self.item lastName]];
    if ([self.item contactType] == ZZMenuContactTypeAddressbook)
    {
        self.image = nil;
    }
    else
    {
        self.image = [ZZThumbnailGenerator thumbImageForUser:(id)self.item];
    }
}

- (void)updateImageView:(UIImageView*)imageView
{
    imageView.image = self.image;
}

@end

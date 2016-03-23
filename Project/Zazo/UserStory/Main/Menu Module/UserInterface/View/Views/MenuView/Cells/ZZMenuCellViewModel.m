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

@property (nonatomic, strong, readwrite) NSString *abbreviation;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *placeholderImageName;

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
        self.image = [item thumbnail];
        
        if (!self.image)
        {
            self.abbreviation = [ZZUserPresentationHelper abbreviationWithFullname:self.username];
        }
    }
    else
    {
        UIImage* image = [ZZThumbnailGenerator thumbImageForUser:(id)_item];
        self.image = image ? : kImagePlaceholder;
    }
}

- (void)updateImageView:(UIImageView*)imageView
{
    UIImage *image = self.image;
    
    if (!image)
    {
        image = [[UIImage imageNamed:self.placeholderImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        ZZColorPair *pair = [ZZColorPair randomPair];
        imageView.backgroundColor = pair.backgroundColor;
        imageView.tintColor = pair.tintColor;
    }

    imageView.image = image;
    
}

- (NSString *)placeholderImageName
{
    if (!_placeholderImageName)
    {
        NSUInteger number = arc4random_uniform(4)+1;
        _placeholderImageName = [NSString stringWithFormat:@"contact-pattern-%lu", (unsigned long)number];
        
    }
    
    return _placeholderImageName;
}

@end

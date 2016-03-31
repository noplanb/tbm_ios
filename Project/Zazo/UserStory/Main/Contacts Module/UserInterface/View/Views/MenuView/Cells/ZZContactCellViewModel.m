//
//  ZZContactCellViewModel.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactCellViewModel.h"
#import "NSString+ZZAdditions.h"
#import "ZZUserPresentationHelper.h"
#import "ZZThumbnailGenerator.h"

static UIImage* kImagePlaceholder = nil;

@interface ZZContactCellViewModel ()

@property (nonatomic, strong, readwrite) NSString *abbreviation;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *placeholderImageName;
@property (nonatomic, strong, readonly) ZZColorPair *colorPair;

@end

@implementation ZZContactCellViewModel

+ (instancetype)viewModelWithItem:(id<ZZUserInterface>)item
{
    ZZContactCellViewModel * model = [self new];
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
    
    self.image = [item thumbnail];
    
    if (!self.image)
    {
        self.abbreviation = [ZZUserPresentationHelper abbreviationWithFullname:self.username];
    }
}

- (void)updateImageView:(UIImageView*)imageView
{
    UIImage *image = self.image;
    
    if (!image)
    {
        image = [[UIImage imageNamed:self.placeholderImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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
        _colorPair = [ZZColorPair randomPair];
    }
    
    return _colorPair;
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

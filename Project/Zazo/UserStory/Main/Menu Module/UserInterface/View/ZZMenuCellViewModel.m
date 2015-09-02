//
//  ZZMenuCellViewModel.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuCellViewModel.h"
#import "NSString+ZZAdditions.h"

@interface ZZMenuCellViewModel ()

@end

@implementation ZZMenuCellViewModel

+ (instancetype)viewModelWithItem:(id<ZZUserInterface>)item
{
    ZZMenuCellViewModel* model = [self new];
    model.item = item;
    
    return model;
}

- (NSString *)username
{
    NSString* firstName = [self.item firstName].length > 0 ? [self.item firstName] : @"";
    NSString* lastName = [self.item lastName].length > 0 ? [self.item lastName] : @"";
    
    NSString *name = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    return name; // TODO;
}

- (void)updateImageView:(UIImageView *)imageView
{
    if (self.item.hasApp)
    {
        imageView.image = [self _zazoImage];
    }
    else
    {
        UIImage* photo = [self.item photoImage];
        
        if (photo)
        {
            imageView.image = photo; // TODO: load from cache
        }
        else
        {
            imageView.image = [self _placeHolderImage];
        }
    }
}

#pragma mark - Private

- (UIImage *)_placeHolderImage
{
    UIImage* placeholder = [UIImage imageWithPDFNamed:@"Contacts-plaiceholder-men" atHeight:36.f];
    
    return [placeholder an_imageByTintingWithColor:[UIColor an_colorWithHexString:@"625f57"]];
}

-(UIImage *)_zazoImage
{
    UIImage* zazoImage = [UIImage imageWithPDFNamed:@"icon_zazo" atHeight:36.f];
    
    return [zazoImage an_imageByTintingWithColor:[UIColor an_colorWithHexString:@"625f57"]];
}

@end

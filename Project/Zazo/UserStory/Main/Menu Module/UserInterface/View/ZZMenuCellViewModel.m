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
    // TODO:
}

@end

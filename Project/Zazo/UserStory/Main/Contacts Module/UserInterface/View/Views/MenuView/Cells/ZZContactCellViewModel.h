//
//  ZZContactCellViewModel.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZUserInterface.h"

@interface ZZContactCellViewModel : NSObject

@property (nonatomic, strong) id <ZZUserInterface> item;

+ (instancetype)viewModelWithItem:(id <ZZUserInterface>)item;

@property (nonatomic, strong, readonly) NSString *abbreviation;

- (NSString *)username;

- (void)updateImageView:(UIImageView *)imageView;

@end

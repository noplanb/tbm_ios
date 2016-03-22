//
//  ZZUserInterface.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuEnumsAdditions.h"

@protocol ZZUserInterface <NSObject>

- (NSString*)firstName;
- (NSString*)lastName;
- (BOOL)hasApp;
- (ZZMenuContactType)contactType;
- (UIImage *)thumbnail;

@end

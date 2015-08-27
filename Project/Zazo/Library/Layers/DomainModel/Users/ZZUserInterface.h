//
//  ZZUserInterface.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZUserInterface <NSObject>

- (NSString*)firstName;
- (NSString*)lastName;
- (NSString*)photoURLString;
- (UIImage *)photoImage; // TODO; temp

@end

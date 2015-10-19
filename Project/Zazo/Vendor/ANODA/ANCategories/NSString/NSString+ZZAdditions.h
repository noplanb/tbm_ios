//
//  NSString+ANAdditions.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface NSString (ZZAdditions)

+ (NSString*)an_concatenateString:(NSString*)firstString withString:(NSString*)endString delimenter:(NSString*)string;

- (NSString*)an_md5;

@end

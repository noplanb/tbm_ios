//
// Created by Rinat on 13/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ZZCacheCleaner : NSObject

+ (void)setNeedsCacheCleaning;

+ (void)cleanIfNeeded;

@end
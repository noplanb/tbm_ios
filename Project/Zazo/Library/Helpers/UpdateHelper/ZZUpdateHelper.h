//
// Created by Rinat on 29/04/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZZUpdateHelper;

@interface ZZUpdateHelper : NSObject

+ (instancetype)shared;

- (void)checkForUpdates;

@end
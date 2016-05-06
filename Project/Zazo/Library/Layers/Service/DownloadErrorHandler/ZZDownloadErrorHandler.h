//
// Created by Rinat on 09/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZVideoStatusHandler.h"

@class ZZVideoFileHandler;

// Handles permanent download errors

// 1. Observes video state changes when app in foreground
// 2. Finds failed videos when become foreground
// 3. Finds failed videos when app launched

// If "state = permanent error" then shows dialog "try again?"
// If "yes" then "repeats download"
// If "no" then deletes video (deletion means setting ghost state)

// Both decisions will be applied to all videos currently failed to download

@interface ZZDownloadErrorHandler : NSObject

- (void)startService;

@property (nonatomic, strong) ZZVideoFileHandler *videoFileHandler;

@end
//
//  TBMDownloadManager.m
//  tbm
//
//  Created by Sani Elfishawy on 5/14/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMDownloadManagerDeprecated.h"

@implementation TBMDownloadManagerDeprecated

//--------------
// Instantiation
//--------------
- (instancetype)init{
    self = [super init];
    if (self){
        super.transferType = TBM_FILE_TRANSFER_TYPE_DOWNLOAD;
        super.transferTypeString = @"Download";
    }
    return self;
}

+ (instancetype)sharedManager{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TBMDownloadManagerDeprecated alloc] init];
        if (!instance){
            DebugLog(@"init: ERROR: got nil for instance on init. This should never happen!");
        }
    });
    return instance;
}

@end

//
//  TBMFileTransferManger.h
//  tbm
//
//  Created by Sani Elfishawy on 5/13/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBMFileTransferManger : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

typedef NS_ENUM (NSInteger, TBMFileTransferType) {
    TBM_FILE_TRANSFER_TYPE_UPLOAD,
    TBM_FILE_TRANSFER_TYPE_DOWNLOAD
};

@property UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property TBMFileTransferType transferType;
@property NSString *transferTypeString;

- (NSString *)sessionIdentifier;
- (void) fileTransferWithFriendId:(NSString *)friendId;
- (void) restartTasksPendingRetry;


@end

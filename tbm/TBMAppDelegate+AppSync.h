//
//  TBMAppDelegate+AppSync.h
//  tbm
//
//  Created by Sani Elfishawy on 8/11/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate.h"
#import "OBFileTransferManager.h"
#import "TBMFriend.h"

@interface TBMAppDelegate (AppSync) <OBFileTransferDelegate>

@property (strong, nonatomic) OBFileTransferManager *fileTransferManager;

// Upload download events
- (void) uploadWithFriendId:(NSString *)friendId;
- (void) queueDownloadWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId;
- (void) retryPendingFileTransfers;

// Polling
- (void) pollAllFriends;
@end

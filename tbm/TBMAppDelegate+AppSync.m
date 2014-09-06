//
//  TBMAppDelegate+AppSync.m
//  tbm
//
//  Created by Sani Elfishawy on 8/11/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate+AppSync.h"
#import <objc/runtime.h>
#import "TBMAppDelegate+PushNotification.h"
#import "TBMConfig.h"
#import "TBMVideoRecorder.h"
#import "TBMRemoteStorageHandler.h"
#import "TBMVideo.h"
#import "TBMVideoIdUtils.h"
#import "TBMVideoPlayer.h"

@implementation TBMAppDelegate (AppSync)


//----------------------------------------
// FileTransfer setup, upload and download
//----------------------------------------
- (OBFileTransferManager *)fileTransferManager{
    OBFileTransferManager *ftm = objc_getAssociatedObject(self, @selector(fileTransferManager));
    if (ftm == nil){
        ftm = [OBFileTransferManager instance];
        ftm.delegate = self;
        ftm.downloadDirectory = [TBMConfig videosDirectoryUrl].path;
        ftm.remoteUrlBase = CONFIG_SERVER_BASE_URL_STRING;
        ftm.maxAttempts = 0;
        [self setFileTransferManager:ftm];
    }
    return ftm;
}

- (void) setFileTransferManager:(OBFileTransferManager *)ftm{
    objc_setAssociatedObject(self, @selector(fileTransferManager), ftm, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSTimeInterval) retryTimeoutValue: (NSUInteger)retryAttempt{
    if (retryAttempt > 7)
        return (NSTimeInterval)128;
    else
        return (NSTimeInterval)(1<<(retryAttempt-1));
}


- (void) uploadWithFriendId:(NSString *)friendId{
    TBMFriend *friend = [TBMFriend findWithId:friendId];
    NSString *localFilePath = [TBMVideoRecorder outgoingVideoUrlWithMarker:friendId].path;
    NSString *marker = [TBMVideoIdUtils markerWithFriend:friend videoId:friend.outgoingVideoId isUpload: YES];
    OB_INFO(@"uploadWithFriendId marker = %@", marker);
    
    [[self fileTransferManager]
     uploadFile:localFilePath
     to:REMOTE_STORAGE_VIDEO_UPLOAD_PATH
     withMarker:marker
     withParams:@{@"filename": [TBMRemoteStorageHandler outgoingVideoRemoteFilename:friend]}];
    
    [friend handleAfterOUtgoingVideoUploadStarted];
}

- (void)queueDownloadWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId{
//    Removed because IOS sends the vidoes out in parallel a later short one may arrive before an earlier long one.
//    if ([TBMVideoIdUtils isvid1:videoId olderThanVid2:[friend oldestIncomingVideo].videoId]) {
//        OB_WARN(@"queueVideoDownloadWithFriend: Ignoring incoming video older than oldest.");
//        return;
//    }
    
    if ([friend hasIncomingVideoId:videoId]){
        OB_WARN(@"queueVideoDownloadWithFriend: Ignoring incoming videoId already processed.");
        return;
    }
    OB_INFO(@"queueVideoDownloadWithFriend:");

    TBMVideo *video = [friend createIncomingVideoWithVideoId:videoId];
    [friend setAndNotifyIncomingVideoStatus:INCOMING_VIDEO_STATUS_DOWNLOADING video:video];
    [self setBadgeNumberUnviewed];
    
    NSString *marker = [TBMVideoIdUtils markerWithFriend:friend videoId:videoId isUpload:NO];
    
    [[self fileTransferManager]
     downloadFile: REMOTE_STORAGE_VIDEO_DOWNLOAD_PATH
     to:[video videoPath]
     withMarker: marker
     withParams:@{@"filename": [TBMRemoteStorageHandler incomingVideoRemoteFilename:video]}];
}

- (void) retryPendingFileTransfers{
    [[self fileTransferManager] retryPending];
}

//--------
// Polling
//--------
- (void) pollAllFriends{
    OB_INFO(@"pollAllFriends");
    for (TBMFriend *f in [TBMFriend all]){
        [self pollWithFriend:f];
    }
}

- (void) pollWithFriend:(TBMFriend *)friend{
    [TBMRemoteStorageHandler getRemoteIncomingVideoIdsWithFriend:friend gotVideoIds:^(NSArray *videoIds) {
        DebugLog(@"pollWithFriend: %@  vids = %@", friend.firstName, videoIds);
        for (NSString *videoId in videoIds){
//            Removed because IOS sends the vidoes out in parallel a later short one may arrive before an earlier long one.
//            if ([TBMVideoIdUtils isvid1:videoId olderThanVid2:[friend oldestIncomingVideoId]]) {
//                OB_WARN(@"pollWithFriend: Deleting remote video and videoId kv older than local oldest.");
//                [TBMRemoteStorageHandler deleteRemoteFileAndVideoIdWithFriend:friend videoId:videoId];
//            }
            [self queueDownloadWithFriend:friend videoId:videoId];
        }
    }];
}

//-------------------------------
// FileTransferDelegate callbacks
//-------------------------------

- (void) fileTransferCompleted:(NSString *)marker withError:(NSError *)error{
    OB_INFO(@"fileTransferCompleted marker = %@", marker);
    [self requestBackground];
    TBMFriend *friend = [TBMVideoIdUtils friendWithMarker:marker];
    NSString *videoId = [TBMVideoIdUtils videoIdWithMarker:marker];
    if (friend == nil){
        OB_ERROR(@"fileTransferCompleted - Could not find friend with marker = %@.", marker);
        return;
    }
    BOOL isUpload = [TBMVideoIdUtils isUploadWithMarker:marker];
    if (isUpload){
        [self uploadCompletedWithFriend:friend videoId:videoId error:error];
    } else {
        [self downloadCompletedWithFriend:friend videoId:videoId error:error];
    }
}

- (void) fileTransferProgress:(NSString *)marker percent:(NSUInteger)progress{
    
}

- (void) fileTransferRetrying:(NSString *)marker attemptCount:(NSInteger)attemptCount withError:(NSError *)error{
    OB_INFO(@"fileTransferRetrying");
    [self requestBackground];
    TBMFriend *friend = [TBMVideoIdUtils friendWithMarker:marker];
    NSString *videoId = [TBMVideoIdUtils videoIdWithMarker:marker];

    BOOL isUpload = [TBMVideoIdUtils isUploadWithMarker:marker];
    if (isUpload){
        [self uploadRetryingWithFriend:friend videoId:videoId retryCount:attemptCount];
    } else {
        [self downloadRetryingWithFriend:friend videoId:videoId retryCount:attemptCount];
    }
}

//--------------
// Upload events
//--------------
- (void) uploadCompletedWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId error:(NSError *)error{
    if (friend == nil){
        OB_ERROR(@"uploadCompletedWithFriend - Could not find friend with marker.");
        return;
    }
    if (error == nil){
        OB_INFO(@"uploadCompletedWithFriend");
        [friend  setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_UPLOADED videoId:videoId];
        [TBMRemoteStorageHandler addRemoteOutgoingVideoId:videoId friend:friend];
        [self sendNotificationForVideoReceived:friend videoId:videoId];
    } else {
        OB_ERROR(@"uploadCompletedWithVideoId: upload error. Setting status to FailedPermanently");
        [friend setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY videoId:videoId];
    }
}

- (void) uploadRetryingWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId retryCount:(NSInteger)retryCount{
    OB_INFO(@"uploadRetryingWithFriend retryCount=%ld", (long)retryCount);
    if (friend == nil){
        OB_ERROR(@"uploadRetryingWithFriend - Could not find friend with marker");
        return;
    }
    
    NSNumber *ncount = [NSNumber numberWithInteger:retryCount];
    [friend setAndNotifyUploadRetryCount:ncount videoId:videoId];
}


//----------------
// Download events
//----------------
- (void) downloadCompletedWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId error:(NSError *)error{
    TBMVideo *video = [TBMVideo findWithVideoId:videoId];
    if (video == nil){
        OB_ERROR(@"downloadCompletedWithFriend: ERROR: unrecognized videoId");
        return;
    }
    
    [TBMRemoteStorageHandler deleteRemoteFileAndVideoIdWithFriend:friend videoId:videoId];
    
    if (error != nil){
        [friend setAndNotifyIncomingVideoStatus:INCOMING_VIDEO_STATUS_FAILED_PERMANENTLY video:video];
    } else {
        if (! [[TBMVideoPlayer findWithFriendId:friend.idTbm] isPlaying])
            [friend deleteAllViewedVideos];
        
        [video generateThumb];
        
        [friend setAndNotifyIncomingVideoStatus:INCOMING_VIDEO_STATUS_DOWNLOADED video:video];
        [TBMRemoteStorageHandler setRemoteIncomingVideoStatus:REMOTE_STORAGE_STATUS_DOWNLOADED videoId:videoId friend:friend];
        [self sendNotificationForVideoStatusUpdate:friend videoId:videoId status:NOTIFICATION_STATUS_DOWNLOADED];
    }
    OB_INFO(@"downloadCompletedWithFriend: Video count = %ld", (unsigned long)[TBMVideo count]);
}


- (void) downloadRetryingWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId retryCount:(NSInteger)retryCount{
    TBMVideo *video = [TBMVideo findWithVideoId:videoId];
    
    if (video == nil){
        OB_ERROR(@"downloadRetryingWithFriend: ERROR: unrecognized videoId");
        return;
    }
    NSNumber *ncount = [NSNumber numberWithInteger:retryCount];
    OB_INFO(@"downloadRetryingWithFriend %@ retryCount= %@", friend.firstName, ncount);
    [friend setAndNotifyDownloadRetryCount:ncount video:video];
}


//---------------------
// HandleStuckDownloads
//---------------------
- (void) handleStuckDownloadsWithCompletionHandler:(void (^)())handler{
    [[self fileTransferManager] currentTransferStateWithCompletionHandler:^(NSArray *allStates){
        OB_DEBUG(@"handleStuckDownloads:");
        for(TBMVideo *video in [TBMVideo downloading]){
            if ([self isStuckWithVideo:video allStates:allStates]){
                [self restartDownloadWithVideo:video];
            }
        }
        handler();
    }];
}

- (BOOL) isStuckWithVideo:(TBMVideo *)video allStates:(NSArray *)allStates{
    NSDictionary *state = [self fileTransferStateWithVideo:video isUpload:NO allStates:allStates];
    if (state == nil) {
        OB_WARN(@"AppSync: isStuckWithVideo: got no FTM state for video: %@", video);
        return NO;
    }
    NSDate *createdOn = [state objectForKey:OBFTMCreatedOnKey];
    NSNumber *bytesReceived = state[OBFTMCountOfBytesReceivedKey];
    NSTimeInterval age = -[createdOn timeIntervalSinceNow];
    OB_DEBUG(@"isStuckWithVideo: age=%f, bytesReceived=%@", age, bytesReceived);
    if (age > 0.25 && [bytesReceived isEqualToNumber: [NSNumber numberWithInt:0]]){
        OB_DEBUG(@"isStuckWithVideo: %@ = YES", video.videoId);
        return YES;
    } else {
        OB_DEBUG(@"isStuckWithVideo: %@ = NO", video.videoId);
        return NO;
    }
}

- (void) restartDownloadWithVideo:(TBMVideo *)video{
    NSString *marker = [TBMVideoIdUtils markerWithVideo:video isUpload:NO];
    [[self fileTransferManager] restartTransferWithMarker:marker onComplete:nil];
}

- (NSDictionary *)fileTransferStateWithVideo:(TBMVideo *)video isUpload:(BOOL)isUpload allStates:(NSArray *)allStates{
    NSString *marker = [TBMVideoIdUtils markerWithVideo:video isUpload:isUpload];
    OB_DEBUG(@"fileTransferStateWithVideo: Looking for: %@", marker);
    for (NSDictionary *d in allStates){
        NSString *dMarker = [d objectForKey:OBFTMMarkerKey ];
        if ([dMarker isEqualToString:marker])
            return d;
    }
    return nil;
}



@end

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
    [self queueDownloadWithFriend:friend videoId:videoId force:NO];
}

- (void)queueDownloadWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId force:(BOOL)force{
//    Removed because IOS sends the vidoes out in parallel a later short one may arrive before an earlier long one.
//    if ([TBMVideoIdUtils isvid1:videoId olderThanVid2:[friend oldestIncomingVideo].videoId]) {
//        OB_WARN(@"queueVideoDownloadWithFriend: Ignoring incoming video older than oldest.");
//        return;
//    }
    
    if ([friend hasIncomingVideoId:videoId] && !force){
        OB_WARN(@"queueVideoDownloadWithFriend: Ignoring incoming videoId already processed.");
        return;
    }
    
    TBMVideo *video;
    if ([friend hasIncomingVideoId:videoId] && force){
        OB_INFO(@"queueVideoDownloadWithFriend: Forcing new transfer of existing video: %@", videoId);
        video = [TBMVideo findWithVideoId:videoId];
    } else {
        OB_INFO(@"queueVideoDownloadWithFriend: Creating new video for download: %@", videoId);
        video = [friend createIncomingVideoWithVideoId:videoId];
    }
    
    if (video == nil){
        OB_ERROR(@"queueVideoDownloadWithFriend: Video is nil. This should never happen.");
        return;
    }

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
    // Run on the main queue since managed object context is on the main queue and you cant pass the resutant objects between threads.
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
}

- (void) fileTransferProgress:(NSString *)marker percent:(NSUInteger)progress{
    
}

- (void) fileTransferRetrying:(NSString *)marker attemptCount:(NSInteger)attemptCount withError:(NSError *)error{
    // Run on the main queue since managed object context is on the main queue and you cant pass the resutant objects between threads.
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
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
            [friend deleteAllViewedOrFailedVideos];
        
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
//
//  obInfo                      transferInfo
//  ------                      ------------
//  nil		                    x                    queue download again
//  status_retry                x                    do nothing
//  !status_retry               nil                  restartDownload
//  !nil                        bytes==0             restartDownload
//

- (void) handleStuckDownloadsWithCompletionHandler:(void (^)())handler{
    NSArray *allObInfo = [[self fileTransferManager] currentState];
    [[self fileTransferManager] currentTransferStateWithCompletionHandler:^(NSArray *allTransferInfo){
        OB_INFO(@"handleStuckDownloads: (%lu)", (unsigned long)[TBMVideo downloadingCount]);
        for(TBMVideo *video in [TBMVideo downloading]){
            NSDictionary *obInfo = [self infoWithVideo:video isUpload:NO allInfo:allObInfo];
            NSDictionary *transferInfo = [self infoWithVideo:video isUpload:NO allInfo:allTransferInfo];
            
            if (obInfo == nil){
                OB_WARN(@"AppSync.handleStuckDownloads: Got no obInfo for vid:%@ double checking to make sure hasnt completed.", video.videoId);
                if ([video isStatusDownloading]){
                    OB_ERROR(@"AppSync.handleStuckDownloads: Got no obInfo for vid:%@ this should not happen. Force requeue the video.", video.videoId);
                    [self queueDownloadWithFriend:video.friend videoId:video.videoId force:YES];
                }
                
            } else if ([self isPendingRetryWithObInfo:obInfo]){
                OB_INFO(@"AppSync.handleStuckDownloads: Ignoring video pending retry: %@.", video.videoId);

            } else if (![self isPendingRetryWithObInfo:obInfo] && transferInfo == nil){
                OB_WARN(@"AppSync.handleStuckDownloads: Got no transferInfo for vid:%@ could be due to termination by user during download. Restarting the task.", video.videoId);
                [self restartDownloadWithVideo:video];
                
            } else if ([self transferTaskStuckWithTransferInfo:transferInfo]){
                OB_WARN(@"AppSync.handleStuckDownloads: Restarting stuck download: %@.", video.videoId);
                [self restartDownloadWithVideo:video];
                
            } else {
                OB_INFO(@"AppSync.handleStuckDownloads: Ignoring video already processing: %@.", video.videoId);
            }
        }
        handler();
    }];
}

- (BOOL) transferTaskStuckWithTransferInfo:(NSDictionary *)transferInfo{
    if (transferInfo == nil) {
        OB_ERROR(@"AppSync.transferTaskStuckWithTransferInfo: nil transferInfo. This should never happen.");
        return NO;
    }
    NSDate *createdOn = transferInfo[OBFTMCreatedOnKey];
    NSNumber *bytesReceived = transferInfo[OBFTMCountOfBytesReceivedKey];
    NSTimeInterval age = -[createdOn timeIntervalSinceNow];
    OB_DEBUG(@"isStuckWithVideo: age=%f, bytesReceived=%@", age, bytesReceived);
    if (age > 0.25 && [bytesReceived isEqualToNumber: [NSNumber numberWithInt:0]]){
        OB_INFO(@"isStuckWithVideo: YES");
        return YES;
    } else {
        OB_INFO(@"isStuckWithVideo: NO");
        return NO;
    }
}

- (BOOL) isPendingRetryWithObInfo:(NSDictionary *)obInfo{
    if (obInfo == nil) {
        OB_ERROR(@"AppSync: isPendingRetryWithVideo: got nil obInfo. Should never happen.");
        return NO;
    } else {
        // OB_DEBUG(@"isPendingRetryWithVideo: got Info = %@", obInfo);
        return [obInfo[OBFTMStatusKey] integerValue] == FileTransferPendingRetry;
    }
}

- (void) restartDownloadWithVideo:(TBMVideo *)video{
    NSString *marker = [TBMVideoIdUtils markerWithVideo:video isUpload:NO];
    [[self fileTransferManager] restartTransferWithMarker:marker onComplete:nil];
}

- (NSDictionary *)infoWithVideo:(TBMVideo *)video isUpload:(BOOL)isUpload allInfo:(NSArray *)allInfo{
    NSString *marker = [TBMVideoIdUtils markerWithVideo:video isUpload:isUpload];
    for (NSDictionary *d in allInfo){
        NSString *dMarker = [d objectForKey:OBFTMMarkerKey ];
        if ([dMarker isEqualToString:marker])
            return d;
    }
    return nil;
}



@end

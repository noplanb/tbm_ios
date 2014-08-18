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
- (OBFileTransferManager *) getFileTransferManager{
    if (self.fileTransferManager == nil) {
        [self setFileTransferManager: [OBFileTransferManager instance]];
        self.fileTransferManager.delegate = self;
        self.fileTransferManager.downloadDirectory = [TBMConfig videosDirectoryUrl].path;
        self.fileTransferManager.remoteUrlBase = CONFIG_SERVER_BASE_URL_STRING;
    }
    return self.fileTransferManager;
}

- (OBFileTransferManager *)fileTransferManager{
    OBFileTransferManager *ftm = objc_getAssociatedObject(self, @selector(fileTransferManager));
    if (ftm == nil){
        ftm = [OBFileTransferManager instance];
        ftm.delegate = self;
        ftm.downloadDirectory = [TBMConfig videosDirectoryUrl].path;
        ftm.remoteUrlBase = CONFIG_SERVER_BASE_URL_STRING;
        [self setFileTransferManager:ftm];
    }
    return ftm;
}

- (void) setFileTransferManager:(OBFileTransferManager *)ftm{
    objc_setAssociatedObject(self, @selector(fileTransferManager), ftm, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) uploadWithFriendId:(NSString *)friendId{
    TBMFriend *friend = [TBMFriend findWithId:friendId];
    NSString *localFilePath = [TBMVideoRecorder outgoingVideoUrlWithMarker:friendId].path;
    NSString *marker = [TBMVideoIdUtils markerWithFriend:friend videoId:friend.outgoingVideoId];
    OB_INFO(@"uploadWithFriendId marker = %@", marker);
    
    [[self getFileTransferManager]
     uploadFile:localFilePath
     to:REMOTE_STORAGE_VIDEO_UPLOAD_PATH
     withMarker:marker
     withParams:@{@"filename": [TBMRemoteStorageHandler outgoingVideoRemoteFilename:friend]}];
}

- (void)queueDownloadWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId{
    if ([TBMVideoIdUtils isvid1:videoId olderThanVid2:[friend oldestIncomingVideo].videoId]) {
        OB_WARN(@"queueVideoDownloadWithFriend: Ignoring incoming video older than oldest.");
        return;
    }
    
    if ([friend hasIncomingVideoId:videoId]){
        OB_WARN(@"queueVideoDownloadWithFriend: Ignoring incoming videoId already processed.");
        return;
    }
    
    TBMVideo *video = [friend createIncomingVideoWithVideoId:videoId];
    [friend setAndNotifyIncomingVideoStatus:INCOMING_VIDEO_STATUS_DOWNLOADING video:video];
    
    NSString *marker = [TBMVideoIdUtils markerWithFriend:friend videoId:videoId];

    [[self getFileTransferManager]
     downloadFile: REMOTE_STORAGE_VIDEO_DOWNLOAD_PATH
     to:[video videoPath]
     withMarker: marker
     withParams:@{@"filename": [TBMRemoteStorageHandler incomingVideoRemoteFilename:video]}];
}


//-------------------------------
// FileTransferDelegate callbacks
//-------------------------------

- (void) fileTransferCompleted:(NSString *)marker isUpload:(BOOL)isUpload withError:(NSError *)error{
    OB_INFO(@"fileTransferCompleted marker = %@", marker);
    TBMFriend *friend = [TBMVideoIdUtils friendWithMarker:marker];
    NSString *videoId = [TBMVideoIdUtils videoIdWithMarker:marker];

    if (friend == nil){
        OB_ERROR(@"fileTransferCompleted - Could not find friend with marker = %@.", marker);
        return;
    }

    if (isUpload){
        [self uploadCompletedWithFriend:friend videoId:videoId error:error];
    } else {
        [self downloadCompletedWithFriend:friend videoId:videoId error:error];
    }
}

- (void) fileTransferProgress:(NSString *)marker isUpload:(BOOL)isUpload percent:(NSUInteger)progress{
    
}

- (void) fileTransferRetrying:(NSString *)marker isUpload:(BOOL)isUpload attemptCount:(NSInteger)attemptCount withError:(NSError *)error{
    OB_INFO(@"fileTransferRetrying");
    TBMFriend *friend = [TBMVideoIdUtils friendWithMarker:marker];
    NSString *videoId = [TBMVideoIdUtils videoIdWithMarker:marker];

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
    OB_INFO(@"uploadCompletedWithFriend");
    if (friend == nil){
        OB_ERROR(@"uploadCompletedWithFriend - Could not find friend with marker.");
        return;
    }
    
    if (error == nil){
        [friend  setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_UPLOADED videoId:videoId];
        [TBMRemoteStorageHandler addRemoteOutgoingVideoId:videoId friend:friend];
        [self sendNotificationForVideoReceived:friend videoId:videoId];
    } else {
        OB_ERROR(@"uploadCompletedWithVideoId: upload error. Setting status to FailedPermanently");
        [friend setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY videoId:videoId];
    }
}

- (void) uploadRetryingWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId retryCount:(NSInteger)retryCount{
    OB_INFO(@"uploadRetryingWithFriend");
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
    
    OB_INFO(@"Video count = %ld", (unsigned long)[TBMVideo count]);
    
    if (video == nil){
        OB_ERROR(@"downloadCompletedWithFriend: ERROR: unrecognized videoId");
        return;
    }
    
    // GARF: TODO: We should delete the remoteVideoId from remoteVideoIds only if file deletion is successful so we dont leave hanging
    // files.
    [TBMRemoteStorageHandler deleteRemoteVideoFile:video];
    [TBMRemoteStorageHandler deleteRemoteIncomingVideoId:videoId friend:friend];
    
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
    
    OB_INFO(@"Video count = %ld", (unsigned long)[TBMVideo count]);

}


- (void) downloadRetryingWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId retryCount:(NSInteger)retryCount{
    TBMVideo *video = [TBMVideo findWithVideoId:videoId];
    
    if (video == nil){
        OB_ERROR(@"downloadRetryingWithFriend: ERROR: unrecognized videoId");
        return;
    }
    NSNumber *ncount = [NSNumber numberWithInteger:retryCount];
    [friend setAndNotifyDownloadRetryCount:ncount video:video];
}


@end

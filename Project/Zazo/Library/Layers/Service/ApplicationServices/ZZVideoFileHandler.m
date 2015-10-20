//
//  ZZVideoFileHandler.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoFileHandler.h"
#import "OBFileTransferManager.h"
#import "ZZS3CredentialsDomainModel.h"
#import "ZZRemoteStorageConstants.h"
#import "TBMVideo.h"
#import "ZZThumbnailGenerator.h"
#import "ZZVideoDomainModel.h"
#import "ZZFriendDataProvider.h"
#import "ZZRemoteStoageTransportService.h"
#import "ZZCommonNetworkTransportService.h"
#import "TBMVideoIdUtils.h"
#import "ZZStoredSettingsManager.h"
#import "ZZVideoDataProvider.h"
#import "ZZNotificationsConstants.h"
#import "ZZRemoteStorageValueGenerator.h"
#import "ZZVideoNetworkTransportService.h"

@interface ZZVideoFileHandler () <OBFileTransferDelegate>

@property (nonatomic, strong, readonly) OBFileTransferManager* fileTransferManager;

@end

@implementation ZZVideoFileHandler

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        OBFileTransferManager* manager = [OBFileTransferManager instance];
        manager.delegate = self;
        NSURL* videosURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                   inDomains:NSUserDomainMask] firstObject];
        manager.downloadDirectory = videosURL.path;
        manager.remoteUrlBase = remoteStorageBaseURL();
        [self _updateCredentials];
    }
    return self;
}

- (void)_updateCredentials
{
    ZZS3CredentialsDomainModel* credentials = [ZZKeychainDataProvider loadCredentials];
    
    NSDictionary *cparams  = @{OBS3RegionParam : [NSObject an_safeString:credentials.region],
                               OBS3NoTvmAccessKeyParam : [NSObject an_safeString:credentials.accessKey],
                               OBS3NoTvmSecretKeyParam : [NSObject an_safeString:credentials.secretKey]};
    [self.fileTransferManager configure:cparams];
}


#pragma mark - OBFileTransferDelegate


//-------------------------------
// FileTransferDelegate callbacks
//-------------------------------

- (NSTimeInterval)retryTimeoutValue:(NSInteger)retryAttempt
{
    if (retryAttempt > 7)
        return (NSTimeInterval) 128;
    else
        return (NSTimeInterval) (1 << (retryAttempt - 1));
}


- (void)fileTransferCompleted:(NSString *)marker withError:(NSError *)error
{
    OB_INFO(@"fileTransferCompleted marker = %@", marker);
    
    [self.delegate requestBackground];
    TBMFriend *friend = [TBMVideoIdUtils friendWithMarker:marker];
    NSString *videoId = [TBMVideoIdUtils videoIdWithMarker:marker];
    if (friend == nil)
    {
        OB_ERROR(@"fileTransferCompleted - Could not find friend with marker = %@. This should never happen", marker);
        return;
    }
    
    [self handleError:error marker:marker];
    
    BOOL isUpload = [TBMVideoIdUtils isUploadWithMarker:marker];
    if (isUpload)
    {
        [self uploadCompletedWithFriendID:friend.idTbm videoId:videoId error:error];
    }
    else
    {
        [self downloadCompletedWithFriendID:friend.idTbm videoId:videoId error:error];
    }
}

- (void)handleError:(NSError *)error marker:(NSString *)marker
{
    if (error == nil)
        return;
    
    // 404s can happen in normal operation do not dispatch or refresh credentials.
    if (error.code == 404)
        return;
    
    
    ANDispatchBlockToBackgroundQueue(^{
        NSString *type = [TBMVideoIdUtils isUploadWithMarker:marker] ? @"upload" : @"download";
        OB_ERROR(@"AppSync: Permanent failure in %@ due to error: %@", type, error);
        // Refresh the credentials from the server and set ftm to nil so that it uses new credentials if they have arrived by the next time we need it.
        [[ZZCommonNetworkTransportService loadS3Credentials] subscribeNext:^(id x) {
            [self _updateCredentials];
        }];
    });
}

- (void)fileTransferProgress:(NSString *)marker percent:(NSUInteger)progress
{
    //nothing
}

- (void)fileTransferRetrying:(NSString *)marker attemptCount:(NSUInteger)attemptCount withError:(NSError *)error
{
    OB_INFO(@"fileTransferRetrying");
    [self.delegate requestBackground];
    TBMFriend *friend = [TBMVideoIdUtils friendWithMarker:marker];
    NSString *videoId = [TBMVideoIdUtils videoIdWithMarker:marker];
    
    BOOL isUpload = [TBMVideoIdUtils isUploadWithMarker:marker];
    if (isUpload)
    {
        [self uploadRetryingWithFriendID:friend.idTbm videoId:videoId retryCount:attemptCount];
    } else
    {
        [self downloadRetryingWithFriendID:friend.idTbm videoId:videoId retryCount:attemptCount];
    }
}


//-------
// Upload
//-------
#pragma mark - Upload

- (void)uploadWithVideoUrl:(NSURL *)videoUrl
{
    OB_INFO(@"uploadWithVideoUrl %@", videoUrl);
    
    NSString *marker = [TBMVideoIdUtils markerWithOutgoingVideoUrl:videoUrl];
    NSString *videoId = [TBMVideoIdUtils videoIdWithOutgoingVideoUrl:videoUrl];
    TBMFriend *friend = [TBMVideoIdUtils friendWithOutgoingVideoUrl:videoUrl];
    
    NSString *remoteFilename = [ZZRemoteStorageValueGenerator outgoingVideoRemoteFilenameWithFriendMkey:friend.mkey
                                                                                             friendCKey:friend.ckey
                                                                                                videoId:videoId];
    [[self fileTransferManager] uploadFile:videoUrl.path
                                        to:remoteStorageFileTransferUploadPath()
                                withMarker:marker
                                withParams:[self fileTransferParams:remoteFilename]];
    
    // fileTransferManager should create a copy of ougtoing file synchronously
    // prior to returning from the above call so should be safe to delete video file here.
    [[NSFileManager defaultManager] removeItemAtURL:videoUrl error:nil];
    
    [friend handleOutgoingVideoUploadingWithVideoId:videoId];
}

//--------------
// Upload events
//--------------
- (void)uploadCompletedWithFriendID:(NSString*)friendID videoId:(NSString *)videoId error:(NSError *)error
{
    TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];
    if (friend == nil)
    {
        OB_ERROR(@"uploadCompletedWithFriend - Could not find friend with marker.");
        return;
    }
    if (error == nil)
    {
        OB_INFO(@"uploadCompletedWithFriend");
        [friend handleOutgoingVideoUploadedWithVideoId:videoId];
        [[ZZRemoteStoageTransportService addRemoteOutgoingVideoWithItemID:videoId friend:friend] subscribeNext:^(id x) {}];
        
        NSString* myMkey = [ZZStoredSettingsManager shared].userID;
        [[ZZRemoteStoageTransportService updateRemoteEverSentKVForFriendMkeys:[TBMFriend everSentMkeys]
                                                                  forUserMkey:myMkey] subscribeNext:^(id x) {}];
        
        [self.delegate videoReceivedFromFriendWithItemID:friendID videoID:videoId];
    }
    else
    {
        OB_ERROR(@"uploadCompletedWithVideoId: upload error. FailedPermanently");
        [friend handleOutgoingVideoFailedPermanentlyWithVideoId:videoId];
    }
}

- (void)uploadRetryingWithFriendID:(NSString*)friendID videoId:(NSString *)videoId retryCount:(NSInteger)retryCount
{
    TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];
    OB_INFO(@"uploadRetryingWithFriend retryCount=%ld", (long) retryCount);
    if (friend == nil)
    {
        OB_ERROR(@"uploadRetryingWithFriend - Could not find friend with marker");
        return;
    }
    [friend handleUploadRetryCount:retryCount videoId:videoId];
}


//----------------
// Download events
//----------------
- (void)downloadCompletedWithFriendID:(NSString*)friendID videoId:(NSString *)videoId error:(NSError *)error
{
    TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];
    TBMVideo *video = [TBMVideo findWithVideoId:videoId];
    if (video == nil)
    {
        OB_ERROR(@"downloadCompletedWithFriend: ERROR: unrecognized videoId");
        return;
    }
    
    [self deleteRemoteFileAndVideoId:video];
    
    if (error != nil)
    {
        OB_ERROR(@"downloadCompletedWithFriend %@", error);
        [friend setAndNotifyIncomingVideoStatus:INCOMING_VIDEO_STATUS_FAILED_PERMANENTLY video:video];
        return;
    }
    
    ZZVideoDomainModel* videoModel = [ZZVideoDataProvider modelFromEntity:video];
    //    NSURL* videoUrl = videoModel.videoURL;
    
    //    if ([ZZFileHelper isMediaFileCorruptedWithFileUrl:videoUrl])
    //    {
    //        [ZZFileHelper deleteFileWithURL:videoUrl];
    //        return;
    //    }
    
    [ZZThumbnailGenerator generateThumbVideo:videoModel];
    [friend deleteAllViewedOrFailedVideos];
    
    [friend setAndNotifyIncomingVideoStatus:INCOMING_VIDEO_STATUS_DOWNLOADED video:video];
    
    [[ZZRemoteStoageTransportService updateRemoteStatusForVideoWithItemID:videoId
                                                                 toStatus:ZZRemoteStorageVideoStatusDownloaded
                                                                   friend:friend] subscribeNext:^(id x) {}];
    
    [self.delegate sendNotificationForVideoStatusUpdate:friend videoId:videoId status:NOTIFICATION_STATUS_DOWNLOADED];
    
    OB_INFO(@"downloadCompletedWithFriend: Video count = %ld", (unsigned long) [TBMVideo count]);
}


- (void)downloadRetryingWithFriendID:(NSString*)friendID videoId:(NSString *)videoId retryCount:(NSInteger)retryCount
{
    TBMVideo *video = [TBMVideo findWithVideoId:videoId];
    
    if (video == nil)
    {
        OB_ERROR(@"downloadRetryingWithFriend: ERROR: unrecognized videoId");
        return;
    }
    TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];
    OB_INFO(@"downloadRetryingWithFriend %@ retryCount= %@", friend.firstName, @(retryCount));
    [friend setAndNotifyDownloadRetryCount:retryCount video:video];
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

- (void)handleStuckDownloadsWithCompletionHandler:(void (^)())handler
{
    [[self fileTransferManager] currentTransferStateWithCompletionHandler:^(NSArray *allTransferInfo)
     {
         OB_INFO(@"handleStuckDownloads: (%lu)", (unsigned long) [TBMVideo downloadingCount]);
         NSArray *allObInfo = [[self fileTransferManager] currentState];
         for (TBMVideo *video in [TBMVideo downloading])
         {
             NSDictionary *obInfo = [self infoWithVideo:video isUpload:NO allInfo:allObInfo];
             NSDictionary *transferInfo = [self infoWithVideo:video isUpload:NO allInfo:allTransferInfo];
             
             if (obInfo == nil)
             {
                 OB_WARN(@"AppSync.handleStuckDownloads: Got no obInfo for vid:%@ double checking to make sure hasnt completed.", video.videoId);
                 if ([video isStatusDownloading])
                 {
                     OB_ERROR(@"AppSync.handleStuckDownloads: Got no obInfo for vid:%@ this should not happen. Force requeue the video.", video.videoId);
                     [self queueDownloadWithFriendID:video.friend.idTbm videoId:video.videoId force:YES];
                 }
                 
             } else if ([self isPendingRetryWithObInfo:obInfo])
             {
                 OB_INFO(@"AppSync.handleStuckDownloads: Ignoring video pending retry: %@.", video.videoId);
                 
             } else if (![self isPendingRetryWithObInfo:obInfo] && transferInfo == nil)
             {
                 OB_WARN(@"AppSync.handleStuckDownloads: Got no transferInfo for vid:%@ could be due to termination by user during download. Restarting the task.", video.videoId);
                 [self restartDownloadWithVideo:video];
                 
             } else if ([self transferTaskStuckWithTransferInfo:transferInfo])
             {
                 OB_WARN(@"AppSync.handleStuckDownloads: Restarting stuck download: %@.", video.videoId);
                 [self restartDownloadWithVideo:video];
                 
             } else
             {
                 OB_INFO(@"AppSync.handleStuckDownloads: Ignoring video already processing: %@.", video.videoId);
             }
         }
         handler();
     }];
}

- (BOOL)transferTaskStuckWithTransferInfo:(NSDictionary *)transferInfo
{
    if (transferInfo == nil)
    {
        OB_ERROR(@"AppSync.transferTaskStuckWithTransferInfo: nil transferInfo. This should never happen.");
        return NO;
    }
    NSDate *createdOn = transferInfo[CreatedOnKey];
    NSNumber *bytesReceived = transferInfo[CountOfBytesReceivedKey];
    NSTimeInterval age = -[createdOn timeIntervalSinceNow];
    OB_DEBUG(@"isStuckWithVideo: age=%f, bytesReceived=%@", age, bytesReceived);
    if (age > 0.25 && [bytesReceived isEqualToNumber:[NSNumber numberWithInt:0]])
    {
        OB_INFO(@"isStuckWithVideo: YES");
        return YES;
    }
    else
    {
        OB_INFO(@"isStuckWithVideo: NO");
        return NO;
    }
}

- (BOOL)isPendingRetryWithObInfo:(NSDictionary *)obInfo
{
    if (obInfo == nil)
    {
        OB_ERROR(@"AppSync: isPendingRetryWithVideo: got nil obInfo. Should never happen.");
        return NO;
    } else
    {
        // OB_DEBUG(@"isPendingRetryWithVideo: got Info = %@", obInfo);
        return [obInfo[StatusKey] integerValue] == FileTransferPendingRetry;
    }
}

- (void)restartDownloadWithVideo:(TBMVideo *)video
{
    NSString *marker = [TBMVideoIdUtils markerWithVideo:video isUpload:NO];
    [[self fileTransferManager] restartTransfer:marker onComplete:nil];
}

- (NSDictionary *)infoWithVideo:(TBMVideo *)video isUpload:(BOOL)isUpload allInfo:(NSArray *)allInfo
{
    NSString *marker = [TBMVideoIdUtils markerWithVideo:video isUpload:isUpload];
    for (NSDictionary *d in allInfo)
    {
        NSString *dMarker = [d objectForKey:MarkerKey];
        if ([dMarker isEqualToString:marker])
            return d;
    }
    return nil;
}

//---------
// Download
//---------
- (void)queueDownloadWithFriendID:(NSString*)friendID videoId:(NSString *)videoId
{
    [self queueDownloadWithFriendID:friendID videoId:videoId force:NO];
}

- (void)queueDownloadWithFriendID:(NSString*)friendID videoId:(NSString *)videoId force:(BOOL)force
{
    //    Removed because IOS sends the vidoes out in parallel a later short one may arrive before an earlier long one.
    //    if ([TBMVideoIdUtils isvid1:videoId olderThanVid2:[friend oldestIncomingVideo].videoId]) {
    //        OB_WARN(@"queueVideoDownloadWithFriend: Ignoring incoming video older than oldest.");
    //        return;
    //    }
    
    TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];
    
    if ([friend hasIncomingVideoId:videoId] && !force)
    {
        OB_WARN(@"queueVideoDownloadWithFriend: Ignoring incoming videoId already processed.");
        return;
    }
    
    TBMVideo *video;
    if ([friend hasIncomingVideoId:videoId] && force)
    {
        OB_INFO(@"queueVideoDownloadWithFriend: Forcing new transfer of existing video: %@", videoId);
        video = [TBMVideo findWithVideoId:videoId];
    } else
    {
        OB_INFO(@"queueVideoDownloadWithFriend: Creating new video for download: %@", videoId);
        video = [friend createIncomingVideoWithVideoId:videoId];
    }
    
    if (video == nil)
    {
        OB_ERROR(@"queueVideoDownloadWithFriend: Video is nil. This should never happen.");
        return;
    }
    
    [friend setAndNotifyIncomingVideoStatus:INCOMING_VIDEO_STATUS_DOWNLOADING video:video];
    [self.delegate setBadgeNumberUnviewed];
    
    NSString *marker = [TBMVideoIdUtils markerWithFriend:friend videoId:videoId isUpload:NO];
    
    NSString *remoteFilename = [ZZRemoteStorageValueGenerator incomingVideoRemoteFilenameWithFriendMkey:video.friend.mkey
                                                                                             friendCKey:video.friend.ckey
                                                                                                videoId:video.videoId];
    
    [[self fileTransferManager] downloadFile:remoteStorageFileTransferDownloadPath()
                                          to:[video videoPath]
                                  withMarker:marker
                                  withParams:[self fileTransferParams:remoteFilename]];
}

- (NSDictionary *)fileTransferParams:(NSString *)remoteFilename
{
    return @{@"filename" : remoteFilename,
             FilenameParamKey : remoteFilename,
             ContentTypeParamKey : @"video/mp4"};
}

- (void)retryPendingFileTransfers
{
    [[self fileTransferManager] retryPending];
}



//-------
// Delete
//-------
- (void)deleteRemoteFile:(NSString *)filename
{
    OB_INFO(@"deleteRemoteFile: deleting: %@", filename);
    if (kRemoteStorageShouldUseS3)
    {
        NSString *full = [NSString stringWithFormat:@"%@/%@", remoteStorageFileTransferDeletePath(), filename];
        [self performSelectorInBackground:@selector(ftmDelete:) withObject:full];
    }
    else
    {
        [[ZZVideoNetworkTransportService deleteVideoFileWithName:filename] subscribeNext:^(id x) {}];
    }
}

- (void)ftmDelete:(NSString *)path
{
    NSError *e = [[self fileTransferManager] deleteFile:path];
    if (e != nil)
        OB_ERROR(@"ftmDelete: Error trying to delete remote file. This should never happen. %@", e);
}

// Convenience
- (void)deleteRemoteVideoFile:(TBMVideo *)video
{
    NSString *filename = [ZZRemoteStorageValueGenerator incomingVideoRemoteFilenameWithFriendMkey:video.friend.mkey
                                                                                       friendCKey:video.friend.ckey
                                                                                          videoId:video.videoId];
    [self deleteRemoteFile:filename];
}

- (void)deleteRemoteFileAndVideoId:(TBMVideo *)video
{
    // GARF: TODO: We should delete the remoteVideoId from remoteVideoIds only if file deletion is successful so we dont leave hanging
    // files. This is not a problem on s3 as old videos are automatically deleted by the server.
    [self deleteRemoteVideoFile:video];
    [[ZZRemoteStoageTransportService deleteRemoteIncomingVideoWithItemID:video.videoId
                                                                  friend:video.friend] subscribeNext:^(id x) {}];
}





#pragma mark - Private

- (OBFileTransferManager*)fileTransferManager
{
    return [OBFileTransferManager instance];
}

@end

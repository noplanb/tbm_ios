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
#import "TBMVideoRecorder.h"
#import "TBMRemoteStorageHandler.h"
#import "TBMVideoIdUtils.h"
#import "TBMVideoProcessor.h"
#import "ZZVideoRecorder.h"
#import "MagicalRecord.h"
#import "ZZVideoNetworkTransportService.h"
#import "ZZKeychainDataProvider.h"
#import "ZZS3CredentialsDomainModel.h"
#import "ZZCommonNetworkTransportService.h"
#import "ZZFriendDataProvider.h"
#import "ZZThumbnailGenerator.h"
#import "ZZVideoDataProvider.h"
#import "ZZFileHelper.h"
#import "ZZVideoDomainModel.h"


@implementation TBMAppDelegate (AppSync)

//-------------------
// FileTransfer setup
//-------------------
- (OBFileTransferManager *)fileTransferManager
{
    OBFileTransferManager *ftm = objc_getAssociatedObject(self, @selector(fileTransferManager));
    if (ftm == nil)
    {
        ftm = [OBFileTransferManager instance];
        ftm.delegate = self;
         NSURL* videosURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        ftm.downloadDirectory = videosURL.path;
        ftm.remoteUrlBase = [TBMRemoteStorageHandler fileTransferRemoteUrlBase];
        NSDictionary *cparams;
        ZZS3CredentialsDomainModel* credentials = [ZZKeychainDataProvider loadCredentials];
        cparams = @{
                OBS3RegionParam : [NSObject an_safeString:credentials.region],
                OBS3NoTvmAccessKeyParam : [NSObject an_safeString:credentials.accessKey],
                OBS3NoTvmSecretKeyParam : [NSObject an_safeString:credentials.secretKey]
        };
        [ftm configure:cparams];
        [self setFileTransferManager:ftm];
    }
    return ftm;
}

- (void)setFileTransferManager:(OBFileTransferManager *)ftm
{
    objc_setAssociatedObject(self, @selector(fileTransferManager), ftm, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)retryTimeoutValue:(NSUInteger)retryAttempt
{
    if (retryAttempt > 7)
        return (NSTimeInterval) 128;
    else
        return (NSTimeInterval) (1 << (retryAttempt - 1));
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

    NSString *remoteFilename = [TBMRemoteStorageHandler outgoingVideoRemoteFilename:friend videoId:videoId];
    [[self fileTransferManager] uploadFile:videoUrl.path
                                        to:[TBMRemoteStorageHandler fileTransferUploadPath]
                                withMarker:marker
                                withParams:[self fileTransferParams:remoteFilename]];

    // fileTransferManager should create a copy of ougtoing file synchronously
    // prior to returning from the above call so should be safe to delete video file here.
    [[NSFileManager defaultManager] removeItemAtURL:videoUrl error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSendMessage object:nil];

    [friend handleOutgoingVideoUploadingWithVideoId:videoId];
}

//---------
// Download
//---------
- (void)queueDownloadWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId
{
    ANDispatchBlockToBackgroundQueue(^{
       [self queueDownloadWithFriend:friend videoId:videoId force:NO];
    });
}

- (void)queueDownloadWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId force:(BOOL)force
{
//    Removed because IOS sends the vidoes out in parallel a later short one may arrive before an earlier long one.
//    if ([TBMVideoIdUtils isvid1:videoId olderThanVid2:[friend oldestIncomingVideo].videoId]) {
//        OB_WARN(@"queueVideoDownloadWithFriend: Ignoring incoming video older than oldest.");
//        return;
//    }

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
    [self setBadgeNumberUnviewed];

    NSString *marker = [TBMVideoIdUtils markerWithFriend:friend videoId:videoId isUpload:NO];
    NSString *remoteFilename = [TBMRemoteStorageHandler incomingVideoRemoteFilename:video];
    
    [[self fileTransferManager] downloadFile:[TBMRemoteStorageHandler fileTransferDownloadPath]
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
    if (REMOTE_STORAGE_USE_S3)
    {
        NSString *full = [NSString stringWithFormat:@"%@/%@", [TBMRemoteStorageHandler fileTransferDeletePath], filename];
        [self performSelectorInBackground:@selector(ftmDelete:) withObject:full];
    }
    else
    {
        [[ZZVideoNetworkTransportService deleteVideoFileWithName:filename] subscribeNext:^(id x) {
            
        }];
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
    NSString *filename = [TBMRemoteStorageHandler incomingVideoRemoteFilename:video];
    [self deleteRemoteFile:filename];
}

- (void)deleteRemoteFileAndVideoId:(TBMVideo *)video
{
    // GARF: TODO: We should delete the remoteVideoId from remoteVideoIds only if file deletion is successful so we dont leave hanging
    // files. This is not a problem on s3 as old videos are automatically deleted by the server.
    [self deleteRemoteVideoFile:(TBMVideo *) video];
    [TBMRemoteStorageHandler deleteRemoteIncomingVideoId:video.videoId friend:video.friend];
}

//--------
// Polling
//--------
- (void)getAndPollAllFriends
{
    OB_INFO(@"getAndPollAllFriends");
    [[[TBMFriendGetter alloc] initWithDelegate:self] getFriends];
}

- (void)gotFriends
{
    OB_INFO(@"gotFriends");
    [self pollAllFriends];
}

- (void)friendGetterServerError
{
    [self pollAllFriends];
}

- (void)pollAllFriends
{
    ANDispatchBlockToBackgroundQueue(^{
        OB_INFO(@"pollAllFriends");
        self.myFriends = [TBMFriend all];
        for (TBMFriend *f in self.myFriends)
        {
            [self pollVideosWithFriend:f];
            [self pollVideoStatusWithFriend:f];
        }
        [self pollEverSentStatusForAllFriends];
    });
}

- (void)pollEverSentStatusForAllFriends
{
    [TBMRemoteStorageHandler getRemoteEverSentFriendsWithSuccess:^(NSArray *response) {
        ANDispatchBlockToBackgroundQueue(^{
            [TBMFriend setEverSentForMkeys:response];
        });
    } failure:nil];
}

- (void)pollVideosWithFriend:(TBMFriend *)friend
{
    NSLog(@"before");
    
//    [TBMRemoteStorageHandler getRemoteIncomingVideoIdsWithFriend:friend gotVideoIds:^(NSArray *videoIds)
//    {
//        OB_INFO(@"pollWithFriend: %@  vids = %@", friend.firstName, videoIds);
//        for (NSString *videoId in videoIds)
//        {
////            Removed because IOS sends the vidoes out in parallel a later short one may arrive before an earlier long one.
////            if ([TBMVideoIdUtils isvid1:videoId olderThanVid2:[friend oldestIncomingVideoId]]) {
////                OB_WARN(@"pollWithFriend: Deleting remote video and videoId kv older than local oldest.");
////                [TBMRemoteStorageHandler deleteRemoteFileAndVideoIdWithFriend:friend videoId:videoId];
////            }
//            [self queueDownloadWithFriend:friend videoId:videoId];
//        }
//    }];
    
    if (friend.idTbm)
    {
        __block TBMFriend* someFriend = friend;
        
        __block NSString* URL = [someFriend.objectID.URIRepresentation absoluteString];
        
        [TBMRemoteStorageHandler getRemoteIncomingVideoIdsWithFriend:friend
                                                         gotVideoIds:^(NSArray *videoIds) {
                                                             OB_INFO(@"pollWithFriend: %@  vids = %@", someFriend.firstName, videoIds);
                                                             for (NSString *videoId in videoIds)
                                                             {
                                                                 //            Removed because IOS sends the vidoes out in parallel a later short one may arrive before an earlier long one.
                                                                 //            if ([TBMVideoIdUtils isvid1:videoId olderThanVid2:[friend oldestIncomingVideoId]]) {
                                                                 //                OB_WARN(@"pollWithFriend: Deleting remote video and videoId kv older than local oldest.");
                                                                 //                [TBMRemoteStorageHandler deleteRemoteFileAndVideoIdWithFriend:friend videoId:videoId];
                                                                 //            }
                                                                 
                                                                 NSManagedObject* object;
                                                                 if (!ANIsEmpty(URL))
                                                                 {
                                                                     NSURL* objectURL = [NSURL URLWithString:[NSString stringWithString:URL]];
                                                                     NSManagedObjectContext* context = [NSManagedObjectContext MR_rootSavingContext];
                                                                     NSManagedObjectID* objectID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:objectURL];
                                                                     NSError* error = nil;
                                                                     if (!ANIsEmpty(objectID))
                                                                     {
                                                                         object = [context existingObjectWithID:objectID error:&error];
                                                                     }
                                                                 }
                                                                 
                                                                 [self queueDownloadWithFriend:(TBMFriend*)object videoId:videoId];
                                                             }
                                                         }];
    }
    
}

- (void)pollVideoStatusWithFriend:(TBMFriend *)friend
{
    if (friend.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED)
    {
        OB_INFO(@"pollVideoStatusWithFriend: skipping %@ becuase outgoing status is viewed.", friend.firstName);
        return;
    }

    [TBMRemoteStorageHandler getRemoteOutgoingVideoStatus:friend
                                                  success:^(NSDictionary *response)
                                                  {
                                                      NSString *status = response[REMOTE_STORAGE_STATUS_KEY];
                                                      int ovsts = [TBMRemoteStorageHandler outgoingVideoStatusWithRemoteStatus:status];
                                                      if (ovsts == -1)
                                                      {
                                                          OB_ERROR(@"pollVideoStatusWithFriend: got unknown outgoing video status: %@", status);
                                                          return;
                                                      }
                                                      // This call handles making sure that videoId == outgoingVideoId etc.
                                                      [friend setAndNotifyOutgoingVideoStatus:ovsts
                                                                                      videoId:response[REMOTE_STORAGE_VIDEO_ID_KEY]];
                                                  }
                                                  failure:^(NSError *error)
                                                  {
                                                      // This can happen on startup when there is nothing in the remoteVideoStatusKV
                                                      OB_WARN(@"pollVideoStatusWithFriend: Error polling outgoingVideoStatus for %@ - %@", friend.firstName, error);
                                                  }];
}

//-------------------------------
// FileTransferDelegate callbacks
//-------------------------------

- (void)fileTransferCompleted:(NSString *)marker withError:(NSError *)error
{
    OB_INFO(@"fileTransferCompleted marker = %@", marker);
    
    [self requestBackground];
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
        [self uploadCompletedWithFriend:friend videoId:videoId error:error];
    } else
    {
        [self downloadCompletedWithFriend:friend videoId:videoId error:error];
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
        [[ZZCommonNetworkTransportService loadS3Credentials] subscribeNext:^(id x) {}];
        [self setFileTransferManager:nil];
    });
}

- (void)fileTransferProgress:(NSString *)marker percent:(NSUInteger)progress
{

}

- (void)fileTransferRetrying:(NSString *)marker attemptCount:(NSInteger)attemptCount withError:(NSError *)error
{
    OB_INFO(@"fileTransferRetrying");
    [self requestBackground];
    TBMFriend *friend = [TBMVideoIdUtils friendWithMarker:marker];
    NSString *videoId = [TBMVideoIdUtils videoIdWithMarker:marker];
    
    BOOL isUpload = [TBMVideoIdUtils isUploadWithMarker:marker];
    if (isUpload)
    {
        [self uploadRetryingWithFriend:friend videoId:videoId retryCount:attemptCount];
    } else
    {
        [self downloadRetryingWithFriend:friend videoId:videoId retryCount:attemptCount];
    }
}

//--------------
// Upload events
//--------------
- (void)uploadCompletedWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId error:(NSError *)error
{
    if (friend == nil)
    {
        OB_ERROR(@"uploadCompletedWithFriend - Could not find friend with marker.");
        return;
    }
    if (error == nil)
    {
        OB_INFO(@"uploadCompletedWithFriend");
        [friend handleOutgoingVideoUploadedWithVideoId:videoId];
        [TBMRemoteStorageHandler addRemoteOutgoingVideoId:videoId friend:friend];
        [TBMRemoteStorageHandler setRemoteEverSentKVForFriendMkeys:[TBMFriend everSentMkeys]];

        [self sendNotificationForVideoReceived:friend videoId:videoId];
    } else
    {
        OB_ERROR(@"uploadCompletedWithVideoId: upload error. FailedPermanently");
        [friend handleOutgoingVideoFailedPermanentlyWithVideoId:videoId];
    }
}

- (void)uploadRetryingWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId retryCount:(NSInteger)retryCount
{
    OB_INFO(@"uploadRetryingWithFriend retryCount=%ld", (long) retryCount);
    if (friend == nil)
    {
        OB_ERROR(@"uploadRetryingWithFriend - Could not find friend with marker");
        return;
    }

    NSNumber *ncount = [NSNumber numberWithInteger:retryCount];
    [friend handleUploadRetryCount:ncount videoId:videoId];
}


//----------------
// Download events
//----------------
- (void)downloadCompletedWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId error:(NSError *)error
{
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
    [TBMRemoteStorageHandler setRemoteIncomingVideoStatus:REMOTE_STORAGE_STATUS_DOWNLOADED videoId:videoId friend:friend];
    [self sendNotificationForVideoStatusUpdate:friend videoId:videoId status:NOTIFICATION_STATUS_DOWNLOADED];
  
    OB_INFO(@"downloadCompletedWithFriend: Video count = %ld", (unsigned long) [TBMVideo count]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFriendChangeNotification object:friend];
}


- (void)downloadRetryingWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId retryCount:(NSInteger)retryCount
{
    TBMVideo *video = [TBMVideo findWithVideoId:videoId];

    if (video == nil)
    {
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
                    [self queueDownloadWithFriend:video.friend videoId:video.videoId force:YES];
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

#pragma mark - VideoProcessorObservers

- (void)addVideoProcessorObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoProcessorDidFinishProcessingNotification:)
                                                 name:TBMVideoProcessorDidFinishProcessing
                                               object:nil];
}

- (void)addVideoRecordingObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidStartRecording:)
                                                 name:TBMVideoRecorderShouldStartRecording
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidFinishRecording:)
                                                 name:TBMVideoRecorderDidCancelRecording
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidFinishRecording:)
                                                 name:TBMVideoRecorderDidFail
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidFinishRecording:)
                                                 name:TBMVideoRecorderDidFinishRecording
                                               object:nil];
}

- (void)videoDidStartRecording:(id)sender
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)videoDidFinishRecording:(id)sender
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)videoProcessorDidFinishProcessingNotification:(NSNotification *)notification
{
    NSURL *videoUrl = [notification.userInfo objectForKey:@"videoUrl"];
    
    TBMFriend *friend = [TBMVideoIdUtils friendWithOutgoingVideoUrl:videoUrl];
    NSString *videoId = [TBMVideoIdUtils videoIdWithOutgoingVideoUrl:videoUrl];
    [friend handleOutgoingVideoCreatedWithVideoId:videoId];
    [self uploadWithVideoUrl:videoUrl];
}


@end

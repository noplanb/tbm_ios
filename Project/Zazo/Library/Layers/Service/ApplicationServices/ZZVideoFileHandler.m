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
#import "ZZFileTransferMarkerDomainModel.h"
#import "ZZVideoStatuses.h"
#import "ZZVideoStatusHandler.h"
#import "ZZFriendDataHelper.h"
#import "MagicalRecord.h"


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

- (void)startService
{
//    [self updateS3CredentialsWithRequest];
    [self handleStuckDownloadsWithCompletionHandler:^{
        [self.fileTransferManager retryPending];
        [self.delegate updateDataRequired];
    }];
}

- (void)_updateCredentials
{
    ZZS3CredentialsDomainModel* credentials = [ZZKeychainDataProvider loadCredentials];
    
    NSDictionary *cparams  = @{OBS3RegionParam : [NSObject an_safeString:credentials.region],
                               OBS3NoTvmAccessKeyParam : [NSObject an_safeString:credentials.accessKey],
                               OBS3NoTvmSecretKeyParam : [NSObject an_safeString:credentials.secretKey]};
    [self.fileTransferManager configure:cparams];
}

- (void)handleBackgroundSessionWithIdentifier:(NSString*)identifier completionHandler:(ANCodeBlock)completionHandler
{
    ZZLogInfo(@"handleEventsForBackgroundURLSession: for sessionId=%@", [NSObject an_safeString:identifier]);
    if ([[self.fileTransferManager session].configuration.identifier isEqualToString:identifier])
    {
        self.fileTransferManager.backgroundSessionCompletionHandler = completionHandler;
    }
    else
    {
        ZZLogError(@"handleEventsForBakcgroundURLSession passed us a different identifier from the one we instantiated our background session with.");
    }
}



#pragma mark - OBFileTransferDelegate


//-------------------------------
// FileTransferDelegate callbacks
//-------------------------------

- (NSTimeInterval)retryTimeoutValue:(NSInteger)retryAttempt
{
    if (retryAttempt > 7)
    {
        return (NSTimeInterval) 128;
    }
    else
    {
        return (NSTimeInterval) (1 << (retryAttempt - 1));
    }
}

- (void)fileTransferCompleted:(NSString *)marker withError:(NSError *)error
{
    
    ZZLogInfo(@"fileTransferCompleted marker = %@", marker);
    
    [self.delegate requestBackground];
    
    ZZFileTransferMarkerDomainModel* markerModel = [ZZFileTransferMarkerDomainModel modelWithEncodedMarker:marker];
    
    BOOL isFriendExist = [ZZFriendDataProvider isFriendExistsWithItemID:markerModel.friendID];
    
    if (isFriendExist)
    {
        [self _handleError:error marker:markerModel];
        
        if (markerModel.isUpload)
        {
            [self _uploadCompletedWithFriendID:markerModel.friendID videoId:markerModel.videoID error:error];
        }
        else
        {
            [self _downloadCompletedWithFriendID:markerModel.friendID videoId:markerModel.videoID error:error];
        }
    }
    else
    {
         ZZLogError(@"fileTransferCompleted - Could not find friend with marker = %@. This should never happen", marker);
    }
}

- (void)fileTransferRetrying:(NSString*)marker attemptCount:(NSUInteger)attemptCount withError:(NSError*)error
{
    ZZLogInfo(@"fileTransferRetrying");
    [self.delegate requestBackground];
    
    ZZFileTransferMarkerDomainModel* markerModel = [ZZFileTransferMarkerDomainModel modelWithEncodedMarker:marker];
    
    if (markerModel.isUpload)
    {
        [self uploadRetryingWithFriendID:markerModel.friendID videoId:markerModel.videoID retryCount:attemptCount];
    }
    else
    {
        [self downloadRetryingWithFriendID:markerModel.friendID videoId:markerModel.videoID retryCount:attemptCount];
    }
}

- (void)updateS3CredentialsWithRequest
{
    [[ZZCommonNetworkTransportService loadS3Credentials] subscribeNext:^(id x) {
        [self _updateCredentials];
    } error:^(NSError *error) {
        [self _loadS3CredentialsDidFailWithError:error];
    }];
}

- (void)_loadS3CredentialsDidFailWithError:(NSError *)error
{
    ANDispatchBlockToMainQueue(^{
        NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
        NSString* badConnectiontitle = [NSString stringWithFormat:@"Unable to reach %@ please check your Internet connection and try again.", [NSObject an_safeString:appName]];
        
        UIAlertView *av = [[UIAlertView alloc]
                           initWithTitle:@"Bad Connection"
                           message:badConnectiontitle
                           delegate:nil
                           cancelButtonTitle:@"Try Again"
                           otherButtonTitles:nil];
        
        [av.rac_buttonClickedSignal subscribeNext:^(id x) {
            [self updateS3CredentialsWithRequest];
        }];
        [av show];
    });
}

#pragma mark - Private

- (void)_handleError:(NSError *)error marker:(ZZFileTransferMarkerDomainModel*)marker
{
//    if (error == nil)
//        return;
//    
//    // 404s can happen in normal operation do not dispatch or refresh credentials.
//    if (error.code == 404)
//        return;
    if ((!ANIsEmpty(error) && error.code != 404) ||
        (!ANIsEmpty(error) && error.code != 403))
    {
        ANDispatchBlockToBackgroundQueue(^{
            NSString *type = marker.isUpload ? @"upload" : @"download";
            ZZLogError(@"AppSync: Permanent failure in %@ due to error: %@", type, error);
            // Refresh the credentials from the server and set ftm to nil so that it uses new credentials
            // if they have arrived by the next time we need it.
            //        [[ZZCommonNetworkTransportService loadS3Credentials] subscribeNext:^(id x) {
            //            [self _updateCredentials];
            //        }];
            [self updateS3CredentialsWithRequest];
        });
    }
}


//-------
// Upload
//-------
#pragma mark - Upload

- (void)uploadWithVideoUrl:(NSURL*)videoUrl friendCKey:(NSString*)friendCKey
{
    ZZLogInfo(@"uploadWithVideoUrl %@", videoUrl);
    
    NSString *marker = [videoUrl URLByDeletingPathExtension].lastPathComponent;
    ZZFileTransferMarkerDomainModel* markerModel = [ZZFileTransferMarkerDomainModel modelWithEncodedMarker:marker];
    
    
    TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:markerModel.friendID];
    //TODO: remove this
    
    NSString *remoteFilename = [ZZRemoteStorageValueGenerator outgoingVideoRemoteFilenameWithFriendMkey:friend.mkey
                                                                                             friendCKey:friendCKey
                                                                                                videoId:markerModel.videoID];
    [[self fileTransferManager] uploadFile:videoUrl.path
                                        to:remoteStorageFileTransferUploadPath()
                                withMarker:marker
                                withParams:[self fileTransferParams:remoteFilename]];
    
    // fileTransferManager should create a copy of ougtoing file synchronously
    // prior to returning from the above call so should be safe to delete video file here.
    [[NSFileManager defaultManager] removeItemAtURL:videoUrl error:nil];
    
    [self.delegate notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusUploading withFriend:friend videoId:markerModel.videoID];
}

//--------------
// Upload events
//--------------

- (void)uploadRetryingWithFriendID:(NSString*)friendID videoId:(NSString *)videoId retryCount:(NSInteger)retryCount
{
    BOOL isExist = [ZZFriendDataProvider isFriendExistsWithItemID:friendID];
    ZZLogInfo(@"uploadRetryingWithFriend retryCount=%ld", (long) retryCount);
    if (isExist)
    {
        TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];
        TBMVideo* video = [ZZVideoDataProvider entityWithID:videoId];
        [self.delegate setAndNotifyUploadRetryCount:retryCount withFriend:friend video:video];
    }
    else
    {
        ZZLogError(@"uploadRetryingWithFriend - Could not find friend with marker");
    }
}

- (void)_uploadCompletedWithFriendID:(NSString*)friendID videoId:(NSString *)videoId error:(NSError *)error
{
    TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];

    if (!ANIsEmpty(friend))
    {
        if (ANIsEmpty(error))
        {
            ZZLogInfo(@"uploadCompletedWithFriend");
            
            if (![friend.everSent boolValue])
            {
                friend.everSent = @(YES);
                [friend.managedObjectContext MR_saveToPersistentStoreAndWait];
            }
            
            [self.delegate notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusUploaded withFriend:friend videoId:videoId];
            
            [[ZZRemoteStoageTransportService addRemoteOutgoingVideoWithItemID:videoId
                                                                   friendMkey:friend.mkey
                                                                   friendCKey:friend.ckey] subscribeNext:^(id x) {}];
            
            NSString* myMkey = [ZZStoredSettingsManager shared].userID;
            
            [[ZZRemoteStoageTransportService updateRemoteEverSentKVForFriendMkeys:[ZZFriendDataHelper everSentMkeys]
                                                                      forUserMkey:myMkey] subscribeNext:^(id x) {}];
            
            [self.delegate sendNotificationForVideoReceived:friend videoId:videoId];
        }
        else
        {
            ZZLogError(@"uploadCompletedWithVideoId: upload error. FailedPermanently");
            [self.delegate notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusFailedPermanently withFriend:friend videoId:videoId];
        }
    }
    else
    {
        ZZLogError(@"uploadCompletedWithFriend - Could not find friend with marker.");
    }
}

//----------------
// Download events
//----------------
- (void)_downloadCompletedWithFriendID:(NSString*)friendID videoId:(NSString *)videoId error:(NSError *)error
{
        TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];
        TBMVideo *video = [ZZVideoDataProvider findWithVideoId:videoId];
        
        if (!ANIsEmpty(video))
        {
            if (ANIsEmpty(error))
            {
                [self deleteRemoteFileAndVideoId:video];
                ZZVideoDomainModel* videoModel = [ZZVideoDataProvider modelFromEntity:video];
                [ZZThumbnailGenerator generateThumbVideo:videoModel];
                [self.delegate deleteAllViewedOrFailedVideosWithFriendId:friendID];
                
                [self.delegate setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusDownloaded friendId:friendID videoId:videoId];
                
                [[ZZRemoteStoageTransportService updateRemoteStatusForVideoWithItemID:videoId
                                                                             toStatus:ZZRemoteStorageVideoStatusDownloaded
                                                                           friendMkey:friend.mkey
                                                                           friendCKey:friend.ckey] subscribeNext:^(id x) {}];
                
                [self.delegate sendNotificationForVideoStatusUpdate:friend videoId:videoId status:NOTIFICATION_STATUS_DOWNLOADED];
                
                ZZLogInfo(@"downloadCompletedWithFriend: Video count = %ld", (unsigned long) [ZZVideoDataProvider countAllVideos]);
            }
            else
            {
                ZZLogError(@"downloadCompletedWithFriend %@", error);
                [[ZZVideoStatusHandler sharedInstance] setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusFailedPermanently
                                                                              friendId:friendID
                                                                               videoId:videoId];
                [self deleteRemoteFileAndVideoId:video];
            }
        }
        else
        {
            ZZLogError(@"downloadCompletedWithFriend: ERROR: unrecognized videoId");
        }
    
}


- (void)downloadRetryingWithFriendID:(NSString*)friendID videoId:(NSString *)videoId retryCount:(NSInteger)retryCount
{
    TBMVideo *video = [ZZVideoDataProvider findWithVideoId:videoId];

    if (!ANIsEmpty(video))
    {
        TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];
        ZZLogInfo(@"downloadRetryingWithFriend %@ retryCount= %@", friend.firstName, @(retryCount));
        [self.delegate setAndNotifyDownloadRetryCount:retryCount withFriend:friend video:video];
    }
    else
    {
        ZZLogError(@"downloadRetryingWithFriend: ERROR: unrecognized videoId");
    }
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
    [[self fileTransferManager] currentTransferStateWithCompletionHandler:^(NSArray *allTransferInfo) {

        ZZLogInfo(@"handleStuckDownloads: (%lu)", (unsigned long) [ZZVideoDataProvider countDownloadingVideos]);
         NSArray *allObInfo = [[self fileTransferManager] currentState];
        
         for (TBMVideo *video in [ZZVideoDataProvider downloadingEntities])
         {
             NSDictionary *obInfo = [self infoWithVideo:video isUpload:NO allInfo:allObInfo];
             NSDictionary *transferInfo = [self infoWithVideo:video isUpload:NO allInfo:allTransferInfo];
             
             if (obInfo == nil)
             {
                 ZZLogWarning(@"AppSync.handleStuckDownloads: Got no obInfo for vid:%@ double checking to make sure hasnt completed.", video.videoId);
                 
                 if ([ZZVideoDataProvider isStatusDownloadingWithVideo:video])
                 {
                     ZZLogError(@"AppSync.handleStuckDownloads: Got no obInfo for vid:%@ this should not happen. Force requeue the video.", video.videoId);
                     [self _queueDownloadWithFriendID:video.friend.idTbm videoId:video.videoId force:YES];
                 }
                 
             }
             else if ([self isPendingRetryWithObInfo:obInfo])
             {
                 ZZLogInfo(@"AppSync.handleStuckDownloads: Ignoring video pending retry: %@.", video.videoId);
                 
             }
             else if (![self isPendingRetryWithObInfo:obInfo] && transferInfo == nil)
             {
                 ZZLogWarning(@"AppSync.handleStuckDownloads: Got no transferInfo for vid:%@ could be due to termination by user during download. Restarting the task.", video.videoId);
                 [self restartDownloadWithVideo:video];
                 
             }
             else if ([self transferTaskStuckWithTransferInfo:transferInfo])
             {
                 ZZLogWarning(@"AppSync.handleStuckDownloads: Restarting stuck download: %@.", video.videoId);
                 [self restartDownloadWithVideo:video];
                 
             }
             else
             {
                 ZZLogInfo(@"AppSync.handleStuckDownloads: Ignoring video already processing: %@.", video.videoId);
             }
         }
         handler();
     }];
}

- (BOOL)transferTaskStuckWithTransferInfo:(NSDictionary *)transferInfo
{
    BOOL transferValidation = NO;
    
    if (!ANIsEmpty(transferInfo))
    {
        NSDate *createdOn = transferInfo[CreatedOnKey];
        NSNumber *bytesReceived = transferInfo[CountOfBytesReceivedKey];
        NSTimeInterval age = -[createdOn timeIntervalSinceNow];
        ZZLogDebug(@"isStuckWithVideo: age=%f, bytesReceived=%@", age, bytesReceived);
        if (age > 0.25 && ([bytesReceived integerValue] == 0))
        {
            ZZLogInfo(@"isStuckWithVideo: YES");
            transferValidation = YES;
        }
        else
        {
            ZZLogInfo(@"isStuckWithVideo: NO");
            transferValidation = NO;
        }
    }
    else
    {
        ZZLogError(@"AppSync.transferTaskStuckWithTransferInfo: nil transferInfo. This should never happen.");
    }
    
    return transferValidation;
}

- (BOOL)isPendingRetryWithObInfo:(NSDictionary *)obInfo
{
    BOOL retryEnabled = NO;
    
    if (!ANIsEmpty(obInfo))
    {
        retryEnabled = [obInfo[StatusKey] integerValue] == FileTransferPendingRetry;
    }
    else
    {
        ZZLogError(@"AppSync: isPendingRetryWithVideo: got nil obInfo. Should never happen.");
    }
    
    return retryEnabled;
}

- (void)restartDownloadWithVideo:(TBMVideo *)video
{
    NSString *marker = [TBMVideoIdUtils markerWithFriendID:[video friend].idTbm videoID:video.videoId isUpload:NO];
    [[self fileTransferManager] restartTransfer:marker onComplete:nil];
}

- (NSDictionary *)infoWithVideo:(TBMVideo *)video isUpload:(BOOL)isUpload allInfo:(NSArray *)allInfo
{
    __block NSDictionary* videoInfo = nil;

    NSString* marker = [TBMVideoIdUtils markerWithFriendID:[video friend].idTbm videoID:video.videoId isUpload:isUpload];
    [allInfo enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* dMarker = [object objectForKey:MarkerKey];
        if ([dMarker isEqualToString:marker])
        {
            videoInfo = object;
            *stop = YES;
        }
    }];
    
    return videoInfo;
}

//---------
// Download
//---------
- (void)queueDownloadWithFriendID:(NSString*)friendID videoId:(NSString *)videoId
{
    [self _queueDownloadWithFriendID:friendID videoId:videoId force:NO];
}

- (void)_queueDownloadWithFriendID:(NSString*)friendID videoId:(NSString*)videoId force:(BOOL)force
{
    if (!ANIsEmpty(videoId) && !ANIsEmpty(friendID))
    {
        TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];
        
        if ([ZZFriendDataHelper isFriend:friend hasIncomingVideoWithId:videoId] && !force)
        {
            ZZLogWarning(@"queueVideoDownloadWithFriend: Ignoring incoming videoId already processed.");
        }
        else
        {
                TBMVideo *video;
                if ([ZZFriendDataHelper isFriend:friend hasIncomingVideoWithId:videoId] && force)
                {
                    ZZLogInfo(@"queueVideoDownloadWithFriend: Forcing new transfer of existing video: %@", videoId);
                    video = [ZZVideoDataProvider findWithVideoId:videoId];
                }
                else
                {
                    ZZLogInfo(@"queueVideoDownloadWithFriend: Creating new video for download: %@", videoId);
                    video = [ZZVideoDataProvider createIncomingVideoForFriend:friend withVideoId:videoId];
                }
                
                if (!ANIsEmpty(video))
                {
                    [self.delegate deleteViewedVideoIfNeededWithFriendId:friendID];
                    [self.delegate setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusDownloading friendId:friendID videoId:videoId];
                    [self.delegate updateBadgeCounter];
                    
                    NSString *marker = [TBMVideoIdUtils markerWithFriendID:friend.idTbm videoID:videoId isUpload:NO];
                    
                    NSString *remoteFilename = [ZZRemoteStorageValueGenerator incomingVideoRemoteFilenameWithFriendMkey:video.friend.mkey
                                                                                                             friendCKey:video.friend.ckey
                                                                                                                videoId:video.videoId];
                    
                    [[self fileTransferManager] downloadFile:remoteStorageFileTransferDownloadPath()
                                                          to:[ZZVideoDataProvider videoUrlWithVideo:video].path
                                                  withMarker:marker
                                                  withParams:[self fileTransferParams:remoteFilename]];
                }
                else
                {
                    ZZLogWarning(@"queueVideoDownloadWithFriend: Ignoring incoming videoId already processed.");
                }
            
        }
    }
}

- (NSDictionary*)fileTransferParams:(NSString *)remoteFilename
{
    return @{@"filename"         : remoteFilename,
             FilenameParamKey    : remoteFilename,
             ContentTypeParamKey : @"video/mp4"};
}



//-------
// Delete
//-------

- (void)deleteRemoteFileAndVideoId:(TBMVideo *)video
{
    // GARF: TODO: We should delete the remoteVideoId from remoteVideoIds only if file deletion is successful so we dont leave hanging
    // files. This is not a problem on s3 as old videos are automatically deleted by the server.
    
    NSString *filename = [ZZRemoteStorageValueGenerator incomingVideoRemoteFilenameWithFriendMkey:video.friend.mkey
                                                                                       friendCKey:video.friend.ckey
                                                                                          videoId:video.videoId];
    ZZLogInfo(@"deleteRemoteFile: deleting: %@", filename);
    if (kRemoteStorageShouldUseS3)
    {
        NSString *full = [NSString stringWithFormat:@"%@/%@", remoteStorageFileTransferDeletePath(), filename];
        NSError *e = [[self fileTransferManager] deleteFile:full];
        if (e != nil)
        {
            ZZLogError(@"ftmDelete: Error trying to delete remote file. This should never happen. %@", e);
        }
    }
    else
    {
        [[ZZVideoNetworkTransportService deleteVideoFileWithName:filename] subscribeNext:^(id x) {}];
    }
    
    [[ZZRemoteStoageTransportService deleteRemoteIncomingVideoWithItemID:video.videoId
                                                              friendMkey:video.friend.mkey
                                                              friendCKey:video.friend.ckey] subscribeNext:^(id x) {}];
}


#pragma mark - Private

- (OBFileTransferManager*)fileTransferManager
{
    return [OBFileTransferManager instance];
}

@end

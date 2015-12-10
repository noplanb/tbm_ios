//
//  ZZVideoFileHandler.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoFileHandler.h"
#import "ZZS3CredentialsDomainModel.h"
#import "ZZRemoteStorageConstants.h"
#import "ZZThumbnailGenerator.h"
#import "ZZVideoDomainModel.h"
#import "ZZFriendDataProvider.h"
#import "ZZFriendDataUpdater.h"
#import "ZZRemoteStoageTransportService.h"
#import "ZZCommonNetworkTransportService.h"
#import "ZZStoredSettingsManager.h"
#import "ZZVideoDataProvider.h"
#import "ZZNotificationsConstants.h"
#import "ZZRemoteStorageValueGenerator.h"
#import "ZZVideoNetworkTransportService.h"
#import "ZZFileTransferMarkerDomainModel.h"
#import "ZZVideoStatuses.h"
#import "ZZVideoStatusHandler.h"
#import "ZZFriendDataHelper.h"

#import "TBMVideoIdUtils.h"
#import "OBFileTransferManager.h"



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
            [self _downloadCompletedWithFriendId:markerModel.friendID videoId:markerModel.videoID error:error];
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
    if (!ANIsEmpty(error) && error.code != 404)
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
    
    ZZFriendDomainModel* friend = [ZZFriendDataProvider friendWithItemID:markerModel.friendID];
    //TODO: remove this
    
    NSString *remoteFilename = [ZZRemoteStorageValueGenerator outgoingVideoRemoteFilenameWithFriendMkey:friend.mKey
                                                                                             friendCKey:friendCKey
                                                                                                videoId:markerModel.videoID];
    NSDictionary *params = [self fileTransferParamsIncludingMetadataWithFilename:remoteFilename
                                                                      friendMkey:friend.mKey
                                                                         videoId:markerModel.videoID];
    
    [[self fileTransferManager] uploadFile:videoUrl.path
                                        to:remoteStorageFileTransferUploadPath()
                                withMarker:marker
                                withParams: params];
    
    // fileTransferManager should create a copy of ougtoing file synchronously
    // prior to returning from the above call so should be safe to delete video file here.
    [[NSFileManager defaultManager] removeItemAtURL:videoUrl error:nil];
    
    
    [self.delegate notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusUploading withFriendID:friend.idTbm videoId:markerModel.videoID];
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
        [self.delegate setAndNotifyUploadRetryCount:retryCount withFriendID:friendID videoID:videoId];
    }
    else
    {
        ZZLogError(@"uploadRetryingWithFriend - Could not find friend with marker");
    }
}

- (void)_uploadCompletedWithFriendID:(NSString*)friendID videoId:(NSString *)videoId error:(NSError *)error
{
    ZZFriendDomainModel* friend = [ZZFriendDataProvider friendWithItemID:friendID];

    if (!ANIsEmpty(friend))
    {
        if (ANIsEmpty(error))
        {
            ZZLogInfo(@"uploadCompletedWithFriend");

            if (!friend.everSent)
            {
                friend.everSent = YES;
                [ZZFriendDataUpdater upsertFriend:friend];
            }
            
            [self.delegate notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusUploaded withFriendID:friendID videoId:videoId];
            
//            [[ZZRemoteStoageTransportService addRemoteOutgoingVideoWithItemID:videoId
//                                                                   friendMkey:friend.mkey
//                                                                   friendCKey:friend.ckey] subscribeNext:^(id x) {}];
            
            NSString* myMkey = [ZZStoredSettingsManager shared].userID;
            
            [[ZZRemoteStoageTransportService updateRemoteEverSentKVForFriendMkeys:[ZZFriendDataHelper everSentMkeys]
                                                                      forUserMkey:myMkey] subscribeNext:^(id x) {}];

        }
        else
        {
            ZZLogError(@"Upload error. FailedPermanently");
            [self.delegate notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusFailedPermanently withFriendID:friendID videoId:videoId];
        }
    }
    else
    {
        ZZLogError(@"Could not find friend with marker.");
    }
}

//----------------
// Download events
//----------------
- (void)_downloadCompletedWithFriendId:(NSString*)friendId videoId:(NSString *)videoId error:(NSError *)error
{
    // Whether successful, failed permanently, or unrecognized video we always want to try to
    // delete the remote video and received kv as we don't ever want to try again.
    [self _deleteRemoteWithFriendId:friendId videoId:videoId];

    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:friendId];
    ZZVideoDomainModel *videoModel = [ZZVideoDataProvider findWithVideoId:videoId];

    if (!videoModel)
    {
        ZZLogError(@"unrecognized videoId");
        return;
    }

    if (!error)
    {
        BOOL validThumb = [ZZThumbnailGenerator generateThumbVideo:videoModel];
        
        if (validThumb)
        {
            ANDispatchBlockToMainQueue(^{
                [self.delegate deleteAllViewedOrFailedVideosWithFriendId:friendId];
            });
        }
        
        [self.delegate setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusDownloaded friendId:friendId videoId:videoId];

        [[ZZRemoteStoageTransportService updateRemoteStatusForVideoWithItemID:videoId
                                                                     toStatus:ZZRemoteStorageVideoStatusDownloaded
                                                                   friendMkey:friendModel.mKey
                                                                   friendCKey:friendModel.cKey] subscribeNext:^(id x) {}];
        
        [self.delegate sendNotificationForVideoStatusUpdate:friendModel videoId:videoId status:NOTIFICATION_STATUS_DOWNLOADED];
        
        [self.delegate updateBadgeCounter];
//
        ZZLogInfo(@"Video count = %ld", (unsigned long) [ZZVideoDataProvider countAllVideos]);
    }
    else  // error
    {
        ZZLogError(@"%@", error);
        [[ZZVideoStatusHandler sharedInstance] setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusFailedPermanently
                                                                      friendId:friendId
                                                                       videoId:videoId];
    }
    
}


- (void)downloadRetryingWithFriendID:(NSString*)friendID videoId:(NSString *)videoId retryCount:(NSInteger)retryCount
{
    ZZVideoDomainModel *video = [ZZVideoDataProvider findWithVideoId:videoId];

    if (video)
    {
        ZZFriendDomainModel* friend = [ZZFriendDataProvider friendWithItemID:friendID];
        
        ZZLogInfo(@"downloadRetryingWithFriend %@ retryCount= %@", friend.firstName, @(retryCount));
        [self.delegate setAndNotifyDownloadRetryCount:retryCount withFriendID:friendID videoID:videoId];
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

        for (ZZVideoDomainModel *video in [ZZVideoDataProvider downloadingItems])
        {
            NSDictionary *obInfo = [self _infoWithVideo:video isUpload:NO allInfo:allObInfo];
            NSDictionary *transferInfo = [self _infoWithVideo:video isUpload:NO allInfo:allTransferInfo];
            
            if (obInfo == nil)
            {
                ZZLogWarning(@"AppSync.handleStuckDownloads: Got no obInfo for vid:%@ double checking to make sure hasnt completed.", video.videoID);
                
                if ([ZZVideoDataProvider isStatusDownloadingWithVideo:video])
                {
                    ZZLogError(@"AppSync.handleStuckDownloads: Got no obInfo for vid:%@ this should not happen. Force requeue the video.", video.videoID);
                    [self _queueDownloadWithFriendID:video.relatedUserID videoId:video.videoID force:YES];
                }
                
            }
            else if ([self isPendingRetryWithObInfo:obInfo])
            {
                ZZLogInfo(@"AppSync.handleStuckDownloads: Ignoring video pending retry: %@.", video.videoID);
                
            }
            else if (![self isPendingRetryWithObInfo:obInfo] && transferInfo == nil)
            {
                ZZLogWarning(@"AppSync.handleStuckDownloads: Got no transferInfo for vid:%@ could be due to termination by user during download. Restarting the task.", video.videoID);
                [self _restartDownloadWithVideo:video];
                
            }
            else if ([self transferTaskStuckWithTransferInfo:transferInfo])
            {
                ZZLogWarning(@"AppSync.handleStuckDownloads: Restarting stuck download: %@.", video.videoID);
                [self _restartDownloadWithVideo:video];
                
            }
            else
            {
                ZZLogInfo(@"AppSync.handleStuckDownloads: Ignoring video already processing: %@.", video.videoID);
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

- (void)_restartDownloadWithVideo:(ZZVideoDomainModel *)video
{
    NSString *marker = [TBMVideoIdUtils markerWithFriendID:video.relatedUserID videoID:video.videoID isUpload:NO];
    [[self fileTransferManager] restartTransfer:marker onComplete:nil];
}

- (NSDictionary *)_infoWithVideo:(ZZVideoDomainModel *)video isUpload:(BOOL)isUpload allInfo:(NSArray *)allInfo
{
    __block NSDictionary* videoInfo = nil;
  
    NSString* marker = [TBMVideoIdUtils markerWithFriendID:video.relatedUserID videoID:video.videoID isUpload:isUpload];
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
        BOOL hasIncomingVideo = [ZZFriendDataHelper isFriendWithId:friendID hasIncomingVideoWithId:videoId];
        if (hasIncomingVideo && !force)
        {
            ZZLogWarning(@"queueVideoDownloadWithFriend: Ignoring incoming videoId already processed.");
        }
        else
        {
            ZZVideoDomainModel *video;
            if (hasIncomingVideo && force)
            {
                ZZLogInfo(@"queueVideoDownloadWithFriend: Forcing new transfer of existing video: %@", videoId);
                video = [ZZVideoDataProvider findWithVideoId:videoId];
            }
            else
            {
                ZZLogInfo(@"queueVideoDownloadWithFriend: Creating new video for download: %@", videoId);
                video = [ZZVideoDataProvider createIncomingVideoForFriendId:friendID withVideoId:videoId];
            }
            
            if (!ANIsEmpty(video))
            {
                [self.delegate setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusDownloading friendId:friendID videoId:videoId];
                
                
                NSString *marker = [TBMVideoIdUtils markerWithFriendID:friendID videoID:videoId isUpload:NO];
                
                ZZFriendDomainModel* friend = [ZZFriendDataProvider friendWithItemID:friendID];
                
                NSString *remoteFilename = [ZZRemoteStorageValueGenerator incomingVideoRemoteFilenameWithFriendMkey:friend.mKey
                                                                                                         friendCKey:friend.cKey
                                                                                                            videoId:video.videoID];
                
                [[self fileTransferManager] downloadFile:remoteStorageFileTransferDownloadPath()
                                                      to:[ZZVideoDataProvider videoUrlWithVideo:video].path
                                              withMarker:marker
                                              withParams:[self fileTransferParamsWithFilename:remoteFilename]];
            }
            else
            {
                ZZLogWarning(@"queueVideoDownloadWithFriend: Ignoring incoming videoId already processed.");
            }
            
        }
    }
}

#pragma mark - File Transfer Params

- (NSDictionary*)fileTransferParamsWithFilename:(NSString *)remoteFilename
{
    return @{@"filename"                   : remoteFilename,
             FilenameParamKey              : remoteFilename,
             ContentTypeParamKey           : @"video/mp4",
             };
}


- (NSDictionary*)fileTransferParamsIncludingMetadataWithFilename:(NSString *)remoteFilename
                         friendMkey:(NSString *)friendMkey
                            videoId:(NSString *)videoId
{
    NSMutableDictionary *common = [NSMutableDictionary dictionaryWithDictionary:[self fileTransferParamsWithFilename:remoteFilename]];
    
    NSDictionary *metadata = @{
                               @"video-id"        : videoId,
                               @"sender-mkey"     : [ZZStoredSettingsManager shared].userID,
                               @"receiver-mkey"   : friendMkey,
                               @"client-version"  : kGlobalApplicationVersion,
                               @"client-platform" : @"ios",
                               };
    
    common[kOBFileTransferMetadataKey] = metadata;
    return [NSDictionary dictionaryWithDictionary:common];
}



//-------
// Delete
//-------

- (void)_deleteRemoteWithFriendId:(NSString *)friendId videoId:(NSString *)videoId
{
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithItemID:friendId];
    
    if (ANIsEmpty(friendModel))
    {
        ZZLogWarning(@"Unrecognized friendId. Unable to delete remote. This could happen if you are testing and delete a user using the admin console");
        return;
    }

    NSString *filename = [ZZRemoteStorageValueGenerator incomingVideoRemoteFilenameWithFriendMkey:friendModel.mKey
                                                                                       friendCKey:friendModel.cKey
                                                                                          videoId:videoId];
    
    ANDispatchBlockToBackgroundQueue(^{
        ZZLogInfo(@"deleteRemoteS3VideoFile: deleting: %@", filename);
        NSString *full = [NSString stringWithFormat:@"%@/%@", remoteStorageFileTransferDeletePath(), filename];
        NSError *e = [[self fileTransferManager] deleteFile:full];
        if (e != nil)
        {
            ZZLogError(@"ftmDelete: Error trying to delete remote file. This should never happen. %@", e);
        }

        [[ZZRemoteStoageTransportService deleteRemoteIncomingVideoWithItemID:videoId
                                                                  friendMkey:friendModel.mKey
                                                                  friendCKey:friendModel.cKey] subscribeNext:^(id x) {}];
    });
}


#pragma mark - Private

- (OBFileTransferManager*)fileTransferManager
{
    return [OBFileTransferManager instance];
}

@end

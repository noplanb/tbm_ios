//
//  ZZVideoFileHandler.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoDataProvider+Entities.h"
#import "OBFileTransferManager.h"
#import "ZZS3CredentialsDomainModel.h"
#import "ZZRemoteStorageConstants.h"
#import "ZZThumbnailGenerator.h"
#import "ZZVideoDomainModel.h"
#import "ZZRemoteStorageTransportService.h"
#import "ZZCommonNetworkTransportService.h"
#import "TBMVideoIdUtils.h"
#import "ZZStoredSettingsManager.h"
#import "ZZNotificationsConstants.h"
#import "ZZRemoteStorageValueGenerator.h"
#import "ZZVideoNetworkTransportService.h"
#import "ZZFileTransferMarkerDomainModel.h"
#import "ZZVideoStatuses.h"
#import "ZZVideoStatusHandler.h"
#import "ZZVideoFileHandler.h"
#import "ZZVideoDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZFriendDataHelper.h"
#import "ZZFriendDomainModel.h"
#import "ZZFriendDataUpdater.h"
#import "ZZVideoDataUpdater.h"
#import "ZZFileHelper.h"

@interface ZZVideoFileHandler () <OBFileTransferDelegate>

@property (nonatomic, strong, readonly) OBFileTransferManager* fileTransferManager;
@property (nonatomic, assign) BOOL shouldDuplicateNextUpload; // For duplicate uploads debug

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(shouldDuplicateNextUploadNotification:)
                                                     name:kShouldDuplicateNextUploadNotificationKey
                                                   object:nil];
        
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

- (void)resetAllTasksCompletion:(void(^)())completion
{
    [self.fileTransferManager reset:completion];
}

- (void)updateCredentials
{
    [self _updateCredentials];
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

- (void)shouldDuplicateNextUploadNotification:(NSNotification *)notification
{
    self.shouldDuplicateNextUpload = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    ZZLogInfo(@"fileTransferRetrying: %@ attemptCount: %lu", marker, (unsigned long)attemptCount);
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
    NSString *marker = [videoUrl URLByDeletingPathExtension].lastPathComponent;
    ZZFileTransferMarkerDomainModel* markerModel = [ZZFileTransferMarkerDomainModel modelWithEncodedMarker:marker];
    
    ZZLogInfo(@"uploadWithVideoUrl = %@ | marker = %@", videoUrl, marker);
    
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithItemID:markerModel.friendID];
    //TODO: remove this
    
    NSString *remoteFilename = [ZZRemoteStorageValueGenerator outgoingVideoRemoteFilenameWithFriendMkey:friendModel.mKey
                                                                                             friendCKey:friendCKey
                                                                                                videoId:markerModel.videoID];
    NSDictionary *params =
    [self fileTransferParamsIncludingMetadataWithFilename:remoteFilename
                                               friendMkey:friendModel.mKey
                                                  videoId:markerModel.videoID
                                                 filesize:[ZZFileHelper fileSizeWithURL:videoUrl]];
    
    if (self.shouldDuplicateNextUpload)
    {
        self.shouldDuplicateNextUpload = NO;
        
        for (NSUInteger i = 0; i < 3; i++)
        {
            params =
            [self fileTransferParamsIncludingMetadataWithFilename:remoteFilename
                                                       friendMkey:friendModel.mKey
                                                          videoId:markerModel.videoID
                                                         filesize:[ZZFileHelper fileSizeWithURL:videoUrl]];

            [[self fileTransferManager] uploadFile:videoUrl.path
                                                to:remoteStorageFileTransferUploadPath()
                                        withMarker:marker
                                        withParams:params];
            
        }
    }
    
    else
    {
        [[self fileTransferManager] uploadFile:videoUrl.path
                                            to:remoteStorageFileTransferUploadPath()
                                    withMarker:marker
                                    withParams: params];
    }
    
    // fileTransferManager should create a copy of ougtoing file synchronously
    // prior to returning from the above call so should be safe to delete video file here.
    [[NSFileManager defaultManager] removeItemAtURL:videoUrl error:nil];
    
    
    [self.delegate notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusUploading withFriendID:friendModel.idTbm videoId:markerModel.videoID];
}

//--------------
// Upload events
//--------------

- (void)uploadRetryingWithFriendID:(NSString*)friendID videoId:(NSString *)videoID retryCount:(NSInteger)retryCount
{
    BOOL isExist = [ZZFriendDataProvider isFriendExistsWithItemID:friendID];
    ZZLogInfo(@"videoUploadRetrying: %@ withFriend: %@ retryCount=%ld", videoID, friendID, (long) retryCount);
    if (isExist)
    {
        [self.delegate setAndNotifyUploadRetryCount:retryCount withFriendID:friendID videoID:videoID];
    }
    else
    {
        ZZLogError(@"uploadRetryingWithFriend - Could not find friend with marker");
    }
}

- (void)_uploadCompletedWithFriendID:(NSString*)friendID videoId:(NSString *)videoId error:(NSError *)error
{
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithItemID:friendID];

    if (!ANIsEmpty(friendModel))
    {
        if (ANIsEmpty(error))
        {
            ZZLogInfo(@"Video upload completed: %@ with friend: %@", videoId, friendID);
            
            if (!friendModel.everSent)
            {
                [ZZFriendDataUpdater updateEverSentFriendsWithMkeys:@[friendModel.mKey]];
            }
            
            [self.delegate notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusUploaded withFriendID:friendID videoId:videoId];
            
            //            [[ZZRemoteStorageTransportService addRemoteOutgoingVideoWithItemID:videoId
            //                                                                   friendMkey:friend.mkey
            //                                                                   friendCKey:friend.ckey] subscribeNext:^(id x) {}];
            
            NSString* myMkey = [ZZStoredSettingsManager shared].userID;
            
            [[ZZRemoteStorageTransportService updateRemoteEverSentKVForFriendMkeys:[ZZFriendDataHelper everSentMkeys]
                                                                       forUserMkey:myMkey] subscribeNext:^(id x) {}];
            
            
        }
        else
        {
            ZZLogInfo(@"Video failed permanently: %@ with friend: %@", videoId, friendID);
            [self.delegate notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusFailedPermanently withFriendID:friendID videoId:videoId];
        }
    }
    else
    {
        ZZLogWarning(@"Could not find friend: %@", friendID);
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
    ZZVideoDomainModel *videoModel = [ZZVideoDataProvider itemWithID:videoId];

    if (ANIsEmpty(videoModel))
    {
        ZZLogError(@"Unrecognized video: %@", videoId);
        return;
    }


    if (ANIsEmpty(error))
    {
        BOOL validThumb = [ZZThumbnailGenerator generateThumbVideo:videoModel];
        
        if (validThumb)
        {
            [ZZVideoDataUpdater deleteAllViewedOrFailedVideoWithFriendID:friendId];
        }
        
        [self.delegate setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusDownloaded friendId:friendId videoId:videoId];
        
        [[ZZRemoteStorageTransportService updateRemoteStatusForVideoWithItemID:videoId
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
        ZZLogError(@"VideoID %@ Error: %@", videoId, error);
        [[ZZVideoStatusHandler sharedInstance] setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusFailedPermanently
                                                                      friendId:friendId
                                                                       videoId:videoId];
    }
    
}


- (void)downloadRetryingWithFriendID:(NSString*)friendID videoId:(NSString *)videoId retryCount:(NSInteger)retryCount
{
    ZZVideoDomainModel *videoModel = [ZZVideoDataProvider itemWithID:videoId];

    ZZLogInfo(@"Video %@ download retrying with friend %@ retryCount= %@", videoId, friendID, @(retryCount));
    
    if (!ANIsEmpty(videoModel))
    {
        [self.delegate setAndNotifyDownloadRetryCount:retryCount withFriendID:friendID videoID:videoId];
    }
    else
    {
        ZZLogError(@"downloadRetryingWithFriend failed -- unrecognized videoId: %@", videoId);
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
        
         for (ZZVideoDomainModel *videoModel in [ZZVideoDataProvider downloadingVideos])
         {
             NSDictionary *obInfo = [self infoWithVideo:videoModel isUpload:NO allInfo:allObInfo];
             NSDictionary *transferInfo = [self infoWithVideo:videoModel isUpload:NO allInfo:allTransferInfo];
             
             if (obInfo == nil)
             {
                 ZZLogWarning(@"AppSync.handleStuckDownloads: Got no obInfo for vid:%@ double checking to make sure hasnt completed.", videoModel.videoID);
                 
                 if (videoModel.incomingStatusValue == ZZVideoIncomingStatusDownloading)
                 {
                     ZZLogError(@"AppSync.handleStuckDownloads: Got no obInfo for vid:%@ this should not happen. Force requeue the video.", videoModel.videoID);
                     [self _queueDownloadWithFriendID:videoModel.relatedUserID videoId:videoModel.videoID force:YES];
                 }
             }
             else if ([self isPendingRetryWithObInfo:obInfo])
             {
                 ZZLogInfo(@"AppSync.handleStuckDownloads: Ignoring video pending retry: %@.", videoModel.videoID);
                 
             }
             else if (![self isPendingRetryWithObInfo:obInfo] && transferInfo == nil)
             {
                 ZZLogWarning(@"AppSync.handleStuckDownloads: Got no transferInfo for vid:%@ could be due to termination by user during download. Restarting the task.", videoModel.videoID);
                 [self restartDownloadWithVideo:videoModel];
                 
             }
             else if ([self transferTaskStuckWithTransferInfo:transferInfo])
             {
                 ZZLogWarning(@"AppSync.handleStuckDownloads: Restarting stuck download: %@.", videoModel.videoID);
                 [self restartDownloadWithVideo:videoModel];
                 
             }
             else
             {
                 ZZLogInfo(@"AppSync.handleStuckDownloads: Ignoring video already processing: %@.", videoModel.videoID);
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

- (void)restartDownloadWithVideo:(ZZVideoDomainModel *)video
{
    NSString *marker = [TBMVideoIdUtils markerWithFriendID:video.relatedUserID videoID:video.videoID isUpload:NO];
    ZZLogInfo(@"restartDownloadWithVideo: %@", marker);
    [[self fileTransferManager] restartTransfer:marker onComplete:nil];
}

- (NSDictionary *)infoWithVideo:(ZZVideoDomainModel *)video isUpload:(BOOL)isUpload allInfo:(NSArray *)allInfo
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

- (void)_queueDownloadWithFriendID:(NSString*)friendID videoId:(NSString*)videoID force:(BOOL)force
{
    if (!ANIsEmpty(videoID) && !ANIsEmpty(friendID))
    {
        ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithItemID:friendID];
        
        if ([ZZVideoDataProvider videoExists:videoID] && !force)
        {
            ZZLogWarning(@"queueVideoDownloadWithFriend: Ignoring incoming videoId already processed: %@", videoID);
        }
        else
        {
                ZZVideoDomainModel *videoModel;
                if ([ZZVideoDataProvider videoExists:videoID] && force)
                {
                    ZZLogInfo(@"queueVideoDownloadWithFriend: Forcing new transfer of existing video: %@", videoID);
                    videoModel = [ZZVideoDataProvider itemWithID:videoID];
                }
                else
                {
                    ZZLogInfo(@"queueVideoDownloadWithFriend: Creating new video for download: %@", videoID);
                    videoModel = [ZZVideoDataProvider createIncomingVideoModelForFriend:friendModel withVideoID:videoID];
                }
                
                NSString *marker = [TBMVideoIdUtils markerWithFriendID:friendID videoID:videoID isUpload:NO];
            
                if (!ANIsEmpty(videoModel))
                {
                    [self.delegate setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusDownloading friendId:friendID videoId:videoID];
                    
                    ZZFriendDomainModel *relatedUser = [ZZFriendDataProvider friendWithItemID:videoModel.relatedUserID];
                    
                    NSString *remoteFilename =
                    [ZZRemoteStorageValueGenerator incomingVideoRemoteFilenameWithFriendMkey:relatedUser.mKey
                                                                                  friendCKey:relatedUser.cKey
                                                                                     videoId:videoModel.videoID];
                    
                    [[self fileTransferManager] downloadFile:remoteStorageFileTransferDownloadPath()
                                                          to:[ZZVideoDataProvider videoUrlWithVideoModel:videoModel].path
                                                  withMarker:marker
                                                  withParams:[self fileTransferParamsWithFilename:remoteFilename]];
                }
                else
                {
                    ZZLogWarning(@"queueVideoDownloadWithFriend: Ignoring incoming videoId already processed: %@", marker);
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
                                                         videoId:(NSString *)videoID
                                                        filesize:(long)filesize
{
    NSMutableDictionary *common = [NSMutableDictionary dictionaryWithDictionary:[self fileTransferParamsWithFilename:remoteFilename]];
    
    if ([ZZStoredSettingsManager shared].shouldSendIncorrectFilesize) 
    {
        filesize = arc4random_uniform(1000000);
    }
    
    NSDictionary *metadata = @{
                               @"video-id"        : videoID,
                               @"sender-mkey"     : [ZZStoredSettingsManager shared].userID,
                               @"receiver-mkey"   : friendMkey,
                               @"client-version"  : kGlobalApplicationVersion,
                               @"client-platform" : @"ios",
                               @"file-size"       : [NSString stringWithFormat:@"%ld", filesize]
                               };
    
    common[kOBFileTransferMetadataKey] = metadata;
    return [NSDictionary dictionaryWithDictionary:common];
}



//-------
// Delete
//-------

- (void)_deleteRemoteWithFriendId:(NSString *)friendID videoId:(NSString *)videoID
{
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithItemID:friendID];
    
    if (ANIsEmpty(friendModel))
    {
        ZZLogWarning(@"Unrecognized friendId %@ Unable to delete remote. This could happen if you are testing and delete a user using the admin console", friendID);
        return;
    }
    
    NSString *filename = [ZZRemoteStorageValueGenerator incomingVideoRemoteFilenameWithFriendMkey:friendModel.mKey
                                                                                       friendCKey:friendModel.cKey
                                                                                          videoId:videoID];
    ANDispatchBlockToBackgroundQueue(^{
        ZZLogInfo(@"deleteRemoteS3VideoFile: deleting: %@", filename);
        NSString *full = [NSString stringWithFormat:@"%@/%@", remoteStorageFileTransferDeletePath(), filename];
        NSError *e = [[self fileTransferManager] deleteFile:full];
        if (e != nil)
        {
            ZZLogError(@"ftmDelete: Error trying to delete remote file %@. This should never happen. %@", full, e);
        }
        
        ZZLogInfo(@"deleteRemoteIncomingVideoWithItemID: %@ friendMkey:%@, friendCKey:%@", videoID, friendModel.mKey, friendModel.cKey);
        
        [[ZZRemoteStorageTransportService deleteRemoteIncomingVideoWithItemID:videoID
                                                                   friendMkey:friendModel.mKey
                                                                   friendCKey:friendModel.cKey] subscribeNext:^(id x) {
            ZZLogInfo(@"deleteRemoteIncomingVideoWithItemID: %@ STARTED", videoID);
        } error:^(NSError *error) {
            ZZLogError(@"deleteRemoteIncomingVideoWithItemID: %@ %@", videoID, error);
        } completed:^{
            ZZLogInfo(@"deleteRemoteIncomingVideoWithItemID: %@ SUCCESS", videoID);
        }];
         
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteFileNotification
                                                            object:nil
                                                          userInfo:@{@"videoID": videoID ?: @""}];
    });
}


#pragma mark - Private

- (OBFileTransferManager*)fileTransferManager
{
    return [OBFileTransferManager instance];
}

@end

//
// Created by Rinat on 27.01.16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZVideoFileHandler.h"
#import "ZZCommonNetworkTransportService.h"
#import "ZZFileTransferMarkerDomainModel.h"
#import "ZZFriendDataProvider.h"
#import "ZZRemoteStorageValueGenerator.h"
#import "ZZFriendDomainModel.h"
#import "ZZFriendDataHelper.h"
#import "ZZVideoDomainModel.h"
#import "ZZVideoDataProvider.h"
#import "ZZKeychainDataProvider.h"
#import "ZZThumbnailGenerator.h"
#import "ZZVideoDataUpdater.h"
#import "ZZRemoteStorageTransportService.h"
#import "ZZNotificationsConstants.h"
#import "ZZVideoStatusHandler.h"
#import "ZZFriendDataUpdater.h"

@interface ZZVideoFileHandler ()


@end

@implementation ZZVideoFileHandler

@synthesize delegate = _delegate;

#pragma mark Initialization



- (instancetype)init
{
    self = [super init];

    if (!self)
    {
        return nil;
    }

//    _transferManager = [AWSS3TransferManager alloc] init

    return self;
}

- (void)startService {

}


- (void)handleBackgroundSessionWithIdentifier:(NSString *)identifier completionHandler:(ANCodeBlock)completionHandler {

}

- (void)_updateCredentials
{

}


#pragma mark Operations

- (void)downloadVideoWithFriendID:(NSString *)friendID videoID:(NSString *)videoID
{
    [self _downloadVideoWithFriendID:friendID videoID:videoID force:NO];
}

- (void)_downloadVideoWithFriendID:(NSString *)friendID videoID:(NSString *)videoID force:(BOOL)force
{
    if (!ANIsEmpty(videoID) && !ANIsEmpty(friendID))
    {
        ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithItemID:friendID];

        if ([ZZFriendDataHelper isFriend:friendModel hasIncomingVideoWithID:videoID] && !force)
        {
            ZZLogWarning(@"queueVideoDownloadWithFriend: Ignoring incoming videoId already processed.");
        }
        else
        {
            ZZVideoDomainModel *videoModel;
            if ([ZZFriendDataHelper isFriend:friendModel hasIncomingVideoWithID:videoID] && force)
            {
                ZZLogInfo(@"queueVideoDownloadWithFriend: Forcing new transfer of existing video: %@", videoID);
                videoModel = [ZZVideoDataProvider itemWithID:videoID];
            }
            else
            {
                ZZLogInfo(@"queueVideoDownloadWithFriend: Creating new video for download: %@", videoID);
                videoModel = [ZZVideoDataProvider createIncomingVideoModelForFriend:friendModel withVideoID:videoID];
            }

            if (!ANIsEmpty(videoModel))
            {
                [self.delegate setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusDownloading friendID:friendID videoID:videoID];

                ZZFriendDomainModel *relatedUser = [ZZFriendDataProvider friendWithItemID:videoModel.relatedUserID];

                NSString *remoteFilename =
                        [ZZRemoteStorageValueGenerator incomingVideoRemoteFilenameWithFriendMkey:relatedUser.mKey
                                                                                      friendCKey:relatedUser.cKey
                                                                                         videoID:videoModel.videoID];

                [self.fileTransfer downloadFile:remoteFilename to:[ZZVideoDataProvider videoUrlWithVideoModel:videoModel] completion:^(NSError *error) {
                    [self videoDownloadCompleted:videoModel.videoID withError:error];
                }];                               ;
            }
            else
            {
                ZZLogWarning(@"queueVideoDownloadWithFriend: Ignoring incoming videoId already processed.");
            }

        }
    }
}

- (void)uploadVideoAtUrl:(NSURL *)videoUrl videoID:(NSString *)videoID friendID:(NSString *)friendID {
    
    ZZLogInfo(@"uploadWithVideoUrl %@", videoUrl);
    
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithItemID:friendID];
    
    NSString *remoteFilename = [ZZRemoteStorageValueGenerator outgoingVideoRemoteFilenameWithFriendMkey:friendModel.mKey
                                                                                             friendCKey:friendModel.cKey
                                                                                                videoID:videoID];

    // fileTransferManager should create a copy of ougtoing file synchronously
    // prior to returning from the above call so should be safe to delete video file here.

    //TODO: Implement copying
//    [[NSFileManager defaultManager] removeItemAtURL:videoUrl error:nil];

    NSDictionary <NSString *, NSString *> *metadata =
    [self metadataWithFilename:remoteFilename
                    friendMkey:friendModel.mKey
                       videoId:videoID];
    
    [self.fileTransfer uploadFile:videoUrl
                               to:remoteFilename
                         metadata:metadata
                       completion:^(NSError *error) {
                           
        [self _uploadVideoCompleted:videoID friendID:friendID withError:error];
                           
    }];
    
    [self.delegate notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusUploading withFriendID:friendID videoID:videoID];
}

#pragma mark Other

- (void)resetAllTasksCompletion:(void (^)())completion {

}

#pragma mark ZZFileTransferDelegate

- (void)_uploadVideoCompleted:(NSString *)videoID
                    friendID:(NSString *)friendID
                   withError:(NSError *)error
{
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithItemID:friendID];

    if (!ANIsEmpty(friendModel))
    {
        if (ANIsEmpty(error))
        {
            ZZLogInfo(@"uploadCompletedWithFriend");
            
            if (!friendModel.everSent)
            {
                [ZZFriendDataUpdater updateEverSentFriendsWithMkeys:@[friendModel.mKey]];
            }
            
            [self.delegate notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusUploaded withFriendID:friendID videoID:videoID];

            NSString* myMkey = [ZZStoredSettingsManager shared].userID;
            
            [[ZZRemoteStorageTransportService updateRemoteEverSentKVForFriendMkeys:[ZZFriendDataHelper everSentMkeys]
                                                                       forUserMkey:myMkey] subscribeNext:^(id x) {}];
            
            
        }
        else
        {
            ZZLogError(@"Upload error. FailedPermanently");
            [self.delegate notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusFailedPermanently
                                            withFriendID:friendID
                                                 videoID:videoID];
        }
    }
    else
    {
        ZZLogError(@"Could not find friend with marker.");
    }
}

- (void)videoDownloadCompleted:(NSString *)videoID withError:(NSError *)error
{
    ZZVideoDomainModel *videoModel = [ZZVideoDataProvider itemWithID:videoID];
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithItemID:videoModel.relatedUserID];

    // Whether successful, failed permanently, or unrecognized video we always want to try to
    // delete the remote video and received kv as we don't ever want to try again.
    [self _deleteRemoteWithFriendID:friendModel.idTbm videoID:videoID];
    
    if (ANIsEmpty(videoModel))
    {
        ZZLogError(@"unrecognized video downloaded");
        return;
    }
    
    if (ANIsEmpty(error))
    {
        BOOL validThumb = [ZZThumbnailGenerator generateThumbVideo:videoModel];
        
        if (validThumb)
        {
            [ZZVideoDataUpdater deleteAllViewedOrFailedVideoWithFriendID:friendModel.idTbm];
        }
        
        [self.delegate setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusDownloaded
                                              friendID:friendModel.idTbm
                                               videoID:videoID];
        
        [[ZZRemoteStorageTransportService updateRemoteStatusForVideoWithItemID:videoID
                                                                      toStatus:ZZRemoteStorageVideoStatusDownloaded
                                                                    friendMkey:friendModel.mKey
                                                                    friendCKey:friendModel.cKey] subscribeNext:^(id x) {}];
        
        [self.delegate sendNotificationForVideoStatusUpdate:friendModel
                                                    videoID:videoID
                                                     status:NOTIFICATION_STATUS_DOWNLOADED];
        
        [self.delegate updateBadgeCounter];
        //
        ZZLogInfo(@"Video count = %ld", (unsigned long) [ZZVideoDataProvider countAllVideos]);
    }
    else  // error
    {
        ZZLogError(@"%@", error);
        [[ZZVideoStatusHandler sharedInstance] setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusFailedPermanently
                                                                      friendID:friendModel.idTbm
                                                                       videoID:videoID];
    }
}

- (void)_deleteRemoteWithFriendID:(NSString *)friendID videoID:(NSString *)videoID
{
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithItemID:friendID];
    
    if (ANIsEmpty(friendModel))
    {
        ZZLogWarning(@"Unrecognized friendId. Unable to delete remote. This could happen if you are testing and delete a user using the admin console");
        return;
    }
    
    NSString *filename = [ZZRemoteStorageValueGenerator incomingVideoRemoteFilenameWithFriendMkey:friendModel.mKey
                                                                                       friendCKey:friendModel.cKey
                                                                                          videoID:videoID];
    
        ZZLogInfo(@"deleteRemoteS3VideoFile: deleting: %@", filename);
//        NSString *full = [NSString stringWithFormat:@"%@/%@", remoteStorageFileTransferDeletePath(), filename];
    
        [self.fileTransfer deleteFile:filename completion:^(NSError *error) {
            
            if (error != nil)
            {
                ZZLogError(@"ftmDelete: Error trying to delete remote file. This should never happen. %@", error);
            }

            [[ZZRemoteStorageTransportService deleteRemoteIncomingVideoWithItemID:videoID
                                                                       friendMkey:friendModel.mKey
                                                                       friendCKey:friendModel.cKey] subscribeNext:^(id x) {}];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteFileNotification object:nil];

        }];
        
    
}

- (NSDictionary <NSString *, NSString *> *)metadataWithFilename:(NSString *)remoteFilename
                                                     friendMkey:(NSString *)friendMkey
                                                        videoId:(NSString *)videoID
{

    NSDictionary <NSString *, NSString *> *metadata = @{
                               @"x-amz-meta-video-id"        : videoID,
                               @"x-amz-meta-sender-mkey"     : [ZZStoredSettingsManager shared].userID,
                               @"x-amz-meta-receiver-mkey"   : friendMkey,
                               @"x-amz-meta-client-version"  : kGlobalApplicationVersion,
                               @"x-amz-meta-client-platform" : @"ios",
                               };
    
    return metadata;
}


@end
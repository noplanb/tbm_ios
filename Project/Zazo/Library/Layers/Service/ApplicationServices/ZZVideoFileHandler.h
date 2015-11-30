//
//  ZZVideoFileHandler.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoStatuses.h"

@class TBMFriend;
@class TBMVideo;

@protocol ZZVideoFileHandlerDelegate <NSObject>

- (void)requestBackground;

- (void)sendNotificationForVideoReceived:(TBMFriend *)friendModel videoId:(NSString *)videoId;
- (void)sendNotificationForVideoStatusUpdate:(TBMFriend *)friendModel videoId:(NSString *)videoId status:(NSString *)status;
- (void)updateBadgeCounter;
- (void)updateDataRequired;


- (void)notifyOutgoingVideoWithStatus:(ZZVideoOutgoingStatus)status withFriendID:(NSString*)friendID videoId:(NSString*)videoId;
- (void)setAndNotifyUploadRetryCount:(NSInteger)count withFriendID:(NSString*)friendID videoID:(NSString*)videoID;
- (void)setAndNotifyIncomingVideoStatus:(ZZVideoIncomingStatus)status friendId:(NSString*)friendId videoId:(NSString*)videoId;
- (void)deleteAllViewedOrFailedVideosWithFriendId:(NSString*)friendId;
- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount withFriendID:(NSString*)friendID videoID:(NSString*)videoID;


@end

@interface ZZVideoFileHandler : NSObject

@property (nonatomic, weak) id<ZZVideoFileHandlerDelegate> delegate;

- (void)startService;

- (void)handleBackgroundSessionWithIdentifier:(NSString*)identifier completionHandler:(ANCodeBlock)completionHandler;
- (void)queueDownloadWithFriendID:(NSString*)friendID videoId:(NSString *)videoId;
- (void)updateS3CredentialsWithRequest;

- (void)handleStuckDownloadsWithCompletionHandler:(void (^)())handler;

#pragma mark - Upload

- (void)uploadWithVideoUrl:(NSURL*)videoUrl friendCKey:(NSString*)friendCKey;

@end

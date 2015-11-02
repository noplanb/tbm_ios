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

- (void)sendNotificationForVideoReceived:(TBMFriend *)friend videoId:(NSString *)videoId;
- (void)sendNotificationForVideoStatusUpdate:(TBMFriend *)friend videoId:(NSString *)videoId status:(NSString *)status;
- (void)updateBadgeCounter;
- (void)updateDataRequired;


- (void)notifyOutgoinVideoWithStatus:(ZZVideoOutgoingStatus)status withFriend:(TBMFriend*)friend video:(TBMVideo*)video;
- (void)setAndNotifyUploadRetryCount:(NSInteger)count withFriend:(TBMFriend*)friend video:(TBMVideo*)video;
- (void)setAndNotifyIncomingVideoStatus:(ZZVideoIncomingStatus)status withFriend:(TBMFriend*)friend video:(TBMVideo*)video;
- (void)deleteAllViewedOrFailedVideosForFriend:(TBMFriend*)friend;
- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount withFriend:(TBMFriend*)friend video:(TBMVideo*)video;

@end

@interface ZZVideoFileHandler : NSObject

@property (nonatomic, weak) id<ZZVideoFileHandlerDelegate> delegate;

- (void)startService;

- (void)handleBackgroundSessionWithIdentifier:(NSString*)identifier completionHandler:(ANCodeBlock)completionHandler;
- (void)queueDownloadWithFriendID:(NSString*)friendID videoId:(NSString *)videoId;
- (void)updateS3CredentialsWithRequest;

#pragma mark - Upload

- (void)uploadWithVideoUrl:(NSURL*)videoUrl friendCKey:(NSString*)friendCKey;

@end

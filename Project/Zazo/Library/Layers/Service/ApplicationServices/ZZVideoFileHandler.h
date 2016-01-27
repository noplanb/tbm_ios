//
// Created by Rinat on 27.01.16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZVideoStatuses.h"

@class ZZFriendDomainModel;

@protocol ZZVideoFileHandlerDelegate <NSObject>

- (void)requestBackground;

- (void)sendNotificationForVideoReceived:(ZZFriendDomainModel *)friendModel videoID:(NSString *)videoID;
- (void)sendNotificationForVideoStatusUpdate:(ZZFriendDomainModel *)friendModel videoID:(NSString *)videoID status:(NSString *)status;
- (void)updateBadgeCounter;
- (void)updateDataRequired;


- (void)notifyOutgoingVideoWithStatus:(ZZVideoOutgoingStatus)status withFriendID:(NSString *)friendID videoID:(NSString*)videoID;
- (void)setAndNotifyUploadRetryCount:(NSInteger)count withFriendID:(NSString*)friendID videoID:(NSString*)videoID;
- (void)setAndNotifyIncomingVideoStatus:(ZZVideoIncomingStatus)status friendID:(NSString *)friendID videoID:(NSString*)videoID;
- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount withFriendID:(NSString*)friendID videoID:(NSString*)videoID;

@end

@protocol ZZVideoFileHandler <NSObject>

@property (nonatomic, weak) id<ZZVideoFileHandlerDelegate> delegate;

- (void)startService;

- (void)handleBackgroundSessionWithIdentifier:(NSString*)identifier completionHandler:(ANCodeBlock)completionHandler;
- (void)queueDownloadWithFriendID:(NSString *)friendID videoID:(NSString *)videoID;
- (void)updateS3CredentialsWithRequest;

- (void)handleStuckDownloadsWithCompletionHandler:(void (^)())handler;
- (void)updateCredentials;
- (void)resetAllTasksCompletion:(void(^)())completion;

#pragma mark - Upload

- (void)uploadWithVideoUrl:(NSURL*)videoUrl friendCKey:(NSString*)friendCKey;

@end
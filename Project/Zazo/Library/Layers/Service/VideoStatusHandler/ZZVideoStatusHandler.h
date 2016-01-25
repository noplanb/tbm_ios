//
//  ZZVideoStatusHandler.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 11/1/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoStatuses.h"

@protocol ZZVideoStatusHandlerDelegate <NSObject>

@optional

- (void)videoStatusChangedWithFriendID:(NSString*)friendID;
- (void)sendNotificationForVideoStatusUpdate:(ZZFriendDomainModel *)friend videoID:(NSString *)videoID status:(NSString *)status;

@end


@interface ZZVideoStatusHandler : NSObject

+ (instancetype)sharedInstance;

- (void)addVideoStatusHandlerObserver:(id <ZZVideoStatusHandlerDelegate>)observer;
- (void)removeVideoStatusHandlerObserver:(id <ZZVideoStatusHandlerDelegate>)observer;

- (void)notifyOutgoingVideoWithStatus:(ZZVideoOutgoingStatus)status
                         withFriendID:(NSString *)friendID
                          withVideoID:(NSString*)videoID;


- (void)setAndNotifyUploadRetryCount:(NSInteger)retryCount
                        withFriendID:(NSString*)friendID
                             videoID:(NSString*)videoID;


- (void)setAndNotifyIncomingVideoStatus:(ZZVideoIncomingStatus)videoStatus
                               friendID:(NSString *)friendID
                                videoID:(NSString*)videoID;


- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount
                          withFriendID:(NSString*)friendID
                               videoID:(NSString*)videoID;


- (void)notifyFriendChangedWithId:(NSString*)friendID;

//TODO:

- (void)setAndNotityViewedIncomingVideoWithFriendID:(NSString*)friendID videoID:(NSString*)videoID;
- (void)handleOutgoingVideoCreatedWithVideoID:(NSString *)videoID withFriend:(NSString*)friendID;

@end

//
//  ZZVideoStatusHandler.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 11/1/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoStatuses.h"

@protocol ZZVideoStatusHandlerDelegate <NSObject>

- (void)videoStatusChangedWithFriendID:(NSString*)friendID;

@end


@interface ZZVideoStatusHandler : NSObject

+ (instancetype)sharedInstance;

- (void)addVideoStatusHandlerObserver:(id <ZZVideoStatusHandlerDelegate>)observer;
- (void)removeVideoStatusHandlerObserver:(id <ZZVideoStatusHandlerDelegate>)observer;

- (void)deleteAllViewedOrFailedVideoWithFriendId:(NSString*)friendId;

- (void)notifyOutgoingVideoWithStatus:(ZZVideoOutgoingStatus)status
                         withFriendID:(NSString*)friendID
                          withVideoId:(NSString*)videoId;


- (void)setAndNotifyUploadRetryCount:(NSInteger)retryCount
                        withFriendID:(NSString*)friendID
                             videoID:(NSString*)videoID;


- (void)setAndNotifyIncomingVideoStatus:(ZZVideoIncomingStatus)videoStatus
                               friendId:(NSString*)friendId
                                videoId:(NSString*)videoId;


- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount
                          withFriendID:(NSString*)friendID
                               videoID:(NSString*)videoID;


- (void)notifyFriendChangedWithId:(NSString*)friendID;

//TODO:

- (void)setAndNotityViewedIncomingVideoWithFriendID:(NSString*)friendID videoID:(NSString*)videoID;
- (void)handleOutgoingVideoCreatedWithVideoId:(NSString*)videoId withFriendId:(NSString*)friendID;

@end

//
//  ZZTestGenerator.m
//  Zazo
//
//  Created by ANODA on 10/27/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZTestGenerator.h"
#import "TBMFriend.h"
#import "MagicalRecord.h"
#import "TBMVideo.h"
#import "ZZRemoteStorageValueGenerator.h"
#import "TBMRemoteStorageHandler.h"


@implementation ZZTestGenerator

- (BOOL)startTest
{
    TBMFriend* testFriend = [TBMFriend MR_findFirst];
    TBMVideo* testVideo = [TBMVideo MR_findFirst];

    return (
            [self _isIncomingVideoFileNameTestPassedWithFriend:testFriend video:testVideo] &&
            [self _isOutgoingVideoFileNameTestPassedWithFriend:testFriend video:testVideo] &&
            //video id
            [self _isIncomingVideoIdTestPassedWithFriend:testFriend video:testVideo] &&
            [self _isOutgoingVideoIdTestPassedWithFriend:testFriend video:testVideo] &&
            
            //video status
            [self _isIncomingVideoStatusTestPassedWithFriend:testFriend video:testVideo] &&
            [self _isOutgoingVideoStatusTestPassedWithFriend:testFriend video:testVideo]
            );
}

- (BOOL)_isIncomingVideoFileNameTestPassedWithFriend:(TBMFriend*)friend video:(TBMVideo*)video
{
     BOOL isEqual = NO;
    
    NSString* zIncomingVideoFileName = [ZZRemoteStorageValueGenerator incomingVideoRemoteFilenameWithFriendMkey:video.friend.mkey friendCKey:video.friend.ckey videoID:video.videoId];
    
    NSString* tbmIncomingVideoFileName = [TBMRemoteStorageHandler incomingVideoRemoteFilename:video];
    
    isEqual = [zIncomingVideoFileName isEqualToString:tbmIncomingVideoFileName];
    
    return isEqual;
}

- (BOOL)_isOutgoingVideoFileNameTestPassedWithFriend:(TBMFriend*)friend video:(TBMVideo*)video
{
    BOOL isEqual = NO;
    
    NSString* zOutgoinFileName = [ZZRemoteStorageValueGenerator outgoingVideoRemoteFilenameWithFriendMkey:video.friend.mkey friendCKey:video.friend.ckey videoID:video.videoId];
    NSString* tbmOutgointFileName = [TBMRemoteStorageHandler outgoingVideoRemoteFilename:video.friend videoID:video.videoId];
    
    isEqual = [zOutgoinFileName isEqualToString:tbmOutgointFileName];
    
    return isEqual;
}


#pragma mark - VideoID

- (BOOL)_isIncomingVideoIdTestPassedWithFriend:(TBMFriend*)friend video:(TBMVideo*)video
{
     BOOL isEqual = NO;
    
    NSString* zIncomingVideoId = [ZZRemoteStorageValueGenerator incomingVideoIDRemoteKVKeyWithFriendMKey:video.friend.mkey friendCKey:video.friend.ckey];
    NSString*  tbmIncomingVideoId = [TBMRemoteStorageHandler incomingVideoIDRemoteKVKey:video.friend];
    
    isEqual = [zIncomingVideoId isEqualToString:tbmIncomingVideoId];
    
     return isEqual;
}

- (BOOL)_isOutgoingVideoIdTestPassedWithFriend:(TBMFriend*)friend video:(TBMVideo*)video
{
    BOOL isEqual = NO;
    
    NSString* zOutgoingVideoId = [ZZRemoteStorageValueGenerator outgoingVideoIDRemoteKVWithFriendMKey:video.friend.mkey friendCKey:video.friend.ckey];
    NSString* tbmOutgoingVideoId = [TBMRemoteStorageHandler outgoingVideoIDRemoteKVKey:video.friend];
    
    isEqual = [zOutgoingVideoId isEqualToString:tbmOutgoingVideoId];
    
    return isEqual;

}

#pragma mark - Video Statuses

- (BOOL)_isIncomingVideoStatusTestPassedWithFriend:(TBMFriend*)friend video:(TBMVideo*)video
{
    BOOL isEqual = NO;
    
    NSString* zIncomingVideoStatus = [ZZRemoteStorageValueGenerator incomingVideoStatusRemoteKVKeyWithFriendMKey:video.friend.mkey friendCKey:video.friend.ckey];
    
    NSString* tbmIncoomingVideoStatus = [TBMRemoteStorageHandler incomingVideoStatusRemoteKVKey:video.friend];
    isEqual = [zIncomingVideoStatus isEqualToString:tbmIncoomingVideoStatus];
    
    return isEqual;
}

- (BOOL)_isOutgoingVideoStatusTestPassedWithFriend:(TBMFriend*)friend video:(TBMVideo*)video
{
    BOOL isEqual = NO;
    
    NSString* zOutgoingVideoStatus = [ZZRemoteStorageValueGenerator outgoingVideoStatusRemoteKVKeyWithFriendMKey:video.friend.mkey friendCKey:video.friend.ckey];
    NSString* tbmOutgoingVideoStatus = [TBMRemoteStorageHandler outgoingVideoStatusRemoteKVKey:video.friend];
    isEqual = [zOutgoingVideoStatus isEqualToString:tbmOutgoingVideoStatus];
    
    return isEqual;
}


@end

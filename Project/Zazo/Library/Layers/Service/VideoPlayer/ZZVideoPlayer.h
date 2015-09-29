//
//  ZZVideoPlayer.h
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//


@class ZZFriendDomainModel;

@protocol ZZVideoPlayerDelegate <NSObject>

- (void)videoPlayerURLWasStartPlaying:(NSURL*)videoURL;
- (void)videoPlayerURLWasFinishedPlaying:(NSURL*)videoURL withPlayedUserModel:(ZZFriendDomainModel*)playedFriendModel;

@end

@interface ZZVideoPlayer : NSObject

@property (nonatomic, weak) id<ZZVideoPlayerDelegate> delegate;
@property (nonatomic, assign) BOOL isPlayingVideo;

+ (instancetype)videoPlayerWithDelegate:(id<ZZVideoPlayerDelegate>)delegate;

- (void)playOnView:(UIView*)view withURLs:(NSArray*)URLs;
- (void)stop;

- (void)toggle;
- (BOOL)isPlaying;

@end

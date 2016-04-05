//
//  ZZVideoPlayer.h
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//


@class ZZFriendDomainModel, ZZVideoDomainModel;

@protocol ZZVideoPlayerDelegate <NSObject>

- (void)videoPlayerDidStartVideoModel:(ZZVideoDomainModel *)videoModel;
- (void)videoPlayerURLWasFinishedPlaying:(NSURL *)videoURL withPlayedUserModel:(ZZFriendDomainModel *)playedFriendModel;
- (BOOL)isNetworkEnabled;

@end

@interface ZZVideoPlayer : NSObject

@property (nonatomic, weak) id<ZZVideoPlayerDelegate> delegate;
@property (nonatomic, assign) BOOL isPlayingVideo;

+ (instancetype)videoPlayerWithDelegate:(id<ZZVideoPlayerDelegate>)delegate;

- (ZZFriendDomainModel*)playedFriendModel;
- (void)updateWithFriendModel:(ZZFriendDomainModel*)friendModel;
- (void)playOnView:(UIView*)view withVideoModels:(NSArray*)videoModels;
- (void)stop;

- (void)toggle;
- (BOOL)isPlaying;
- (BOOL)isVideoPlayingWithFriendModel:(ZZFriendDomainModel*)friendModel;

@end

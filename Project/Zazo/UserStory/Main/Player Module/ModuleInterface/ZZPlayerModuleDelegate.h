//
//  ZZPlayerModuleDelegate.h
//  Zazo
//

@class ZZFriendDomainModel, ZZVideoDomainModel;

@protocol ZZPlayerModuleDelegate <NSObject>

- (void)videoPlayerDidStartVideoModel:(ZZVideoDomainModel *)videoModel;

- (void)videoPlayerDidFinishPlayingWithModel:(ZZFriendDomainModel *)playedFriendModel;

- (void)didStartPlayingVideoWithIndex:(NSUInteger)startedVideoIndex totalVideos:(NSUInteger)videos;

- (void)videoPlayingProgress:(CGFloat)progress; // zero if no progress

@end
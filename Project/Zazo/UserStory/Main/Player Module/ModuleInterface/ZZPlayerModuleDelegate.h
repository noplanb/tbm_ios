//
//  ZZPlayerModuleDelegate.h
//  Zazo
//

@class ZZFriendDomainModel, ZZVideoDomainModel;

@protocol ZZPlayerModuleDelegate <NSObject>

- (void)videoPlayerDidStartVideoModel:(ZZVideoDomainModel *)videoModel;
- (void)videoPlayerDidFinishPlayingWithModel:(ZZFriendDomainModel *)playedFriendModel;

@end

//
//  ZZPlayerModuleInterface.h
//  Zazo
//

@class ZZFriendDomainModel, ZZVideoDomainModel;

@protocol ZZPlayerModuleInterface <NSObject>

@property (nonatomic, assign, readonly) BOOL isPlayingVideo;

- (ZZFriendDomainModel *)playedFriendModel;

- (void)appendLastVideoFromFriendModel:(ZZFriendDomainModel *)friendModel; // adds last video to playback queue

- (void)playVideoForFriend:(ZZFriendDomainModel *)friendModel;

- (void)showFullscreen;

- (void)stop;

// UI events:

- (void)didTapVideo;
- (void)didTapNextMessageButton;

@end

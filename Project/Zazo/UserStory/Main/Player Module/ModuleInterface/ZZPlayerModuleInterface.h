//
//  ZZPlayerModuleInterface.h
//  Zazo
//

@class ZZFriendDomainModel, ZZVideoDomainModel;

@protocol ZZPlayerModuleInterface <NSObject>

@property (nonatomic, assign) BOOL isPlayingVideo;

- (ZZFriendDomainModel *)playedFriendModel;

- (void)appendLastVideoFromFriendModel:(ZZFriendDomainModel *)friendModel; // adds last video to playback queue

- (void)playVideoModels:(NSArray <ZZVideoDomainModel *> *)videoModels;

- (void)stop;

- (BOOL)isPlaying;

- (BOOL)isVideoPlayingWithFriendModel:(ZZFriendDomainModel *)friendModel;

// UI events:

- (void)didTapVideo;
- (void)didTapSegmentAtIndex:(NSInteger)index;
- (void)didTapBackground;

@end

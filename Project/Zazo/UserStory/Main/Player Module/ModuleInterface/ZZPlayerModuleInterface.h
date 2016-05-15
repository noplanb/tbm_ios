//
//  ZZPlayerModuleInterface.h
//  Zazo
//

@class ZZFriendDomainModel, ZZVideoDomainModel;

@protocol ZZPlayerModuleInterface <NSObject>

@property (nonatomic, assign) BOOL isPlayingVideo;

- (ZZFriendDomainModel *)playedFriendModel;

- (void)updateWithFriendModel:(ZZFriendDomainModel *)friendModel;

- (void)playVideoModels:(NSArray <ZZVideoDomainModel *> *)videoModels;

- (void)stop;

- (void)toggle;

- (BOOL)isPlaying;

- (BOOL)isVideoPlayingWithFriendModel:(ZZFriendDomainModel *)friendModel;

@end

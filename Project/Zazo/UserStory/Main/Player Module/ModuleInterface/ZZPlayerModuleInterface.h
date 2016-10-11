//
//  ZZPlayerModuleInterface.h
//  Zazo
//

@class ZZFriendDomainModel, ZZVideoDomainModel;

@protocol ZZPlayerModuleInterface <NSObject>

@property (nonatomic, assign, readonly) BOOL isPlayingVideo;

- (ZZFriendDomainModel *)playedFriendModel;
- (void)playVideoForFriend:(ZZFriendDomainModel *)friendModel;
- (void)showFullscreen;
- (void)stop;
- (void)installGestureRecognizer:(UIGestureRecognizer *)recognizer;

// UI events:

- (void)didTapVideo;
- (void)didTapNextMessageButton;

@end

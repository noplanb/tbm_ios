//
//  ZZPlayerViewInterface.h
//  Zazo
//

@class AVPlayerViewController;

@protocol ZZPlayerViewInterface <NSObject>

@property (nonatomic, weak) AVPlayerViewController *playerController;
@property (nonatomic, assign) CGRect initialPlayerFrame;

- (void)setFullscreenEnabled:(BOOL)enabled completion:(ANCodeBlock)completion;

- (void)updatePlayerText:(NSString *)text;
- (void)updateVideoCount:(NSInteger)count;
- (void)updateCurrentVideoIndex:(NSInteger)index;
- (void)updatePlaybackProgress:(CGFloat)progress;

@end

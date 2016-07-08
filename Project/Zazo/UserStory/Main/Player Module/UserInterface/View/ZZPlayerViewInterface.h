//
//  ZZPlayerViewInterface.h
//  Zazo
//

@class AVPlayerViewController;

@protocol ZZPlayerViewInterface <NSObject>

@property (nonatomic, weak) UIView *playerView;
@property (nonatomic, weak) UIView *playbackIndicator;

@property (nonatomic, assign) CGRect initialPlayerFrame;

- (void)setFullscreenEnabled:(BOOL)enabled completion:(ANCodeBlock)completion;

- (void)updatePlayerText:(NSString *)text;

@end

//
//  ZZVideoPlayer.h
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

//@protocol ZZVideoPlayerDelegate  <NSObject>
//
//- (void)videoPlayerStarted;
//- (void)videoPlayerStopped;
//
//@end


@interface ZZVideoPlayer : NSObject

- (instancetype)initWithVideoPlayerView:(UIView *)presentedView;
- (void)setupMoviePlayerWithContentUrl:(NSURL *)contentUrl;
- (void)playVideo;
- (void)stopVideo;
- (BOOL)isPlaying;

@end

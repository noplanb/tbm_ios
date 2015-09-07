//
//  ZZVideoPlayer.h
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZVideoPlayerDelegate <NSObject>

- (void)videoURLWasViewedFully:(NSURL*)videoURL;
- (void)videoURLWasStartPlaying:(NSURL*)videoURL;

@end

@interface ZZVideoPlayer : NSObject

@property (nonatomic, weak) id<ZZVideoPlayerDelegate> delegate;

- (void)playOnView:(UIView*)view withURL:(NSURL*)URL;
- (void)stop;

- (void)toggle;

@end

//
//  ZZVideoPlayer.h
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZVideoPlayerDelegate <NSObject>

- (void)videoPlayerURLWasStartPlaying:(NSURL*)videoURL;
- (void)videoPlayerURLWasFinishedPlaying:(NSURL*)videoURL;

@end

@interface ZZVideoPlayer : NSObject

@property (nonatomic, weak) id<ZZVideoPlayerDelegate> delegate;

- (void)playOnView:(UIView*)view withURLs:(NSArray*)URLs;
- (void)stop;

- (void)toggle;

@end

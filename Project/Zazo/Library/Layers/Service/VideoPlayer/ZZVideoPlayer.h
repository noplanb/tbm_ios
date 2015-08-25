//
//  ZZVideoPlayer.h
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZZVideoPlayerDelegate  <NSObject>

- (void)videoPlayerStarted;
- (void)videoPlayerStopped;

@end


@interface ZZVideoPlayer : NSObject

- (instancetype)initWithVideoPalyerView:(UIView <ZZVideoPlayerDelegate> *)presentedView;
- (void)playVideoWithContentUrl:(NSURL *)contentUrl;

@end

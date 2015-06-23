//
// Created by Maksim Bazarov on 16/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBMVideoPlayer;

@protocol TBMGridElementDelegate <NSObject>
-(void)videoPlayerDidStartPlaying:(TBMVideoPlayer *)player;
-(void)videoPlayerDidStopPlaying:(TBMVideoPlayer *)player;
- (void)messageDidUpload;

- (void)messageDidViewed;
- (void)messageDidReceive;
@end

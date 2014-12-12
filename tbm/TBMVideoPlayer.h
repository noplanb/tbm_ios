//
//  TBMVideoPlayer.h
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBMVideoPlayerEventNotification <NSObject>
- (void)videoPlayerStateDidChangeWithIndex:(NSInteger)index view:(UIView *)view isPlaying:(BOOL)isPlaying;
@end

@interface TBMVideoPlayer : NSObject
// Create
+ (instancetype)sharedInstance;

// Instance methods
- (void)addEventNotificationDelegate:(id)delegate;
- (void)togglePlayWithIndex:(NSInteger)index view:(UIView *)view;
- (void)stop;
- (BOOL)isPlaying;
- (BOOL)isPlayingWithIndex:(NSInteger)index;
@end

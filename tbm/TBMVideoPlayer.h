//
//  TBMVideoPlayer.h
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const TBMVideoPlayerDidStartPlaying;
extern NSString* const TBMVideoPlayerDidFinishPlaying;

@protocol TBMVideoPlayerEventNotification <NSObject>
- (void)videoPlayerStartedIndex:(NSInteger)index;
- (void)videoPlayerStopped;
@end

@interface TBMVideoPlayer : NSObject
@property (nonatomic) UIView *playerView;

// Create
+ (instancetype)sharedInstance;

// Instance methods
- (void)addEventNotificationDelegate:(id)delegate;
- (void)togglePlayWithIndex:(NSInteger)index frame:(CGRect)frame;
- (void)stop;
- (BOOL)isPlaying;
- (BOOL)isPlayingWithIndex:(NSInteger)index;
@end

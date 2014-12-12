//
//  TBMVideoPlayer.m
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideoPlayer.h"
#import "MediaPlayer/MediaPlayer.h"
#import "TBMSoundEffect.h"
#import "TBMGridElement.h"
#import "TBMVideo.h"
#import "TBMFriend.h"
#import "OBLogger.h"

@interface TBMVideoPlayer()
@property TBMGridElement *gridElement;
@property (nonatomic) NSInteger index;
@property (nonatomic) UIView *containerView;
@property (nonatomic) TBMVideo *video;
@property (nonatomic) MPMoviePlayerController *moviePlayerController;
@property (nonatomic) UIView *playerView;
@property (nonatomic) TBMSoundEffect *messageTone;
@property (nonatomic) NSMutableSet *eventNotificationDelegates;
@end

@implementation TBMVideoPlayer

//-------
// Create
//-------
+ (instancetype)sharedInstance{
    static TBMVideoPlayer *sharedVideoPlayer;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedVideoPlayer = [[TBMVideoPlayer alloc] init];
    });
    return sharedVideoPlayer;
}

- (instancetype)init{
    self = [super init];
    if (self != nil){
        _messageTone = [[TBMSoundEffect alloc] initWithSoundNamed:@"single_ding_chimes2.wav"];
        _moviePlayerController = [[MPMoviePlayerController alloc] init];
        _moviePlayerController.controlStyle = MPMovieControlStyleNone;
        _playerView = _moviePlayerController.view;
    }
    return self;
}

//------
// State
//------
- (BOOL)isPlaying{
    return _moviePlayerController.playbackState == MPMoviePlaybackStatePlaying;
}

- (BOOL)isPlayingWithIndex:(NSInteger)index{
    if (self.index != index)
        return NO;
    
    return [self isPlaying];
}

- (BOOL)isPlayingWithFriend:(TBMFriend *)friend{
    if (friend.gridElement == nil)
        return NO;

    if (friend.gridElement.index != self.index)
        return NO;
    
    if (![self isPlaying])
        return NO;
    
    return YES;
}

//------------------------------------------------------
// Notifications of state changes by us to our delegates
//------------------------------------------------------
- (void) addEventNotificationDelegate:(id)delegate{
    if (self.eventNotificationDelegates == nil)
        self.eventNotificationDelegates = [[NSMutableSet alloc] init];
    
    [self.eventNotificationDelegates addObject:delegate];
}

- (void) notifyDelegatesOfEvent{
    for (id <TBMVideoPlayerEventNotification> delegate in self.eventNotificationDelegates){
        [delegate videoPlayerStateDidChangeWithIndex:self.index
                                                view:self.containerView
                                           isPlaying:[self isPlaying]];
    }
}

// ---------------------------------------------------------
// Notifications of state changes from moviePlayerController
// ---------------------------------------------------------
- (void)addPlayerNotifications{
    DebugLog(@"Adding player notifications");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinishNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayerController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayerController];
}

- (void) playbackDidFinishNotification:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *reason = [userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    if ([reason integerValue] != MPMovieFinishReasonUserExited)
        [self playDidComplete];
    
}

- (void) playbackStateDidChangeNotification{
    //DebugLog(@"playbackStateDidChangeNotification");
    [self notifyDelegatesOfEvent];
    if (_moviePlayerController.playbackState == MPMoviePlaybackStatePlaying){
        [self showPlayer];
    } else {
        [self hidePlayer];
    }
}

//-------------
// Message Tone
//-------------
- (void)playNewMessageToneIfNecessary{
    if (_gridElement.friend == nil)
        return;
    
    if (_gridElement.friend.lastVideoStatusEventType == INCOMING_VIDEO_STATUS_EVENT_TYPE &&
        _gridElement.friend.lastIncomingVideoStatus == INCOMING_VIDEO_STATUS_DOWNLOADED) {
        [_messageTone play];
    }
}


// ------------
// View control
// ------------
- (void)showPlayer{
    self.playerView.hidden = NO;
}

- (void)hidePlayer{
    self.playerView.hidden = YES;
}


// ----------------
// Control playback
// ----------------
- (void)togglePlayWithIndex:(NSInteger)index view:(UIView *)view{
    self.containerView = view;
    self.gridElement = [TBMGridElement findWithIndex:index];
    
    // Always start playing if user clicked a different index from the one that was last playing.
    if (self.index != index){
        self.index = index;
        [self start];
        return;
    }
    
    if ([self isPlaying]) {
        [self stop];
    } else {
        [self start];
    }
}

- (void)start{
    OB_INFO(@"VideoPlayer: start:");
    if (self.gridElement.friend == nil)
        return;
    
    [self addPlayerView];
    self.video = [self.gridElement.friend firstPlayableVideo];
    
    if (self.video == nil){
        OB_WARN(@"no playable video.");
        return;
    }
    [self play];
}

- (void)addPlayerView{
    [self.playerView removeFromSuperview];
    [self.playerView setFrame: self.containerView.bounds];
    [self.containerView addSubview:self.playerView];
}


- (void)play{
    DebugLog(@"play for %@", self.video.videoId);

    if ([self.video hasValidVideoFile]){
        self.moviePlayerController.contentURL = [self.video videoUrl];
        [self.moviePlayerController play];
    } else {
        [self  playDidComplete];
    }
}

- (void)stop{
    DebugLog(@"stop for %@", self.video.videoId);
    [self.moviePlayerController stop];
}

- (void)playDidComplete{
    OB_INFO(@"VideoPlayer: playDidComplete: %@", self.video.videoId);
    [self.gridElement.friend setViewedWithIncomingVideo:self.video];
    self.video = [self.gridElement.friend nextPlayableVideoAfterVideo:self.video];
    
    if (self.video != nil)
        [self play];
}


@end

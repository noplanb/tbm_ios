//
//  TBMVideoPlayer.m
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideoPlayer.h"
#import "TBMVideoRecorder.h"
#import "MediaPlayer/MediaPlayer.h"
#import "OBLogger.h"



@interface TBMVideoPlayer()
@end

@implementation TBMVideoPlayer

//-------
// Create
//-------
+ (instancetype)createWithGridElement:(TBMGridElement *)gridElement{
    if (gridElement.videoPlayer != nil)
        [TBMFriend removeVideoStatusNotificationDelegate:gridElement.videoPlayer];
        
    TBMVideoPlayer *player = [[TBMVideoPlayer alloc] initWithGridElement:gridElement];
    [TBMFriend addVideoStatusNotificationDelegate:player];
    return player;
}

- (instancetype)initWithGridElement:(TBMGridElement *)gridElement{
    self = [super init];
    if (self){
        _gridElement = gridElement;
        _gridView = _gridElement.view;
        _messageTone = [[TBMSoundEffect alloc] initWithSoundNamed:@"single_ding_chimes2.wav"];
        
        [self addVideoPlayer];
        [self addThumbnail];
        [self updateThumbNail];
        [self showThumb];
        [self setupViewedIndicator];
        [self updateViewedIndicator];
        [self addPlayerNotifications];
    }
    return self;
}

- (void)addVideoPlayer{
    _moviePlayerController = [[MPMoviePlayerController alloc] init];
    _playerView = _moviePlayerController.view;
    _moviePlayerController.controlStyle = MPMovieControlStyleNone;
    [_playerView setFrame: _gridView.bounds];
    [_gridView addSubview:_playerView];
}

- (void)addThumbnail{
    _thumbView = [[UIImageView alloc] init];
    _thumbView.contentMode = UIViewContentModeScaleAspectFit;
    [_thumbView setFrame: _gridView.bounds];
    [self setThumbnailImage];
    [_gridView addSubview:_thumbView];
}

- (void)setThumbnailImage{
    if (_gridElement.friend != nil)
        _thumbView.image = [_gridElement.friend thumbImageOrThumbMissingImage];
}

- (void)setupViewedIndicator{
    _viewedIndicatorLayer = [CALayer layer];
    _viewedIndicatorLayer.hidden = YES;
    _viewedIndicatorLayer.frame = _gridView.bounds;
    _viewedIndicatorLayer.cornerRadius = 2;
    _viewedIndicatorLayer.backgroundColor = [UIColor clearColor].CGColor;
    _viewedIndicatorLayer.borderWidth = 2;
    _viewedIndicatorLayer.borderColor = [UIColor blueColor].CGColor;
    [_gridView.layer addSublayer:_viewedIndicatorLayer];
    [_viewedIndicatorLayer setNeedsDisplay];
}


//------
// State
//------
- (BOOL)isPlaying{
    return _moviePlayerController.playbackState == MPMoviePlaybackStatePlaying;
}

// ------------------------------
// Notifications of state changes
// ------------------------------
- (void)videoStatusDidChange:(id)object{
    if (object == _gridElement.friend) {
        DebugLog(@"videoStatusDidChange for %@", _gridElement.friend.firstName);
        [self updateView];
    }
}

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
    if (_moviePlayerController.playbackState == MPMoviePlaybackStatePlaying){
        [self showPlayer];
    } else {
        [self showThumb];
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
- (void)updateView{
    [self updateViewedIndicator];
    [self playNewMessageToneIfNecessary];
    [self updateThumbNail];
}

- (void)updateThumbNail{
    if (_gridElement.friend == nil)
        return;
    
    [_gridView setBackgroundColor:[UIColor clearColor]];
    _thumbView.image = [_gridElement.friend thumbImageOrThumbMissingImage];
    [_thumbView setNeedsDisplay];
}


- (void)updateViewedIndicator{
    if (_gridElement.friend == nil)
        return;
    
    if ([_gridElement.friend incomingVideoNotViewed]) {
        DebugLog(@"setting unviewed for %@", _gridElement.friend.firstName);
        [self indicateUnviewed];
    } else {
        DebugLog(@"setting viewed for %@", _gridElement.friend.firstName);
        [self indicateViewed];
    }
}

- (void)indicateUnviewed{
    _viewedIndicatorLayer.hidden = NO;
    [_gridView setNeedsDisplay];
}

- (void)indicateViewed{
    _viewedIndicatorLayer.hidden = YES;
    [_gridView setNeedsDisplay];
}

- (void)showPlayer{
    _playerView.hidden = NO;
    _thumbView.hidden = YES;
}

- (void)showThumb{
    _playerView.hidden = YES;
    _thumbView.hidden = NO;
}

// ----------------
// Control playback
// ----------------
- (void)togglePlay{
    if ([self isPlaying]) {
        [self stop];
    } else {
        [self start];
    }
}

- (void)start{
    OB_INFO(@"VideoPlayer: start:");
    if (_gridElement.friend == nil)
        return;
    
    _video = [_gridElement.friend firstPlayableVideo];
    
    if (_video == nil){
        OB_WARN(@"no playable video.");
        return;
    }
    [self play];
}

- (void)play{
    DebugLog(@"play for %@", _video.videoId);

    if ([_video hasValidVideoFile]){
        _moviePlayerController.contentURL = [_video videoUrl];
        [_moviePlayerController play];
    } else {
        [self  playDidComplete];
    }
}

- (void)stop{
    DebugLog(@"stop for %@", _video.videoId);
    [_moviePlayerController stop];
}

- (void)playDidComplete{
    OB_INFO(@"VideoPlayer: playDidComplete: %@", _video.videoId);
    [_gridElement.friend setViewedWithIncomingVideo:_video];
    _video = [_gridElement.friend nextPlayableVideoAfterVideo:_video];
    
    if (_video != nil)
        [self play];
}

@end

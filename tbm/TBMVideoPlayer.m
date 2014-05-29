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
#import "TBMAppSyncManager.h"

@interface TBMVideoRecorder()
@end

static NSMutableDictionary *instances;

@implementation TBMVideoPlayer

//--------------
// Class Methods
//--------------
+ (id)createWithView:(UIView *)playView friendId:(NSString *)friendId
{
    if (!instances){
        instances = [[NSMutableDictionary alloc] init];
    }

    [TBMVideoPlayer removeWithFriendId:friendId];
    TBMVideoPlayer *player = [[TBMVideoPlayer alloc] initWIthView:playView friendId:friendId];
    [instances setObject:player forKey:friendId];
    [TBMVideoPlayer addVideoStatusObserverWithPlayer:player];
    return player;
}

+ (id)findWithFriendId:(NSNumber *)friendId{
    return [instances objectForKey:friendId];
}

+ (void)removeWithFriendId:(NSNumber *)friendId
{
    TBMVideoPlayer *player = [instances objectForKey:friendId];
    if (player){
        [self removeVideoStatusObserverWithPlayer:player];
        [instances removeObjectForKey:friendId];
    }
}

+ (void)addVideoStatusObserverWithPlayer:(TBMVideoPlayer *)player{
    [TBMFriend addVideoStatusNotificationDelegate:player];
}

+ (void)removeVideoStatusObserverWithPlayer:(TBMVideoPlayer *)player{
    [TBMFriend removeVideoStatusNotificationDelegate:player];
}

+ (void)removeAll
{
    [instances removeAllObjects];
}

//-----------------
// Instance Methods
//-----------------

// -------------
// Instantiation
// -------------
- (id)initWIthView:(UIView *)friendView friendId:(NSString *)friendId{
    self = [super init];
    if (self){
        _friendView = friendView;
        _friendId = friendId;
        _friend = [TBMFriend findWithId:friendId];
        _messageTone = [[TBMSoundEffect alloc] initWithSoundNamed:@"single_ding_chimes2.wav"];

        
        [_friendView setBackgroundColor:[UIColor clearColor]];
        [self addVideoPlayer];
        [self addThumbnail];
        [self showThumb];
        [self setupViewedIndicator];
        [self updateViewedIndicator];
        [self addPlayerNotifications];
        DebugLog(@"Set up player: %@ for %@",self, _friend.firstName);
    }
    return self;
}

- (void)addVideoPlayer{
    _videoUrl = [_friend incomingVideoUrl];
    _moviePlayerController = [[MPMoviePlayerController alloc] init];
    _playerView = _moviePlayerController.view;
    _moviePlayerController.controlStyle = MPMovieControlStyleNone;
    [_playerView setFrame: _friendView.bounds];
    [_friendView addSubview:_playerView];
}

- (void)addThumbnail{
    _thumbView = [[UIImageView alloc] init];
    _thumbView.contentMode = UIViewContentModeScaleAspectFit;
    [_thumbView setFrame: _friendView.bounds];
    _thumbView.image = [_friend thumbImageOrThumbMissingImage];
    [_friendView addSubview:_thumbView];
}

- (void)setupViewedIndicator{
    _viewedIndicatorLayer = [CALayer layer];
    _viewedIndicatorLayer.hidden = YES;
    _viewedIndicatorLayer.frame = _friendView.bounds;
    _viewedIndicatorLayer.cornerRadius = 2;
    _viewedIndicatorLayer.backgroundColor = [UIColor clearColor].CGColor;
    _viewedIndicatorLayer.borderWidth = 2;
    _viewedIndicatorLayer.borderColor = [UIColor blueColor].CGColor;
    [_friendView.layer addSublayer:_viewedIndicatorLayer];
    [_viewedIndicatorLayer setNeedsDisplay];
}

// ------------------------------
// Notifications of state changes
// ------------------------------

- (void)videoStatusDidChange:(id)object{
    if (object == _friend) {
        DebugLog(@"videoStatusDidChange for %@", _friend.firstName);
        [self updateViewedIndicator];
        [self playNewMessageToneIfNecessary];
        [self updateThumbNail];
    }
}

- (void)playNewMessageToneIfNecessary{
    if (_friend.lastVideoStatusEventType == INCOMING_VIDEO_STATUS_EVENT_TYPE &&
        _friend.incomingVideoStatus == INCOMING_VIDEO_STATUS_DOWNLOADED) {
        [_messageTone play];
    }
}

- (void)addPlayerNotifications{
    DebugLog(@"Adding player notifications");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinishNotification) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayerController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayerController];
}

- (void) playbackDidFinishNotification{
    //Unused.
    //DebugLog(@"playbackDidFinishNotification");
}

- (void) playbackStateDidChangeNotification{
    //DebugLog(@"playbackStateDidChangeNotification");
    if (_moviePlayerController.playbackState == MPMoviePlaybackStatePlaying){
        [self showPlayer];
    } else {
        [self showThumb];
    }
}

// ------------
// View control
// ------------
- (void)updateThumbNail{
    _thumbView.image = [_friend thumbImageOrThumbMissingImage];
    [_thumbView setNeedsDisplay];
}


- (void)updateViewedIndicator{
    if (_friend.incomingVideoStatus == INCOMING_VIDEO_STATUS_DOWNLOADED) {
        DebugLog(@"****** setting unviewed for %@", _friend.firstName);
        [self indicateUnviewed];
    } else {
        DebugLog(@"****** setting viewed for %@", _friend.firstName);
        [self indicateViewed];
    }
}

- (void)indicateUnviewed{
    DebugLog(@"indicateUnviewed %@", _friend.firstName);
    _viewedIndicatorLayer.hidden = NO;
    [_friendView setNeedsDisplay];
}

- (void)indicateViewed{
    DebugLog(@"indicateViewed for %@", _friend.firstName);
    _viewedIndicatorLayer.hidden = YES;
    [_friendView setNeedsDisplay];
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
- (void)play{
    DebugLog(@"play for %@", _friend.firstName);
    if (_friend.incomingVideoStatus != INCOMING_VIDEO_STATUS_VIEWED)
        [TBMAppSyncManager notifyServerOfViewedForFriend:_friend];
    
    [_friend setIncomingViewed];
    if (![_friend hasValidIncomingVideoFile]) {
        DebugLog(@"Cant play no valid video file for %@", _friend.firstName);
        return;
    }
    _moviePlayerController.contentURL = _videoUrl;
    [_moviePlayerController play];
}

- (void)togglePlay{
    if (_moviePlayerController.playbackState == MPMoviePlaybackStatePlaying) {
        [self stop];
    } else {
        [self play];
    }
}

- (void)stop{
    DebugLog(@"stop for %@", _friend.firstName);
    [_moviePlayerController stop];
}

@end

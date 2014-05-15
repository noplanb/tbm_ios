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
    DebugLog(@"findWithFriendId instances = %@", instances);
    for (TBMVideoPlayer *player in [instances allValues]) {
        DebugLog(@"%@ %@ %@", player, player.friend, player.friend.firstName);
    }
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
- (id)initWIthView:(UIView *)friendView friendId:(NSString *)friendId{
    self = [super init];
    if (self){
        _friendView = friendView;
        _friendId = friendId;
        _friend = [TBMFriend findWithId:friendId];
        
        [_friendView setBackgroundColor:[UIColor clearColor]];
        [self addVideoPlayer];
        [self addThumbnail];
        [self showThumb];
        [self setupViewedIndicator];
        [self updateViewedIndicator];
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

- (void)updateThumbNail{
    _thumbView.image = [_friend thumbImageOrThumbMissingImage];
}

- (void)videoStatusDidChange:(id)object{
    if (object == self) {
        [self updateViewedIndicator];
        [self updateThumbNail];
    }
}

- (void)updateViewedIndicator{
    if (_friend.incomingVideoStatus == INCOMING_VIDEO_STATUS_DOWNLOADED) {
        [self indicateUnviewed];
    } else {
        [self indicateViewed];
    }
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

- (void)indicateUnviewed{
    DebugLog(@"indicateUnviewed %@", _friend.firstName);
    _viewedIndicatorLayer.hidden = NO;
}

- (void)indicateViewed{
    DebugLog(@"indicateViewed for %@", _friend.firstName);
    _viewedIndicatorLayer.hidden = YES;
}

- (void)showPlayer{
    _playerView.hidden = NO;
    _thumbView.hidden = YES;
}

- (void)showThumb{
    _playerView.hidden = YES;
    _thumbView.hidden = NO;
}

- (void)play{
    DebugLog(@"play for %@", _friend.firstName);
    if (![_friend hasValidIncomingVideoFile]) {
        DebugLog(@"Cant play no valid video file for %@", _friend.firstName);
        return;
    }
    
    DebugLog(@"Playing path=%@", _videoUrl.path);
    _moviePlayerController.contentURL = _videoUrl;
    [self showPlayer];
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
    [_moviePlayerController stop];
}

@end

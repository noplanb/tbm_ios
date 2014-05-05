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
    return player;
}

+ (id)findWithFriendId:(NSNumber *)friendId{
    return [instances objectForKey:friendId];
}

+ (void)removeWithFriendId:(NSNumber *)friendId
{
    [instances removeObjectForKey:friendId];
}

+ (void)removeAll
{
    [instances removeAllObjects];
}

//-----------------
// Instance Methods
//-----------------
- (id)init{
    self = [super init];
    return self;
}

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
        DebugLog(@"Set up player for %@", _friend.firstName);
    }
    return self;
}

- (void)addVideoPlayer{
    _videoUrl = [TBMVideoRecorder outgoingVideoUrlWithFriendId:_friendId];
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

- (void)showPlayer{
    _playerView.hidden = NO;
    _thumbView.hidden = YES;
}

- (void)showThumb{
    _playerView.hidden = YES;
    _thumbView.hidden = NO;
}

- (void)play{
    DebugLog(@"Playing path=%@", _videoUrl.path);
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
    [_moviePlayerController stop];
}

@end

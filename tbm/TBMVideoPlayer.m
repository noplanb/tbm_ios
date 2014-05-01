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
+ (id)createWithView:(UIView *)playView friendId:(NSNumber *)friendId
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

- (id)initWIthView:(UIView *)playView friendId:(NSNumber *)friendId{
    self = [super init];
    if (self){
        _playView = playView;
        _friendId = friendId;
        _videoUrl = [TBMVideoRecorder outgoingVideoUrlWithFriendId:friendId];
        _moviePlayerController = [[MPMoviePlayerController alloc] init];
        _moviePlayerController.controlStyle = MPMovieControlStyleNone;
        [_moviePlayerController.view setFrame: playView.bounds];
        [_playView addSubview:_moviePlayerController.view];
    }
    return self;
}

- (void)play{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *fa = [fm attributesOfItemAtPath:_videoUrl.path error:&error];
    NSLog(@"Playing filesize=%llu path=%@", fa.fileSize, _videoUrl.path);
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

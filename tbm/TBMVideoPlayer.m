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
#import "TBMRemoteStorageHandler.h"
#import "UIAlertView+Blocks.h"
#import "TBMAlertController.h"
#import "TBMAlertControllerVisualStyle.h"
#import "iToast.h"
#import "OBFileTransferManager.h"

@interface TBMVideoPlayer()
@property TBMGridElement *gridElement;
@property (nonatomic) NSInteger index;
@property (nonatomic) CGRect playerFrame;
@property (nonatomic) TBMVideo *video;
@property (nonatomic) NSString *videoId;
@property (nonatomic) MPMoviePlayerController *moviePlayerController;
@property (nonatomic) TBMSoundEffect *messageTone;
@property (nonatomic) NSMutableSet *eventNotificationDelegates;
@property (nonatomic) BOOL videosAreDownloading;
@property (nonatomic) BOOL userStopped;
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
        _messageTone = [[TBMSoundEffect alloc] initWithSoundNamed:@"BeepSin.wav"];
        _moviePlayerController = [[MPMoviePlayerController alloc] init];
        _moviePlayerController.controlStyle = MPMovieControlStyleNone;
        _playerView = _moviePlayerController.view;
        _playerView.tag = 1401;
        self.playerView.hidden = YES;
        [self addPlayerNotifications];
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

- (void) notifyDelegates:(BOOL)isPlaying{
    for (id <TBMVideoPlayerEventNotification> delegate in self.eventNotificationDelegates){
        if (isPlaying){
            [delegate videoPlayerStartedIndex:self.index];
        } else {
            [delegate videoPlayerStopped];
        }
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
    // Note unresolved problem:
    // For some reason when MPMoviePlayerController stop is called we dont get MPMovieFinishReasonUserExited.
    // We get rather MPMovieFinishReasonPlaybackEnded.
    // To work around this we track state userStopped rather than rely on the reson reported in userInfo.
    // NSDictionary *userInfo = [notification userInfo];
    // int reason = [[userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    // if (reason != MPMovieFinishReasonUserExited)
    //    [self playDidComplete];
    
    if (!self.userStopped)
        [self playDidComplete];
}

- (void) playbackStateDidChangeNotification{
//    DebugLog(@"playbackStateDidChangeNotification isplaying:%hhd",  [self isPlaying]);
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

//-------------
// Control view
//-------------
- (void)showPlayerView{
    [self notifyDelegates:YES];
    [self.playerView setFrame: self.playerFrame];
    self.playerView.hidden = NO;
}

- (void)hidePlayerView{
    [self notifyDelegates:NO];
    self.playerView.hidden = YES;
}


// ----------------
// Control playback
// ----------------
- (void)togglePlayWithIndex:(NSInteger)index frame:(CGRect)frame{
    self.playerFrame = frame;
    self.gridElement = [TBMGridElement findWithIndex:index];
    
    // Always stop first so that the notification goes out to reset the view we were on in case it was still playing.
    BOOL wasPlaying = [self isPlaying];
    [self stop];

    // Always start playing if user clicked a different index from the one that was last playing.
    if (self.index != index){
        self.index = index;
        [self start];
        return;
    }
    
    if (!wasPlaying)
        [self start];
}

- (void)start{
    OB_INFO(@"VideoPlayer: start:");
    if (self.gridElement.friend == nil)
        return;
    
    self.userStopped = NO;
    
    [self determineIfDownloading];
    
    if (self.videosAreDownloading)
        [self setCurrentVideo:[self.gridElement.friend firstUnviewedVideo]];
    else
        [self setCurrentVideo:[self.gridElement.friend firstPlayableVideo]];

    if (self.video == nil){
        if (!self.videosAreDownloading){
            OB_WARN(@"no playable video.");
            return;
        }
        
        if ([self.gridElement.friend hasRetryingDownload]){
            [[OBFileTransferManager instance] retryPending];
            [self alertBadConn];
        } else {
            [self toastWait];
        }
        
        return;
    }
    [self play];
}

- (void) determineIfDownloading{
    if ([self.gridElement.friend hasDownloadingVideo]){
        self.videosAreDownloading = YES;
    } else {
        self.videosAreDownloading = NO;
    }
    OB_DEBUG(@"videosAreDownloading: %d", self.videosAreDownloading);
}

- (void)play{
    DebugLog(@"play for %@", self.video.videoId);
    // Set viewed even if the video is not playable so that it gets deleted eventually.
    [self.gridElement.friend setViewedWithIncomingVideo:self.video];
    [TBMRemoteStorageHandler setRemoteIncomingVideoStatus:REMOTE_STORAGE_STATUS_VIEWED
                                                  videoId:self.video.videoId
                                                   friend:self.gridElement.friend];
    if ([self.video hasValidVideoFile]){
        self.moviePlayerController.contentURL = [self.video videoUrl];
        [self.moviePlayerController play];
        [self showPlayerView];
    } else {
        [self  playDidComplete];
    }
}

- (void)stop{
    // DebugLog(@"stop for %@", self.video.videoId);
    self.userStopped = YES;
    [self hidePlayerView];
    [self.moviePlayerController stop];
}

- (void)playDidComplete{
    OB_INFO(@"VideoPlayer: playDidComplete: %@", self.video.videoId);
    if (self.videosAreDownloading)
        [self setCurrentVideo:[self.gridElement.friend nextUnviewedVideoAfterVideoId:self.videoId]];
    else
        [self setCurrentVideo:[self.gridElement.friend nextPlayableVideoAfterVideoId:self.videoId]];
    
    if (self.video != nil){
        [self play];
    } else {
        [self hidePlayerView];
    }
}

- (void)setCurrentVideo:(TBMVideo *)video{
    // We save videoId here becuase video may be deleted out from under us while we are playing if a new video is downloaded
    // since we have marked the current one as viewed.
    self.video = video;
    self.videoId = video.videoId;
}

- (void)toastWait{
    [[iToast makeText:@"Downloading..."] show];
}

- (void)alertBadConn{
    NSString *title = @"Bad Connection";
    NSString *msg = @"Check your connection and try agian.";
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:title message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Try again" style:SDCAlertActionStyleDefault handler:nil]];
    [alert presentWithCompletion:nil];
}


@end

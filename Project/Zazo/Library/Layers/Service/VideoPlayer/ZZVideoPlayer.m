//
//  ZZVideoPlayer.m
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import MediaPlayer;
@import AVFoundation;

#import "ZZVideoPlayer.h"
#import "ZZVideoDomainModel.h"
#import "ZZFriendDataProvider.h"
#import "iToast.h"
#import "ZZFriendDomainModel.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZRemoteStorageTransportService.h"
#import "ZZVideoDataProvider.h"
#import "ZZFileHelper.h"
#import "ZZVideoStatusHandler.h"
#import "ZZFriendDataHelper.h"
#import "ZZFriendDataUpdater.h"
#import "AVAudioSession+ZZAudioSession.h"

@interface ZZVideoPlayer ()

// UI elements
@property (nonatomic, strong) MPMoviePlayerController* moviePlayerController;
@property (nonatomic, strong) UIButton* tapButton;

// All videos:
@property (nonatomic, strong) NSArray <ZZVideoDomainModel *> *videoModels;
@property (nonatomic, strong) NSArray <NSURL *> *videoURLs;

// Current video:
@property (nonatomic, strong) ZZFriendDomainModel *currentFriendModel;
@property (nonatomic, strong) ZZVideoDomainModel *currentVideoModel;
@property (nonatomic, strong) NSURL *currentURL;

// Video duration:
@property (nonatomic, assign) NSTimeInterval currentVideoDuration;
@property (nonatomic, assign) NSTimeInterval totalVideoDuration;
@property (nonatomic, strong) NSArray <NSNumber *> *videoDurations;

// Support
@property (nonatomic, weak) NSTimer *playbackTimer;

@end

@implementation ZZVideoPlayer

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self addNotifications];
        self.videoURLs = [NSArray new];
    }
    return self;
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_playNext:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_playerStateWasUpdated)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stop)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Public

- (BOOL)isPlaying
{
    return (self.moviePlayerController.playbackState == MPMoviePlaybackStatePlaying);
}

- (ZZVideoDomainModel*)_actualVideoDomainModelWithSortedModels:(NSArray*)models
{
    ZZVideoDomainModel* actualVideoModel = [models firstObject];
    
    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:actualVideoModel.relatedUserID];
    ZZVideoDomainModel *videoModel = [ZZVideoDataProvider itemWithID:actualVideoModel.videoID];
    
    NSInteger twoNotViewedVideosCount = 2;
    NSUInteger nextVideoIndex = 1;
    
    if ((friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading) &&
        ([ZZFriendDataHelper unviewedVideoCountWithFriendID:friendModel.idTbm] == twoNotViewedVideosCount) &&
        videoModel.incomingStatusValue == ZZVideoIncomingStatusViewed)
    {
        actualVideoModel = models[nextVideoIndex];
    }
    
    return actualVideoModel;
}

- (void)playOnView:(UIView *)view withVideoModels:(NSArray *)videoModels
{
    [self _updateVideoPlayerStateIfNeeded];
    
    self.moviePlayerController.contentURL = nil;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    self.videoModels = [videoModels sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    [self _configurePlayedUrlsWithModels:self.videoModels];
    
    if (view != self.moviePlayerController.view.superview && view)
    {
        self.moviePlayerController.view.frame = view.bounds;
        [view addSubview:self.moviePlayerController.view];
        [view bringSubviewToFront:self.moviePlayerController.view];
    }
    
    if (!ANIsEmpty(videoModels)) //&& ![self.currentPlayQueue isEqualToArray:URLs]) //TODO: if current playback state is equal to user's play list
    {
        self.moviePlayerController.view.frame = view.bounds;
        [view addSubview:self.moviePlayerController.view];

        ZZVideoDomainModel *viewedVideo = [self _actualVideoDomainModelWithSortedModels:self.videoModels];
        [self _playVideoModel:viewedVideo];
    }
}

- (void)_playVideoModel:(ZZVideoDomainModel *)videoModel
{
//    [self _updateFriendVideoStatusWithFriend:relatedUserModel video:playedVideoModel videoIndex:index];
    
    [self.delegate didStartPlayingVideoWithIndex:[self.videoModels indexOfObject:videoModel] totalVideos:self.videoModels.count];
    
    self.currentVideoModel = videoModel;
    self.currentFriendModel = [ZZFriendDataProvider friendWithItemID:videoModel.relatedUserID];
    self.currentURL = videoModel.videoURL;
    
    NSTimeInterval duration =
    [self.videoDurations[[self.videoModels indexOfObject:videoModel]] doubleValue];
    
    self.currentVideoDuration = duration;
    
    if ((videoModel.incomingStatusValue == ZZVideoIncomingStatusDownloaded ||
         videoModel.incomingStatusValue == ZZVideoIncomingStatusViewed) &&
        [ZZFileHelper isFileExistsAtURL:self.currentURL])
    {
        [self _playCurrentVideo];
    }
    else
    {
        [self _playNextOrStop];
    }

}

- (void)_playCurrentVideo
{
    self.moviePlayerController.contentURL = self.currentURL;
    [self.moviePlayerController play];
    [ZZGridActionStoredSettings shared].incomingVideoWasPlayed = YES;
    
    [self makePlaybackTimer];
    
    [self.delegate videoPlayerDidStartVideoModel:self.currentVideoModel];
    
    self.isPlayingVideo = YES;
    
    // Allow whether locked or unlocked. Users wont know about it till we tell them it is unlocked.
    [[AVAudioSession sharedInstance] startPlaying];
    
    [[ZZVideoStatusHandler sharedInstance]
     setAndNotityViewedIncomingVideoWithFriendID:self.currentFriendModel.idTbm videoID:self.currentVideoModel.videoID];
    
    [[ZZRemoteStorageTransportService updateRemoteStatusForVideoWithItemID:self.currentVideoModel.videoID
                                                                  toStatus:ZZRemoteStorageVideoStatusViewed
                                                                friendMkey:self.currentFriendModel.mKey
                                                                friendCKey:self.currentFriendModel.cKey] subscribeNext:^(id x) {}];

}

- (void)_updateVideoPlayerStateIfNeeded
{
    if (self.isPlayingVideo)
    {
        [self _stopPlaying];
    }
}

- (void)_configurePlayedUrlsWithModels:(NSArray*)videoModels
{
    self.videoURLs = [self.videoModels.rac_sequence map:^id(ZZVideoDomainModel* value) {
        
        ZZVideoDomainModel *videoModel = [ZZVideoDataProvider itemWithID:value.videoID];
        return [ZZVideoDataProvider videoUrlWithVideoModel:videoModel];
        
    }].array;

    self.videoDurations = [self.videoURLs.rac_sequence map:^id(id value) {

        AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:value options:nil];
        CMTime duration = sourceAsset.duration;
        return @(duration.value / (CGFloat)duration.timescale);

    }].array;

    self.totalVideoDuration = 0;

    [self.videoDurations enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        self.totalVideoDuration += obj.doubleValue;
    }];
    
    
}

- (void)stop
{
    [self _stopWithPlayChecking:YES];
}

- (void)_stopWithPlayChecking:(BOOL)isCheckPlaying
{
    if (isCheckPlaying && self.isPlayingVideo)
    {
        [self _stopPlaying];
    }
    else if (!isCheckPlaying)
    {
        [self _stopPlaying];
    }
        
}

- (void)_stopPlaying
{
    self.isPlayingVideo = NO;
    [self.moviePlayerController.view removeFromSuperview];
    [self.moviePlayerController stop];
    self.currentFriendModel.isVideoStopped = YES;
    [self.delegate videoPlayerURLWasFinishedPlaying:self.moviePlayerController.contentURL
                                withPlayedUserModel:self.currentFriendModel];
    self.currentFriendModel = nil;
}

- (void)toggle
{
    if (self.isPlayingVideo)
    {
        [self stop];
    }
    else
    {
        [self playOnView:nil withVideoModels:self.videoModels];
    }
}


#pragma mark - Private

- (void)_playNext:(NSNotification*)notification
{
    ZZLogDebug(@"VideoPlayer#playbackDidFinishNotification: %@", notification.userInfo);
    NSError *error = (NSError *) notification.userInfo[@"error"];
    if (error != nil)
    {
        ZZLogError(@"VideoPlayer#playbackDidFinishNotification: %@", error);
        ANDispatchBlockToMainQueue(^{
            [[iToast makeText:NSLocalizedString(@"video-player-not-playable", nil)] show];
            
            self.isPlayingVideo = NO;
            [self.moviePlayerController stop];
            CGFloat delayAfterToastRemoved = 0.4;
            ANDispatchBlockAfter(delayAfterToastRemoved, ^{
                [self _playNext];
            });
        });
    }
    else
    {
        if (self.isPlayingVideo)
        {
            [self _playNext];
        }
    }
}

#pragma mark - Configure Next played index

- (NSUInteger)_nextVideoIndex
{
    __block NSUInteger index = NSNotFound;
    [self.videoURLs enumerateObjectsUsingBlock:^(NSURL*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.path isEqualToString:self.currentURL.path])
        {
            index = idx;
            *stop = YES;
        }
    }];
    
    if (index != NSNotFound)
    {
        index++;
    }
    
    return index;
}


- (void)_playNextOrStop
{
    if ([self _isAblePlayNext])
    {
        [self _playNext];
    }
    else
    {
        [self _stopWithPlayChecking:NO];
    }
}

- (BOOL)_isAblePlayNext
{
    return ([self _nextVideoIndex] != NSNotFound);
}

- (void)_playNext
{
    NSUInteger index = [self _nextVideoIndex];
    
    NSURL* nextUrl = nil;
    
    if (index < self.videoURLs.count)
    {
        nextUrl = self.videoURLs[index];
    }
    else
    {
        
        ZZVideoDomainModel *lastModel = [self.videoModels lastObject];
        
        self.isPlayingVideo = NO;
        [self.delegate videoPlayerURLWasFinishedPlaying:[ZZVideoDataProvider videoUrlWithVideoModel:lastModel] withPlayedUserModel:self.currentFriendModel];
        [self.moviePlayerController.view removeFromSuperview];
        self.currentFriendModel = nil;
    }
    
    if (nextUrl)
    {
        ZZVideoDomainModel *playedVideoModel = self.videoModels[index];
        [self _playVideoModel:playedVideoModel];
    }
}

//TODO: temprorary
- (void)_updateFriendVideoStatusWithFriend:(ZZFriendDomainModel*)friendModel
                                    video:(ZZVideoDomainModel*)videoModel
                               videoIndex:(NSInteger)index
{
    NSInteger arrayBoundsIndex = 1;
    
    if (index == (self.videoURLs.count - arrayBoundsIndex) &&
        friendModel.lastIncomingVideoStatus != videoModel.incomingStatusValue)
    {
        friendModel.lastIncomingVideoStatus = videoModel.incomingStatusValue;
        [ZZFriendDataUpdater updateFriendWithID:friendModel.idTbm setLastIncomingVideoStatus: videoModel.incomingStatusValue];
    }
}


- (void)updateWithFriendModel:(ZZFriendDomainModel *)friendModel
{
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    NSArray* acutalVideos = [friendModel.videos sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    NSMutableArray* videoModelsCopy = [self.videoModels mutableCopy];
    ZZVideoDomainModel* lastVideoModel = [acutalVideos lastObject];
    
    NSURL* lastVideoUrl = [ZZVideoDataProvider videoUrlWithVideoModel: lastVideoModel];
    
    if (![self.videoURLs containsObject:lastVideoUrl])
    {
        self.videoURLs = [self.videoURLs arrayByAddingObject:lastVideoUrl];
        [videoModelsCopy addObject:lastVideoModel];
        self.videoModels = videoModelsCopy;
    }
}

- (void)_playerStateWasUpdated
{
    if (self.moviePlayerController.playbackState == MPMoviePlaybackStatePlaying)
    {
        NSUInteger index = [self.videoURLs indexOfObject:self.moviePlayerController.contentURL];

        if (index == NSNotFound)
        {
            return;
        }

        [self.delegate videoPlayerDidStartVideoModel:self.videoModels[index]];
    }
}


#pragma mark - Helpers


- (ZZFriendDomainModel*)playedFriendModel
{
    return self.currentFriendModel;
}

- (BOOL)isVideoPlayingWithFriendModel:(ZZFriendDomainModel*)friendModel
{
    return (self.isPlayingVideo &&
            [friendModel.idTbm isEqualToString:self.currentFriendModel.idTbm]);
}

#pragma mark - Lazy Load

- (MPMoviePlayerController *)moviePlayerController
{
    if (!_moviePlayerController)
    {
        _moviePlayerController = [MPMoviePlayerController new];
        [_moviePlayerController setScalingMode:MPMovieScalingModeAspectFill];
        _moviePlayerController.controlStyle = MPMovieControlStyleNone;
        _moviePlayerController.view.backgroundColor = [UIColor clearColor];
        
        for (UIView *aSubView in _moviePlayerController.view.subviews)
        {
            aSubView.backgroundColor = [UIColor clearColor];
        }
        
        [_moviePlayerController.view addSubview:self.tapButton];
    }
    return _moviePlayerController;
}

- (UIButton*)tapButton
{
    if (!_tapButton)
    {
        _tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tapButton addTarget:self
                       action:@selector(toggle)
             forControlEvents:UIControlEventTouchUpInside];
        [self.moviePlayerController.view addSubview:_tapButton];
        
        [_tapButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.moviePlayerController.view);
        }];
    }
    return _tapButton;
}

#pragma mark Timer

- (void)makePlaybackTimer
{
    [self removePlaybackTimer];
    
    self.playbackTimer =
    [NSTimer scheduledTimerWithTimeInterval:0.01f
                                     target:self
                                   selector:@selector(timerTick)
                                   userInfo:nil
                                    repeats:YES];
    
    self.playbackTimer.tolerance = 0.5f;
}

- (void)removePlaybackTimer
{
    [self.playbackTimer invalidate];
}

- (void)timerTick
{
    if (self.moviePlayerController.playbackState != MPMoviePlaybackStatePlaying)
    {
        [self removePlaybackTimer];
        [self.delegate videoPlayingProgress:0];
        return;
    }

    CGFloat relativePlaybackPosition = [self totalPlayedVideoTime] / self.totalVideoDuration;
    
    if ([self.delegate respondsToSelector:@selector(videoPlayingProgress:)])
    {
        [self.delegate videoPlayingProgress:relativePlaybackPosition];
    }
}

- (NSTimeInterval)totalPlayedVideoTime
{
    NSUInteger currentVideoIndex = [self.videoModels indexOfObject:self.currentVideoModel];

    if (currentVideoIndex == 0)
    {
        return self.moviePlayerController.currentPlaybackTime;
    }

    NSTimeInterval playedTimeBeforeCurrentVideo = 0;

    for (NSUInteger i = 0; i < currentVideoIndex; ++i)
    {
        playedTimeBeforeCurrentVideo += [self.videoDurations[i] doubleValue];
    }

    return playedTimeBeforeCurrentVideo + self.moviePlayerController.currentPlaybackTime;
}

@end

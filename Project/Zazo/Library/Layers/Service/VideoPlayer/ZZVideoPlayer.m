//
//  ZZVideoPlayer.m
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import MediaPlayer;
@import AVKit;

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
@property (nonatomic, strong) AVPlayerViewController *playerController;
@property (nonatomic, strong, readonly) AVQueuePlayer *player;

@property (nonatomic, strong) UIButton* tapButton;

// All videos:
@property (nonatomic, strong) NSArray <ZZVideoDomainModel *> *videoModels;

// Current video:
@property (nonatomic, strong) ZZFriendDomainModel *currentFriendModel;
@property (nonatomic, strong, readonly) ZZVideoDomainModel *currentVideoModel;

// Video duration:
@property (nonatomic, assign) NSTimeInterval totalVideoDuration;
@property (nonatomic, assign) NSTimeInterval playedVideoDuration;
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
        self.videoDurations = @[];
        [self _addNotifications];
    }
    return self;
}

- (void)_addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didFinishPlayingItemNotification:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationWillResignNotication)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    
}

- (void)_makePlayer
{
    self.playerController.player = [AVQueuePlayer new];
    self.playerController.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    RACSignal *currentItem = RACObserve(self.playerController.player, currentItem).distinctUntilChanged;
    
    RACSignal *status = [currentItem flattenMap:^RACStream *(AVPlayerItem *item) {
        return RACObserve(item, status);
    }];
    
    [status.distinctUntilChanged subscribeNext:^(NSNumber *x) {
        
        if (self.isPlayingVideo && x.integerValue == AVPlayerStatusFailed)
        {
            [self _failedToPlayCurrentVideo];
        }
        
    }];
    
}

#pragma mark - Public

- (BOOL)isPlaying
{
    return self.playerController.player.rate > 0;
}

//- (ZZVideoDomainModel *)_actualVideoDomainModelWithSortedModels:(NSArray *)models
//{
//    ZZVideoDomainModel* actualVideoModel = [models firstObject];
//    
//    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:actualVideoModel.relatedUserID];
//    
//    ZZVideoDomainModel *videoModel = [ZZVideoDataProvider itemWithID:actualVideoModel.videoID];
//    
//    NSInteger twoNotViewedVideosCount = 2;
//    NSUInteger nextVideoIndex = 1;
//    
//    if ((friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading) &&
//        ([ZZFriendDataHelper unviewedVideoCountWithFriendID:friendModel.idTbm] == twoNotViewedVideosCount) &&
//        videoModel.incomingStatusValue == ZZVideoIncomingStatusViewed)
//    {
//        actualVideoModel = models[nextVideoIndex];
//    }
//    
//    return actualVideoModel;
//}

- (void)playOnView:(UIView *)view withVideoModels:(NSArray <ZZVideoDomainModel *> *)videoModels
{
    [self _stopVideoPlayerStateIfNeeded];
    
    [self _makePlayer];
    
    videoModels = [videoModels.rac_sequence filter:^BOOL(ZZVideoDomainModel *videoModel) {
        return (videoModel.incomingStatusValue == ZZVideoIncomingStatusDownloaded ||
                videoModel.incomingStatusValue == ZZVideoIncomingStatusViewed) &&
        [ZZFileHelper isFileExistsAtURL:videoModel.videoURL];
    }].array;
    
    if (ANIsEmpty(videoModels))
    {
        return;
    }
    
    self.currentFriendModel = [ZZFriendDataProvider friendWithItemID:videoModels.firstObject.relatedUserID];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    videoModels = [videoModels sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    [self _updateWithModels:videoModels];
    
    if (view != self.playerController.view.superview && view)
    {
        [view addSubview:self.playerController.view];
        [view bringSubviewToFront:self.playerController.view];
        self.playerController.view.frame = view.bounds;
    }
    
    [ZZGridActionStoredSettings shared].incomingVideoWasPlayed = YES;
    
    [self _makePlaybackTimer];
    
    [self.delegate videoPlayerDidStartVideoModel:self.currentVideoModel];
    
    self.isPlayingVideo = YES;
    
    // Allow whether locked or unlocked. Users wont know about it till we tell them it is unlocked.
    [[AVAudioSession sharedInstance] startPlaying];
    
    [self _markCurrentVideoAsSeen];
    
    self.playedVideoDuration = 0;
    
    [self.player play];
}

- (void)stop
{
    [self _stopWithPlayChecking:YES];
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

- (void)updateWithFriendModel:(ZZFriendDomainModel *)friendModel
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    
    NSArray *actualVideos = [friendModel.videos sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    ZZVideoDomainModel *lastVideoModel = [actualVideos lastObject];
    
    if (![self.videoModels containsObject:lastVideoModel])
    {
        [self _appendModel:lastVideoModel];
    }
}

- (ZZFriendDomainModel *)playedFriendModel
{
    return self.currentFriendModel;
}

- (BOOL)isVideoPlayingWithFriendModel:(ZZFriendDomainModel*)friendModel
{
    return (self.isPlayingVideo &&
            [friendModel.idTbm isEqualToString:self.currentFriendModel.idTbm]);
}

#pragma mark - Private


- (void)_stopVideoPlayerStateIfNeeded
{
    if (self.isPlayingVideo)
    {
        [self _stopPlaying];
    }
}

- (void)_updateWithModels:(NSArray <ZZVideoDomainModel *> *)videoModels
{
    self.totalVideoDuration = 0;
    [self.player removeAllItems];
    self.videoModels = @[];
    
    for (ZZVideoDomainModel *model in videoModels)
    {
        [self _appendModel:model];
    }
}

- (void)_appendModel:(ZZVideoDomainModel *)videoModel
{
    self.videoModels = [self.videoModels arrayByAddingObject:videoModel];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoModel.videoURL];
    [self.player insertItem:item afterItem:nil];
    
    self.totalVideoDuration += [self _durationByURL:videoModel.videoURL];
    
}

- (NSTimeInterval)_durationByURL:(NSURL *)url
{
    AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    CMTime duration = sourceAsset.duration;
    return CMTimeGetSeconds(duration);
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
    
    [self.playerController.view removeFromSuperview];
    [self.playerController.player pause];
    [self.delegate videoPlayerDidFinishPlayingWithModel:self.currentFriendModel];
    
    self.currentFriendModel = nil;
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
    return self.currentVideoModel != self.videoModels.lastObject;
}

- (void)_playNext
{
    [self.player advanceToNextItem];
    [self.player play];
    
    [self _markCurrentVideoAsSeen];
}

- (void)_markCurrentVideoAsSeen
{
    [self.delegate didStartPlayingVideoWithIndex:[self.videoModels indexOfObject:self.currentVideoModel]
                                     totalVideos:self.videoModels.count];

    [[ZZVideoStatusHandler sharedInstance]
     setAndNotityViewedIncomingVideoWithFriendID:self.currentFriendModel.idTbm videoID:self.currentVideoModel.videoID];
    
    [[ZZRemoteStorageTransportService updateRemoteStatusForVideoWithItemID:self.currentVideoModel.videoID
                                                                  toStatus:ZZRemoteStorageVideoStatusViewed
                                                                friendMkey:self.currentFriendModel.mKey
                                                                friendCKey:self.currentFriendModel.cKey] subscribeNext:^(id x) {}];

}

// temporary
- (void)_updateFriendVideoStatusWithFriend:(ZZFriendDomainModel*)friendModel
                                    video:(ZZVideoDomainModel*)videoModel
                               videoIndex:(NSInteger)index
{
    NSInteger arrayBoundsIndex = 1;
    
    if (index == (self.videoModels.count - arrayBoundsIndex) &&
        friendModel.lastIncomingVideoStatus != videoModel.incomingStatusValue)
    {
        friendModel.lastIncomingVideoStatus = videoModel.incomingStatusValue;
        
        [ZZFriendDataUpdater updateFriendWithID:friendModel.idTbm
                     setLastIncomingVideoStatus: videoModel.incomingStatusValue];
    }
}

- (NSTimeInterval)_totalPlayedVideoTime
{
    NSTimeInterval currentTime = CMTimeGetSeconds(self.playerController.player.currentTime);
    
    return self.playedVideoDuration + currentTime;
}

#pragma mark - Properties

- (AVPlayerViewController *)playerController
{
    if (!_playerController)
    {
        _playerController = [AVPlayerViewController new];
        _playerController.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _playerController.view.backgroundColor = [UIColor clearColor];
        _playerController.showsPlaybackControls = NO;

        [_playerController.view addSubview:self.tapButton];
        
    }
    return _playerController;
}

- (UIButton *)tapButton
{
    if (!_tapButton)
    {
        _tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tapButton addTarget:self
                       action:@selector(toggle)
             forControlEvents:UIControlEventTouchUpInside];
        [self.playerController.view addSubview:_tapButton];
        
        [_tapButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playerController.view);
        }];
    }
    return _tapButton;
}

@dynamic player;

- (AVQueuePlayer *)player
{
    return (id)self.playerController.player;
}

@dynamic currentVideoModel;

- (ZZVideoDomainModel *)currentVideoModel
{
    AVURLAsset *URLAsset = (id)self.player.items.firstObject.asset;
    
    for (ZZVideoDomainModel *videoModel in self.videoModels)
    {
        if ([videoModel.videoURL.path isEqualToString:URLAsset.URL.path])
        {
            return videoModel;
        }
    }
    
    return nil;
}

#pragma mark Events

- (void)_failedToPlayCurrentVideo
{
    NSError *error = self.player.currentItem.error;
    ZZLogError(@"VideoPlayer#playbackDidFail: %@", error);
    
    ANDispatchBlockToMainQueue(^{
        [[iToast makeText:NSLocalizedString(@"video-player-not-playable", nil)] show];
        
        CGFloat delayAfterToastRemoved = 0.4;
        
        ANDispatchBlockAfter(delayAfterToastRemoved, ^{
            [self _playNextOrStop];
        });
        
    });
    
}

- (void)_applicationWillResignNotication
{
    [self stop];
}

- (void)_didFinishPlayingItemNotification:(NSNotification *)notification
{
    AVPlayerItem *item = notification.object;
    
    if (notification.object != self.player.currentItem)
    {
        return;
    }
    
    self.playedVideoDuration += CMTimeGetSeconds(item.duration);
    
    ZZLogDebug(@"VideoPlayer#playbackDidFinishNotification");
    
    if (self.isPlayingVideo)
    {
        [self _playNextOrStop];
    }
}

#pragma mark Timer

- (void)_makePlaybackTimer
{
    [self _removePlaybackTimer];
    
    self.playbackTimer =
    [NSTimer scheduledTimerWithTimeInterval:0.01f
                                     target:self
                                   selector:@selector(_timerTick)
                                   userInfo:nil
                                    repeats:YES];
    
    self.playbackTimer.tolerance = 0.5f;
}

- (void)_removePlaybackTimer
{
    [self.playbackTimer invalidate];
}

- (void)_timerTick
{
    if (![self isPlaying])
    {
        [self _removePlaybackTimer];
        [self.delegate videoPlayingProgress:0];
        return;
    }

    CGFloat relativePlaybackPosition = [self _totalPlayedVideoTime] / self.totalVideoDuration;
    
    if ([self.delegate respondsToSelector:@selector(videoPlayingProgress:)])
    {
        [self.delegate videoPlayingProgress:relativePlaybackPosition];
    }
}

@end

//
//  ZZPlayerController.m
//  Zazo
//
//  Created by Rinat on 08/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZPlayerController.h"
#import "AVAudioSession+ZZAudioSession.h"
#import "ZZFriendDomainModel.h"
#import "ZZVideoDomainModel.h"
#import "ZZVideoStatusHandler.h"
#import "ZZVideoDataProvider.h"
#import "ZZPlaybackQueueItem.h"
#import "ZZPlayerQueue.h"

@import AVKit;
@import AVFoundation;

static NSInteger const ZZPlayerCurrentVideoIndex = NSIntegerMax;

@interface ZZPlayerController () <PlaybackIndicatorDelegate, ZZPlayerQueueDelegate>

// UI elements
@property (nonatomic, strong) AVPlayerViewController *playerController;
@property (nonatomic, strong, readonly) AVQueuePlayer *player;
@property (nonatomic, strong) ZZPlayerQueue *queue;

@property (nonatomic, strong) PlaybackIndicator *indicator;

@property (nonatomic, strong, readonly) AVPlayerItem *currentPlayerItem;
@property (nonatomic) NSObject<ZZPlaybackQueueItem> *currentQueueItem;
@property (nonatomic) ZZVideoDomainModel *currentVideoModel;

@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign, readwrite) BOOL isPlayingVideo;
@property (nonatomic, assign) BOOL waitsForMessageCallback;

@end

@implementation ZZPlayerController

@dynamic player;
@dynamic friendModel;
@dynamic currentPlayerItem;
@dynamic playbackIndicator;
@dynamic paused;

@synthesize muted = _muted;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _indicator = [PlaybackIndicator new];
        _indicator.delegate = self;
        
        _playerController = [AVPlayerViewController new];
        _playerController.showsPlaybackControls = NO;
        _playerController.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _playerController.view.backgroundColor = [UIColor clearColor];

        [_playerController view];
        
        [self _addObservers];
    }
    return self;
}

- (UIView *)playerView
{
    return self.playerController.view;
}

- (void)playVideoForFriend:(ZZFriendDomainModel *)friendModel
{
    [self stop];
    self.dragging = NO;

    [self _makePlayer];
    self.isPlayingVideo = YES;

    self.queue = [ZZPlayerQueue queueForFriend:friendModel
                              withTextMessages:!self.hideTextMessages
                                      delegate:self];
    
    [[AVAudioSession sharedInstance] startPlaying]; // Allow whether locked or unlocked. Users wont know about it till we tell them it is unlocked.
    
    [self updateVideoCount];
    [self _continueAfterItem:nil];
}

- (void)didStartDragging
{
    self.dragging = YES;
    [self.player pause];
}

- (void)didFinishDragging
{
    self.dragging = NO;
    [self _startPlayingIfPossible];
}

- (void)_startPlayingIfPossible
{
    ZZLogInfo(@"Trying to start playing");
    
    if (!self.currentVideoModel)
    {
        ZZLogInfo(@"Aborting: currentVideoModel = nil");
        return;
    }
    
    if (self.dragging)
    {
        ZZLogInfo(@"Aborting: dragging");
        return;
    }
    
    [self.player play];
    
    NSUInteger currentVideoIndex = [self.queue.models indexOfObject:self.currentVideoModel];
    
    NSLog(@"Started playing with currentVideoIndex = %lu", (unsigned long)currentVideoIndex);
    
//    NSInteger index = [self.allVideoModels indexOfObject:self.currentVideoModel];
//
//    if (index == NSNotFound)
//    {
//        return;
//    }

    [self.delegate videoPlayerDidStartVideoModel:self.currentVideoModel];
        
}

- (void)didSeekToPosition:(CGFloat)position ofSegmentWithIndex:(NSInteger)index
{
    NSObject<ZZPlaybackQueueItem> *item = self.queue.models[index];
    
    if (item.type != ZZIncomingEventTypeVideo)
    {
        return;
    }
    
    [self _changeCurrentVideoToVideoWithIndex:index completion:^{
        
        if (self.currentPlayerItem.status != AVPlayerItemStatusReadyToPlay)
        {
            return ;
        }
        
        [self.currentPlayerItem cancelPendingSeeks];
        
        CMTime seekTime = CMTimeMake(self.currentPlayerItem.duration.value * position, self.currentPlayerItem.duration.timescale);
        
        [self.currentPlayerItem seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }];
}

- (void)_makePlayer
{
    self.playerController.player = [AVQueuePlayer new];
    self.playerController.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    self.player.volume = (float)!self.muted;
    
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
    
    @weakify(self);
    
    [self.playerController.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 50)
                                                               queue:dispatch_get_main_queue()
                                                          usingBlock:^(CMTime time) {
                                                              
                                                              @strongify(self);
                                                              
                                                              AVPlayerItem *item = self.currentPlayerItem;
                                                              
                                                              if (self.dragging || item.duration.value == 0 || item.status != AVPlayerStatusReadyToPlay)
                                                              {
                                                                  return;
                                                              }
                                                              
                                                              CGFloat currentTime = (CGFloat)item.currentTime.value / item.currentTime.timescale;
                                                              CGFloat durationTime = (CGFloat)item.duration.value / item.duration.timescale;
                                                              CGFloat relativePlaybackPosition = currentTime / durationTime;
                                                              
                                                              [self updatePlaybackProgress: relativePlaybackPosition];
                                                          }];
    
}



- (AVPlayerItem *)_itemForVideoModel:(ZZVideoDomainModel *)videoModel
{
    if (!videoModel)
    {
        return nil;
    }
    
    for (AVPlayerItem *item in self.player.items)
    {
        AVURLAsset *URLAsset = (id)item.asset;
        
        if ([videoModel.videoURL.path isEqualToString:URLAsset.URL.path])
        {
            return item;
        }
    }
    
    return nil;
}

- (void)_changeCurrentVideoToVideoWithIndex:(NSInteger)indexToPlay
                                 completion:(ANCodeBlock)completion
{
    if (indexToPlay == ZZPlayerCurrentVideoIndex)
    {
        if (completion)
        {
            completion();
        }
        return;
    }
    
    NSUInteger currentSegmentIndex = [self.queue.models indexOfObject:self.currentVideoModel];
    
    if (currentSegmentIndex == indexToPlay)
    {
        if (completion)
        {
            completion();
        }
        return;
    }
    
    if (indexToPlay > currentSegmentIndex)
    {
        NSUInteger itemsToAdvance = indexToPlay - currentSegmentIndex;
        
        for (int i = 0; i < itemsToAdvance; i++)
        {
            NSObject <ZZPlaybackQueueItem> *item = self.queue.models[currentSegmentIndex + i];
            
            if (item.type != ZZIncomingEventTypeVideo) {
                continue;
            }
            
            [self.player advanceToNextItem];
        }
        
        [self.player pause];
    }
    else
    {
        [self.queue reloadWithSkip:indexToPlay];
    }
    
    self.currentQueueItem = [self.queue.models objectAtIndex:indexToPlay];
    
    if (!completion)
    {
        return;
    }
    
    [[[RACObserve(self.currentPlayerItem, status) filter:^BOOL(id value) {
        
        return [value integerValue] == AVPlayerStatusReadyToPlay;
        
    }] take:1] subscribeNext:^(id x) {
        
        completion();
        
    }];
}

- (AVQueuePlayer *)player
{
    return (id)self.playerController.player;
}

- (ZZVideoDomainModel *)currentVideoModel
{
    if ([self.currentQueueItem isKindOfClass:[ZZVideoDomainModel class]]) {
        return (id)self.currentQueueItem;
    }
    
//    AVURLAsset *URLAsset = (id)self.currentPlayerItem.asset;
//    
//    for (ZZVideoDomainModel *videoModel in self.loadedVideoModels)
//    {
//        if ([videoModel.videoURL.path isEqualToString:URLAsset.URL.path])
//        {
//            return videoModel;
//        }
//    }
    
    return nil;
}

- (AVPlayerItem *)currentPlayerItem
{
    return self.player.items.firstObject;
}

- (void)_addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didFinishPlayingItemNotification:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
}

- (void)_playNextVideoOrStop
{
    if ([self _isAblePlayNext])
    {
        [self _continueAfterItem:self.currentVideoModel];
    }
    else
    {
        [self stop];
    }
}

- (BOOL)_isAblePlayNext
{
    return [self.queue itemAfterTimestamp:[self.currentVideoModel timestamp]] != nil;
}

- (void)_playNextVideo
{
    BOOL isVeryBeginning = ([self.player.items indexOfObject:self.currentPlayerItem] == 0) && CMTimeCompare(self.player.currentItem.currentTime, kCMTimeZero) == 0;
    
    if (!isVeryBeginning) {
        [self.player advanceToNextItem];
    }
    
    [self updateCurrentVideoIndex:[self.queue.models indexOfObject:self.currentVideoModel]];
    [self _startPlayingIfPossible];
}

- (void)_didFinishPlayingItemNotification:(NSNotification *)notification
{
    AVPlayerItem *item = notification.object;
    
    if (item != self.currentPlayerItem)
    {
        return;
    }
    
    ZZLogDebug(@"VideoPlayer#playbackDidFinishNotification");
    
    if (self.isPlayingVideo)
    {
        [self _playNextVideoOrStop];
    }
}

- (void)_showMessageGroup:(ZZMessageGroup *)messageGroup
{
    for (ZZMessageDomainModel *messageModel in messageGroup.messages) {
        [[MessageHandler sharedInstance] markAsRead:messageModel];
    }
    
    [self updateCurrentVideoIndex:[self.queue.models indexOfObject:messageGroup]];

    self.waitsForMessageCallback = YES;
    
    @weakify(self);

    [self.delegate needsShowMessages:messageGroup completion:^(BOOL shouldContinue) {
        
        @strongify(self);
        self.waitsForMessageCallback = NO;
        
        if (shouldContinue) {
            [self _continueAfterItem:messageGroup];
        }
        else {
            [self stop];
        }
    }];
}

- (void)_continueAfterItem:(NSObject<ZZPlaybackQueueItem> *)queueItem
{
    NSObject<ZZPlaybackQueueItem> *nextItem;
    
    if (!queueItem)
    {
        nextItem = self.queue.models.firstObject;
    }
    else
    {
        nextItem = [self.queue itemAfterTimestamp:[queueItem timestamp]];
    }
    
    if (!nextItem) {
        [self stop];
        return;
    }
    
    self.currentQueueItem = nextItem;
    
    if ([nextItem type] == ZZIncomingEventTypeVideo)
    {
        [self _playNextVideo];
        return;
    }
    
    // else:
    
    ZZMessageGroup *messageModel = [self.queue messageGroupAfterTimestamp:[queueItem timestamp]];
    
    if (!messageModel) {
        ZZLogWarning(@"Unexpected behaviour");
        return;
    }
    
    [self _showMessageGroup:messageModel];
}



- (void)_failedToPlayCurrentVideo
{
    NSError *error = self.currentPlayerItem.error;
    ZZLogError(@"VideoPlayer#playbackDidFail: %@", error);
    
    ANDispatchBlockToMainQueue(^{

        CGFloat delayAfterToastRemoved = 0.4;
        
        ANDispatchBlockAfter(delayAfterToastRemoved, ^{
            [self _playNextVideoOrStop];
        });
    });
}

- (void)stop
{
    if (!self.isPlayingVideo)
    {
        return;
    }
    
    self.isPlayingVideo = NO;
    
    [self.player pause];
    [self.delegate videoPlayerDidCompletePlaying];
    
    self.currentQueueItem = nil;
    self.queue = nil;
}

- (void)updateVideoCount
{
    self.indicator.segmentScheme = [self.queue.models.rac_sequence map:^id(NSObject<ZZPlaybackQueueItem> *item) {
        return [[PlaybackSegment alloc] initWithType:item.type];
    }].array;
    
    NSUInteger currentSegmentIndex = [self.queue.models indexOfObject:self.currentVideoModel];
    [self updateCurrentVideoIndex:currentSegmentIndex];
}

- (void)updateCurrentVideoIndex:(NSInteger)index
{
    self.indicator.currentSegment = index;
}

- (void)updatePlaybackProgress:(CGFloat)progress
{
    self.indicator.segmentProgress = progress;
}

- (UIView *)playbackIndicator
{
    return self.indicator;
}

- (void)setMuted:(BOOL)muted
{
    _muted = muted;
    self.player.volume = (float)!muted;
}

- (void)setPaused:(BOOL)paused
{
    self.player.rate = !paused;
}

- (BOOL)paused
{
    return self.player.rate;
}

- (ZZFriendDomainModel *)friendModel
{
    return self.queue.friendModel;
}

#pragma mark ZZPlayerQueueDelegate

- (void)queueWillChange
{
    [self.player pause];
}

- (void)queueDidChange
{
    [self updateVideoCount];
    
    if (!self.waitsForMessageCallback && !self.dragging)
    {
        [self.player play];
    }
}

- (void)loadVideoModel:(ZZVideoDomainModel *)videoModel
{
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoModel.videoURL];
    [self.player insertItem:item afterItem:nil];
}

- (void)unloadVideoModel:(ZZVideoDomainModel *)videoModel
{
    AVPlayerItem *item = [self _itemForVideoModel:videoModel];

    if (!item)
    {
        return;
    }

    [self.player removeItem:item];
}

- (void)unloadAllVideoModels
{
    [self.player removeAllItems];
}

@end

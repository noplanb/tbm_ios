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
#import "ZZFileHelper.h"
#import "ZZVideoDataProvider.h"
#import "NSArray+ANAdditions.h"
#import "ZZSegmentSchemeItem.h"

@import AVKit;
@import AVFoundation;

static NSInteger const ZZPlayerCurrentVideoIndex = NSIntegerMax;

@interface ZZPlayerController () <PlaybackIndicatorDelegate>

// UI elements
@property (nonatomic, strong) AVPlayerViewController *playerController;
@property (nonatomic, strong) PlaybackIndicator *indicator;

@property (nonatomic, strong, readonly) AVPlayerItem *currentItem;
@property (nonatomic, strong, readonly) AVQueuePlayer *player;

// All videos:
@property (nonatomic, strong) NSArray <ZZVideoDomainModel *> *allVideoModels; // video models passed to player
@property (nonatomic, strong) NSArray <ZZVideoDomainModel *> *loadedVideoModels; // video models to play

// Text messages:
@property (nonatomic, strong) NSArray <ZZMessageDomainModel *> *messages;

// Text + video
@property (nonatomic, strong) NSArray <id<ZZSegmentSchemeItem>> *mixedModels;
- (void)updateMixedModels;

@property (nonatomic, strong, readonly) ZZVideoDomainModel *currentVideoModel;
@property (nonatomic, strong, readwrite) ZZFriendDomainModel *currentFriendModel;

@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign, readwrite) BOOL isPlayingVideo;

@end

@implementation ZZPlayerController

@dynamic player;
@dynamic currentVideoModel;
@dynamic currentItem;
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
    NSArray <ZZVideoDomainModel *> *videoModels = friendModel.videos;
    self.allVideoModels = [self _filterVideoModels:videoModels];
    
    if (!self.hideTextMessages) {
        self.messages = friendModel.messages;        
    }
    
    [self updateMixedModels];
    
    [[AVAudioSession sharedInstance] startPlaying]; // Allow whether locked or unlocked. Users wont know about it till we tell them it is unlocked.
    self.currentFriendModel = friendModel;
    [self _prepareToPlay];
    [self _loadVideoModels:self.allVideoModels];
    [self _startPlayingIfPossible];
    [self updateVideoCount];
}

- (void)appendLastVideoFromFriendModel:(ZZFriendDomainModel *)friendModel
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    NSArray *actualVideos = [friendModel.videos sortedArrayUsingDescriptors:@[sortDescriptor]];
    ZZVideoDomainModel *videoModel = [actualVideos lastObject];
    
    if (videoModel.incomingStatusValue != ZZVideoIncomingStatusDownloaded) {
        return;
    }
    
    NSArray <NSString *> *videoIDs = [self.loadedVideoModels.rac_sequence map:^id(ZZVideoDomainModel *videoModel) {
        return videoModel.videoID;
    }].array;

    if ([videoIDs containsObject:videoModel.videoID])
    {
        return;
    }
    
    ZZLogInfo(@"Appending video id = %@", videoModel.videoID);
    
    [self _loadModel:videoModel];
    
    self.allVideoModels = [self.allVideoModels arrayByAddingObject:videoModel];
    [self updateMixedModels];
    
    [self _updateSegments];
    
}

- (void)_prepareToPlay
{
    [self stop];
    [self _makePlayer];
    self.isPlayingVideo = YES;
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
    
    NSUInteger currentVideoIndex = [self.allVideoModels indexOfObject:self.currentVideoModel];
    
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
    [self _changeCurrentVideoToVideoWithIndex:index completion:^{
        
        if (self.currentItem.status != AVPlayerItemStatusReadyToPlay)
        {
            return ;
        }
        
        [self.currentItem cancelPendingSeeks];
        
        CMTime seekTime = CMTimeMake(self.currentItem.duration.value * position, self.currentItem.duration.timescale);
        
        [self.currentItem seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }];
}

- (NSArray <ZZVideoDomainModel *> *)_filterVideoModels:(NSArray <ZZVideoDomainModel *> *)videoModels
{
    videoModels = [videoModels.rac_sequence filter:^BOOL(ZZVideoDomainModel *videoModel) {
        return (videoModel.incomingStatusValue == ZZVideoIncomingStatusDownloaded ||
                videoModel.incomingStatusValue == ZZVideoIncomingStatusViewed) &&
        [ZZFileHelper isFileExistsAtURL:videoModel.videoURL];
    }].array;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    videoModels = [videoModels sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    return videoModels;
}

- (void)_videosUnavailable:(NSArray <ZZVideoDomainModel *> *)videoModels
{
    [self.player pause];
    
    ZZLogInfo(@"videos unavailable: %lu", (unsigned long) videoModels.count);
    
    [videoModels enumerateObjectsUsingBlock:^(ZZVideoDomainModel * _Nonnull videoModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _unloadVideoModel:videoModel];
    }];
    
    ZZLogInfo(@"videos loaded: %lu", (unsigned long) self.loadedVideoModels.count);
    
    [self _updateSegments];
    [self _startPlayingIfPossible];
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
                                                              
                                                              AVPlayerItem *item = self.currentItem;
                                                              
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

- (void)_loadVideoModels:(NSArray <ZZVideoDomainModel *> *)videoModels
{
    [self.player removeAllItems];
    self.loadedVideoModels = @[];
    
    for (ZZVideoDomainModel *model in videoModels)
    {
        [self _loadModel:model];
    }
}

- (void)_loadModel:(ZZVideoDomainModel *)videoModel
{
    ZZLogInfo(@"Loading video model id = %@", videoModel.videoID);
    
    self.loadedVideoModels = [self.loadedVideoModels arrayByAddingObject:videoModel];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoModel.videoURL];
    [self.player insertItem:item afterItem:nil];
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

- (void)_unloadVideoModel:(ZZVideoDomainModel *)videoModel
{
    NSInteger index = [self.loadedVideoModels indexOfObject:videoModel];
    
    if (index == NSNotFound)
    {
        return;
    }
    
    ZZLogInfo(@"Unloading %@ | index = %ld", videoModel.videoID, (long)index);
    self.loadedVideoModels = [self.loadedVideoModels zz_arrayWithoutObject:videoModel];
    self.allVideoModels = [self.allVideoModels zz_arrayWithoutObject:videoModel];
    [self updateMixedModels];
    
    AVPlayerItem *item = [self _itemForVideoModel:videoModel];
    
    if (!item)
    {
        return;
    }
    
    [self.player removeItem:item];
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
    
    NSUInteger currentSegmentIndex = [self.allVideoModels indexOfObject:self.currentVideoModel];
    
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
            [self.player advanceToNextItem];
        }
        
        [self.player pause];
    }
    else
    {
        NSRange rangeToPlay = NSMakeRange(indexToPlay, self.allVideoModels.count - indexToPlay);
        [self _loadVideoModels:[self.allVideoModels subarrayWithRange:rangeToPlay]];
        
        [self updateCurrentVideoIndex:rangeToPlay.location];
    }
    
    if (!completion)
    {
        return;
    }
    
    [[[RACObserve(self.currentItem, status) filter:^BOOL(id value) {
        
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
    AVURLAsset *URLAsset = (id)self.currentItem.asset;
    
    for (ZZVideoDomainModel *videoModel in self.loadedVideoModels)
    {
        if ([videoModel.videoURL.path isEqualToString:URLAsset.URL.path])
        {
            return videoModel;
        }
    }
    
    return nil;
}

- (AVPlayerItem *)currentItem
{
    return self.player.items.firstObject;
}

- (void)_addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didFinishPlayingItemNotification:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_videosDeletedNotification)
                                                 name:ZZVideosDeletedNotification
                                               object:nil];
}

- (void)_videosDeletedNotification
{
    ZZLogInfo(@"_videosDeletedNotification");
    
    if (!self.isPlayingVideo)
    {
        return;
    }
    
    NSArray <ZZVideoDomainModel *> *availableVideos =
        [ZZVideoDataProvider sortedIncomingVideosForUserWithID:self.currentFriendModel.idTbm];
    
    NSArray <NSString *> *availableVideoIDs = [availableVideos.rac_sequence map:^id(ZZVideoDomainModel *videoModel) {
        return videoModel.videoID;
    }].array;
    
    NSMutableArray <ZZVideoDomainModel *> *unavailableVideos = [NSMutableArray new];
    
    [self.allVideoModels enumerateObjectsUsingBlock:^(ZZVideoDomainModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![availableVideoIDs containsObject:obj.videoID])
        {
            [unavailableVideos addObject:obj];
        }
    }];
    
    if (!ANIsEmpty(unavailableVideos))
    {
        [self _videosUnavailable:unavailableVideos];
    }
}

- (void)_updateSegments
{
    NSUInteger currentSegmentIndex = [self.allVideoModels indexOfObject:self.currentVideoModel];
    
    [self updateVideoCount];
    [self updateCurrentVideoIndex:currentSegmentIndex];
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
    return [self _itemAfterTimestamp:[self.currentVideoModel timestamp]];
}

- (void)_playNextVideo
{
    [self.player advanceToNextItem];
    [self updateCurrentVideoIndex:[self.mixedModels indexOfObject:self.currentVideoModel]];
    [self _startPlayingIfPossible];
}

- (void)_didFinishPlayingItemNotification:(NSNotification *)notification
{
    AVPlayerItem *item = notification.object;
    
    if (item != self.currentItem)
    {
        return;
    }
    
    ZZLogDebug(@"VideoPlayer#playbackDidFinishNotification");
    
    if (self.isPlayingVideo)
    {
        [self _playNextVideoOrStop];
    }
}

- (void)_showMessage:(ZZMessageDomainModel *)messageModel
{
    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:messageModel.friendID];
    
    MessagePopoperModel *popoverModel = [MessagePopoperModel new];
    popoverModel.text = messageModel.body;
    popoverModel.name = friendModel.fullName;
    popoverModel.date = [NSDate dateWithTimeIntervalSince1970:messageModel.timestamp];

    [[MessageHandler sharedInstance] markAsRead:messageModel];
    [self updateCurrentVideoIndex:[self.mixedModels indexOfObject:messageModel]];

    [self.delegate needsShowMessage:popoverModel completion:^(BOOL shouldContinue) {
        if (shouldContinue) {
            [self _continueAfterItem:messageModel];
        }
        else {
            [self stop];
        }
    }];
}

- (void)_continueAfterItem:(id<ZZSegmentSchemeItem>)item
{
    id<ZZSegmentSchemeItem> nextItem = [self _itemAfterTimestamp:[item timestamp]];
    
    if (!nextItem) {
        [self stop];
        return;
    }
    
    if ([nextItem type] == ZZIncomingEventTypeVideo)
    {
        [self _playNextVideo];
        return;
    }
    
    // else:
    
    ZZMessageDomainModel *messageModel = [self _messageAfterTimestamp:[item timestamp]];
    
    if (!messageModel) {
        ZZLogWarning(@"Unexpected behaviour");
        return;
    }
    
    [self _showMessage:messageModel];
}

- (id<ZZSegmentSchemeItem>)_itemAfterTimestamp:(NSTimeInterval)timestamp
{
    for (id<ZZSegmentSchemeItem> item in self.mixedModels) {
        if ([item timestamp] > timestamp) {
            return item;
        }
    }
    
    return nil;
}

- (ZZMessageDomainModel *)_messageAfterTimestamp:(NSTimeInterval)timestamp
{
    for (ZZMessageDomainModel *messageModel in self.messages) {
        if ([messageModel timestamp] > timestamp) {
            return messageModel;
        }
    }
    
    return nil;
}

- (void)updateMixedModels
{
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    
    NSArray <id<ZZSegmentSchemeItem>> *items = self.messages;
    items = [items arrayByAddingObjectsFromArray:self.allVideoModels];
    items = [items sortedArrayUsingDescriptors:@[descriptor]];

    self.mixedModels = items;
}

- (void)_failedToPlayCurrentVideo
{
    NSError *error = self.currentItem.error;
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
    
    self.currentFriendModel = nil;
}

- (void)updateVideoCount
{
    self.indicator.segmentScheme = [self.mixedModels.rac_sequence map:^id(NSObject<ZZSegmentSchemeItem> *item) {
        return [[PlaybackSegment alloc] initWithType:item.type];
    }].array;
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

- (void)setPaused:(BOOL)paused {
    self.player.rate = !paused;
}

- (BOOL)paused {
    return self.player.rate;
}

@end

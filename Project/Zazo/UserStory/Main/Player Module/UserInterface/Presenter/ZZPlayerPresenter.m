//
//  ZZPlayerPresenter.m
//  Zazo
//

#import "ZZPlayerPresenter.h"
#import "ZZPlayer.h"

@import MediaPlayer;
@import AVKit;
@import UIKit;

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
#import "NSDate+ZZAdditions.h"
#import "ZZPlayerWireframe.h"

static NSInteger const ZZPlayerCurrentVideoIndex = NSIntegerMax;

@interface ZZPlayerPresenter ()

// UI elements
@property (nonatomic, strong) AVPlayerViewController *playerController;
@property (nonatomic, strong, readonly) AVQueuePlayer *player;

// All videos:
@property (nonatomic, strong) NSArray <ZZVideoDomainModel *> *allVideoModels; // video models passed to player
@property (nonatomic, strong) NSArray <ZZVideoDomainModel *> *loadedVideoModels; // video models to play

// Current video:
@property (nonatomic, strong) ZZFriendDomainModel *currentFriendModel;
@property (nonatomic, strong, readonly) ZZVideoDomainModel *currentVideoModel;
@property (nonatomic, strong, readonly) AVPlayerItem *currentItem;

@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign) BOOL waitingForLoad;

@end

@implementation ZZPlayerPresenter

@synthesize isPlayingVideo = _isPlayingVideo;

- (void)configurePresenterWithUserInterface:(UIViewController<ZZPlayerViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    
    [self.userInterface view]; // loading view
    
    self.userInterface.playerController = self.playerController;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
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
                                                              
          [self videoPlayingProgress:relativePlaybackPosition];
    }];
    
}

#pragma mark UI events

- (void)didTapVideo
{
    if (self.isPlayingVideo)
    {
        [self stop];
    }
    else
    {
        [self _loadVideoModels:self.allVideoModels];
        [self _startPlayingIfPossible];
    }
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
    }
    
    if (!completion)
    {
        return;
    }
    
    self.waitingForLoad = YES;
    
    [[[RACObserve(self.currentItem, status) filter:^BOOL(id value) {
        
        return [value integerValue] == AVPlayerStatusReadyToPlay;
        
    }] take:1] subscribeNext:^(id x) {
        
        self.waitingForLoad = NO;
        completion();
        
    }];
}

- (void)didTapBackground
{
    [self stop];
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

- (void)playVideoModels:(NSArray <ZZVideoDomainModel *> *)videoModels
{
    self.dragging = NO;
    
    self.allVideoModels = [self _filterVideoModels:videoModels];
    
    [ZZGridActionStoredSettings shared].incomingVideoWasPlayed = YES;
    
    [[AVAudioSession sharedInstance] startPlaying]; // Allow whether locked or unlocked. Users wont know about it till we tell them it is unlocked.
    
    self.currentFriendModel = [ZZFriendDataProvider friendWithItemID:self.allVideoModels.firstObject.relatedUserID];
    
    [self _updatePlayersFrame];
    
    [self _prepareToPlay];

    [self _loadVideoModels:self.allVideoModels];
    
    [self _startPlayingIfPossible];
    
    [self.userInterface updateVideoCount:self.allVideoModels.count];
}

- (void)_prepareToPlay
{
    [self _stopVideoPlayerStateIfNeeded];
    
    [self _makePlayer];
    
    self.isPlayingVideo = YES;
    
}

- (void)_startPlayingIfPossible
{
    if (!self.currentVideoModel)
    {
        return;
    }
    
    if (self.dragging)
    {
        return;
    }
    
    [self.player play];
        
    [self.delegate videoPlayerDidStartVideoModel:self.currentVideoModel];
    
    [self _showDateForVideoModel:self.currentVideoModel];
    
    [[ZZVideoStatusHandler sharedInstance]
     setAndNotityViewedIncomingVideoWithFriendID:self.currentFriendModel.idTbm videoID:self.currentVideoModel.videoID];
    
    [[ZZRemoteStorageTransportService updateRemoteStatusForVideoWithItemID:self.currentVideoModel.videoID
                                                                  toStatus:ZZRemoteStorageVideoStatusViewed
                                                                friendMkey:self.currentFriendModel.mKey
                                                                friendCKey:self.currentFriendModel.cKey] subscribeNext:^(id x) {}];
    
    
    
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

- (void)_updatePlayersFrame
{
    CGRect cellFrame = [self.grid frameOfViewForFriendModelWithID:self.currentFriendModel.idTbm];
    
    cellFrame = [self.userInterface.view convertRect:cellFrame
                                            fromView:self.userInterface.view.window];
    
    CGFloat ZZCellBorderWidth = 4;
    
    cellFrame = CGRectOffset(cellFrame, -ZZCellBorderWidth, -ZZCellBorderWidth);
    
    self.userInterface.initialPlayerFrame = cellFrame;

}

- (void)stop
{
    [self _stopWithPlayChecking:YES];
}

- (void)appendLastVideoFromFriendModel:(ZZFriendDomainModel *)friendModel
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    
    NSArray *actualVideos = [friendModel.videos sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    ZZVideoDomainModel *lastVideoModel = [actualVideos lastObject];
    
    if (![self.loadedVideoModels containsObject:lastVideoModel])
    {
        [self _loadModel:lastVideoModel];
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

- (void)_showDateForVideoModel:(ZZVideoDomainModel *)videoModel
{
    NSTimeInterval timestamp = videoModel.videoID.doubleValue / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    [self.userInterface updatePlayerText:[date zz_formattedDate]];
}

- (void)_stopVideoPlayerStateIfNeeded
{
    if (self.isPlayingVideo)
    {
        [self _stopPlaying];
    }
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
    self.loadedVideoModels = [self.loadedVideoModels arrayByAddingObject:videoModel];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoModel.videoURL];
    [self.player insertItem:item afterItem:nil];
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
        self.isPlayingVideo = NO;
        
        [self _stopPlaying];
    }
    else if (!isCheckPlaying)
    {
        self.isPlayingVideo = NO;

        [self _stopPlaying];
    }
}

- (void)_stopPlaying
{
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
    return self.currentVideoModel != self.loadedVideoModels.lastObject;
}

- (void)_playNext
{
    [self.player advanceToNextItem];
    [self.userInterface updateCurrentVideoIndex:[self.allVideoModels indexOfObject:self.currentVideoModel]];
    [self _startPlayingIfPossible];
}

- (void)videoPlayingProgress:(CGFloat)progress // zero if no progress
{
    [self.userInterface updatePlaybackProgress:progress];
}

// temporary
- (void)_updateFriendVideoStatusWithFriend:(ZZFriendDomainModel*)friendModel
                                     video:(ZZVideoDomainModel*)videoModel
                                videoIndex:(NSInteger)index
{
    NSInteger arrayBoundsIndex = 1;
    
    if (index == (self.loadedVideoModels.count - arrayBoundsIndex) &&
        friendModel.lastIncomingVideoStatus != videoModel.incomingStatusValue)
    {
        friendModel.lastIncomingVideoStatus = videoModel.incomingStatusValue;
        
        [ZZFriendDataUpdater updateFriendWithID:friendModel.idTbm
                     setLastIncomingVideoStatus: videoModel.incomingStatusValue];
    }
}


#pragma mark - Properties

- (AVPlayerViewController *)playerController
{
    if (!_playerController)
    {
        _playerController = [AVPlayerViewController new];

    }
    return _playerController;
}


@dynamic player;

- (AVQueuePlayer *)player
{
    return (id)self.playerController.player;
}

@dynamic currentVideoModel;

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

- (void)setIsPlayingVideo:(BOOL)isPlayingVideo
{
    _isPlayingVideo = isPlayingVideo;
    
    [self.userInterface hidePlayerAnimated:^{
        
        self.wireframe.playerVisible = isPlayingVideo;
    }];
    
}

@dynamic currentItem;

- (AVPlayerItem *)currentItem
{
    return self.player.items.firstObject;
}

#pragma mark Events

- (void)_failedToPlayCurrentVideo
{
    NSError *error = self.currentItem.error;
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
    
    if (item != self.currentItem)
    {
        return;
    }    
    
    ZZLogDebug(@"VideoPlayer#playbackDidFinishNotification");
    
    if (self.isPlayingVideo)
    {
        [self _playNextOrStop];
    }
}



@end

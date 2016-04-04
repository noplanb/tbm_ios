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
#import "MagicalRecord.h"
#import "ZZFriendDataProvider.h"
#import "iToast.h"
#import "ZZFriendDomainModel.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZRemoteStorageValueGenerator.h"
#import "ZZRemoteStorageTransportService.h"
#import "ZZVideoStatuses.h"
#import "ZZVideoDataProvider.h"
#import "ZZVideoDataUpdater.h"
#import "ZZFileHelper.h"
#import "ZZVideoStatusHandler.h"
#import "ZZFriendDataHelper.h"
#import "ZZFriendDataUpdater.h"
#import "AVAudioSession+ZZAudioSession.h"


@interface ZZVideoPlayer ()

@property (nonatomic, strong) MPMoviePlayerController* moviePlayerController;
@property (nonatomic, strong) UIButton* tapButton;
@property (nonatomic, strong) NSArray* videoModelsArray;
@property (nonatomic, strong) ZZFriendDomainModel* playedFriend;
@property (nonatomic, strong) NSMutableArray* playedVideoUrls;
@property (nonatomic, strong) NSURL* currentPlayedUrl;
@property (nonatomic, strong, readonly) UILabel *date;

@end

@implementation ZZVideoPlayer

+ (instancetype)videoPlayerWithDelegate:(id<ZZVideoPlayerDelegate>)delegate
{
    ZZVideoPlayer* player = [self new];
    player.delegate = delegate;
    return player;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self addNotifications];
        self.playedVideoUrls = [NSMutableArray array];
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
    NSInteger nextVideoIndex = 1;
    
    if ((friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading) &&
        ([ZZFriendDataHelper unviewedVideoCountWithFriendID:friendModel.idTbm] == twoNotViewedVideosCount) &&
        videoModel.incomingStatusValue == ZZVideoIncomingStatusViewed)
    {
        actualVideoModel = models[nextVideoIndex];
    }
    
    return actualVideoModel;
}

- (void)playOnView:(UIView*)view withVideoModels:(NSArray*)videoModels
{
    [self _updateVideoPlayerStateIfNeeded];
    
    self.moviePlayerController.contentURL = nil;
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    self.videoModelsArray = [videoModels sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    [self _configurePlayedUrlsWithModels:self.videoModelsArray];
    
    if (view != self.moviePlayerController.view.superview && view)
    {
        self.moviePlayerController.view.frame = view.bounds;
        [view addSubview:self.moviePlayerController.view];
        [view bringSubviewToFront:self.moviePlayerController.view];
    }
    if (!ANIsEmpty(videoModels))//&& ![self.currentPlayQueue isEqualToArray:URLs]) //TODO: if current playback state is equal to user's play list
    {
//        ZZVideoDomainModel* playedVideoModel = [self.videoModelsArray firstObject];
        ZZVideoDomainModel* playedVideoModel = [self _actualVideoDomainModelWithSortedModels:self.videoModelsArray];
        
        
        self.playedFriend = [ZZFriendDataProvider friendWithItemID:playedVideoModel.relatedUserID];
        self.currentPlayedUrl = playedVideoModel.videoURL;
        
        ZZVideoDomainModel *viewedVideo = [ZZVideoDataProvider itemWithID:playedVideoModel.videoID];
        
        if ((viewedVideo.incomingStatusValue == ZZVideoIncomingStatusDownloaded ||
            viewedVideo.incomingStatusValue == ZZVideoIncomingStatusViewed) &&
            [ZZFileHelper isFileExistsAtURL:self.currentPlayedUrl])
        {
            
            self.moviePlayerController.contentURL = self.currentPlayedUrl;
            
            //save video state
            
            self.moviePlayerController.view.frame = view.bounds;
            [view addSubview:self.moviePlayerController.view];
            
            [self.moviePlayerController play]; // TODO: cleanup this.Have only one entry point to play video and update this flags
            [ZZGridActionStoredSettings shared].incomingVideoWasPlayed = YES;
            
            
            [self.delegate videoPlayerURLWasStartPlaying:[ZZVideoDataProvider videoUrlWithVideoModel:viewedVideo]];
            
            self.isPlayingVideo = YES;
            
            // Allow whether locked or unlocked. Users wont know about it till we tell them it is unlocked.
            [[AVAudioSession sharedInstance] startPlaying];

            
            [[ZZVideoStatusHandler sharedInstance]
             setAndNotityViewedIncomingVideoWithFriendID:self.playedFriend.idTbm videoID:viewedVideo.videoID];
            
            [[ZZRemoteStorageTransportService updateRemoteStatusForVideoWithItemID:viewedVideo.videoID
                                                                          toStatus:ZZRemoteStorageVideoStatusViewed
                                                                        friendMkey:self.playedFriend.mKey
                                                                        friendCKey:self.playedFriend.cKey] subscribeNext:^(id x) {}];
        }
        else
        {
            [self _playNextOrStop];
        }
    }
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
    [self.playedVideoUrls removeAllObjects];
    
    [self.playedVideoUrls addObjectsFromArray:[[self.videoModelsArray.rac_sequence map:^id(ZZVideoDomainModel* value) {
        
        ZZVideoDomainModel *videoModel = [ZZVideoDataProvider itemWithID:value.videoID];
        return [ZZVideoDataProvider videoUrlWithVideoModel:videoModel];
        
    }] array]];
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
    self.playedFriend.isVideoStopped = YES;
    [self.delegate videoPlayerURLWasFinishedPlaying:self.moviePlayerController.contentURL
                                withPlayedUserModel:self.playedFriend];
    self.playedFriend = nil;
}

- (void)toggle
{
    if (self.isPlayingVideo)
    {
        [self stop];
    }
    else
    {
        [self playOnView:nil withVideoModels:self.videoModelsArray];
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

- (NSInteger)_nextVideoIndex
{
    __block NSInteger index = NSNotFound;
    [self.playedVideoUrls enumerateObjectsUsingBlock:^(NSURL*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.path isEqualToString:self.currentPlayedUrl.path])
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
    NSInteger index = [self _nextVideoIndex];
    
    NSURL* nextUrl = nil;
    
    if (index < self.playedVideoUrls.count)
    {
        nextUrl = self.playedVideoUrls[index];
    }
    else
    {
        
        ZZVideoDomainModel* lastModel = [self.videoModelsArray lastObject];
        
        self.isPlayingVideo = NO;
        [self.delegate videoPlayerURLWasFinishedPlaying:[ZZVideoDataProvider videoUrlWithVideoModel:lastModel] withPlayedUserModel:self.playedFriend];
        [self.moviePlayerController.view removeFromSuperview];
        self.playedFriend = nil;
    }
    
    if (nextUrl)
    {
        ZZVideoDomainModel* playedVideoModel = self.videoModelsArray[index];
        
        ZZFriendDomainModel *relatedUserModel = [ZZFriendDataProvider friendWithItemID:playedVideoModel.relatedUserID];
        
        self.playedFriend = relatedUserModel;
        self.currentPlayedUrl = nextUrl;
        
        if ((playedVideoModel.incomingStatusValue == ZZVideoIncomingStatusDownloaded ||
            playedVideoModel.incomingStatusValue == ZZVideoIncomingStatusViewed) &&
            [ZZFileHelper isFileExistsAtURL:self.currentPlayedUrl])
        {
            //save video state
            
            self.moviePlayerController.contentURL = nextUrl;
            
            [[ZZVideoStatusHandler sharedInstance] setAndNotityViewedIncomingVideoWithFriendID:playedVideoModel.relatedUserID videoID:playedVideoModel.videoID];
            
            [ZZRemoteStorageTransportService updateRemoteStatusForVideoWithItemID:playedVideoModel.videoID
                                                                         toStatus:ZZRemoteStorageVideoStatusViewed
                                                                       friendMkey:relatedUserModel.mKey
                                                                       friendCKey:relatedUserModel.cKey];
            
            [self.delegate videoPlayerURLWasStartPlaying:nextUrl];
            
            self.isPlayingVideo = YES;
            
            // Allow play from ear even if locked. User wont know its available till he unlocks it.
            [[AVAudioSession sharedInstance] startPlaying];
            
            relatedUserModel = [ZZFriendDataProvider friendWithItemID:playedVideoModel.relatedUserID];
            playedVideoModel = [ZZVideoDataProvider itemWithID:playedVideoModel.videoID];
            
            [self _updateFriendVideoStatusWithFriend:relatedUserModel video:playedVideoModel videoIndex:index];
            
            [self.moviePlayerController play];
        }
        else
        {
            [self _playNextOrStop];
        }
    }
}


//TODO: temprorary
- (void)_updateFriendVideoStatusWithFriend:(ZZFriendDomainModel*)friendModel
                                    video:(ZZVideoDomainModel*)videoModel
                               videoIndex:(NSInteger)index
{
    NSInteger arrayBoundsIndex = 1;
    
    if (index == (self.playedVideoUrls.count - arrayBoundsIndex) &&
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
    
    NSMutableArray* videoModelsCopy = [self.videoModelsArray mutableCopy];
    ZZVideoDomainModel* lastVideoModel = [acutalVideos lastObject];
    
    NSURL* lastVideoUrl = [ZZVideoDataProvider videoUrlWithVideoModel: lastVideoModel];
    
    if (![self.playedVideoUrls containsObject:lastVideoUrl])
    {
        [self.playedVideoUrls addObject:lastVideoUrl];
        [videoModelsCopy addObject:lastVideoModel];
        self.videoModelsArray = videoModelsCopy;
    }

}

- (void)_playerStateWasUpdated
{
    if (self.moviePlayerController.playbackState == MPMoviePlaybackStatePlaying)
    {
        [self.delegate videoPlayerURLWasStartPlaying:self.moviePlayerController.contentURL];
    }
}


#pragma mark - Helpers


- (ZZFriendDomainModel*)playedFriendModel
{
    return self.playedFriend;
}

- (BOOL)isVideoPlayingWithFriendModel:(ZZFriendDomainModel*)friendModel
{
    return (self.isPlayingVideo &&
            [friendModel.idTbm isEqualToString:self.playedFriend.idTbm]);
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

@end

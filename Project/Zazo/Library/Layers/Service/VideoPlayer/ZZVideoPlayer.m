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
#import "TBMVideo.h"
#import "MagicalRecord.h"
#import "ZZFriendDataProvider.h"
#import "TBMFriend.h"
#import "iToast.h"
#import "ZZFriendDomainModel.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZRemoteStorageValueGenerator.h"
#import "ZZRemoteStoageTransportService.h"
#import "ZZVideoStatuses.h"
#import "ZZVideoDataProvider.h"
#import "ZZFileHelper.h"

@interface ZZVideoPlayer ()

@property (nonatomic, strong) MPMoviePlayerController* moviePlayerController;
@property (nonatomic, strong) UIButton* tapButton;
@property (nonatomic, strong) NSArray* videoModelsArray;
@property (nonatomic, strong) ZZFriendDomainModel* playedFriend;
@property (nonatomic, strong) NSMutableArray* playedVideoUrls;
@property (nonatomic, strong) NSURL* currentPlayedUrl;

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

- (void)playOnView:(UIView*)view withURLs:(NSArray*)URLs
{
    self.moviePlayerController.contentURL = nil;
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    self.videoModelsArray = [URLs sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    [self _configurePlayedUrlsWithModels:self.videoModelsArray];
    
    if (view != self.moviePlayerController.view.superview && view)
    {
        self.moviePlayerController.view.frame = view.bounds;
        [view addSubview:self.moviePlayerController.view];
        [view bringSubviewToFront:self.moviePlayerController.view];
    }
    if (!ANIsEmpty(URLs))//&& ![self.currentPlayQueue isEqualToArray:URLs]) //TODO: if current playback state is equal to user's play list
    {
        ZZVideoDomainModel* playedVideoModel = [self.videoModelsArray firstObject];
        self.playedFriend = playedVideoModel.relatedUser;
        self.currentPlayedUrl = playedVideoModel.videoURL;
        
        TBMVideo* viewedVideo = [ZZVideoDataProvider findWithVideoId:playedVideoModel.videoID];
        
        if ((viewedVideo.statusValue == ZZVideoIncomingStatusDownloaded ||
            viewedVideo.statusValue == ZZVideoIncomingStatusViewed) &&
            [ZZFileHelper isFileExistsAtURL:self.currentPlayedUrl])
        {
            
            self.moviePlayerController.contentURL = self.currentPlayedUrl;
            
            //save video state
            [self _updateViewedVideoCounterWithVideoDomainModel:playedVideoModel];
            
            self.moviePlayerController.view.frame = view.bounds;
            [view addSubview:self.moviePlayerController.view];
            
            [self.moviePlayerController play]; // TODO: cleanup this.Have only one entry point to play video and update this flags
            [ZZGridActionStoredSettings shared].incomingVideoWasPlayed = YES;
            
            
            [self.delegate videoPlayerURLWasStartPlaying:[ZZVideoDataProvider videoUrlWithVideo:viewedVideo]];
            
            self.isPlayingVideo = YES;
            [UIDevice currentDevice].proximityMonitoringEnabled = [ZZGridActionStoredSettings shared].earpieceHintWasShown;
            //TODO:coredata
            TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:playedVideoModel.relatedUser.idTbm];
            [friend setViewedWithIncomingVideo:viewedVideo];
            
            [[ZZRemoteStoageTransportService updateRemoteStatusForVideoWithItemID:viewedVideo.videoId
                                                                        toStatus:ZZRemoteStorageVideoStatusViewed
                                                                      friendMkey:friend.mkey
                                                                      friendCKey:friend.ckey] subscribeNext:^(id x) {}];
        }
        else
        {
            [self _playNextOrStop];
        }
    }
}

- (void)_configurePlayedUrlsWithModels:(NSArray*)videoModels
{
    [self.playedVideoUrls removeAllObjects];
    
    [self.playedVideoUrls addObjectsFromArray:[[self.videoModelsArray.rac_sequence map:^id(ZZVideoDomainModel* value) {
        
        TBMVideo* video = [ZZVideoDataProvider findWithVideoId:value.videoID];
        return [ZZVideoDataProvider videoUrlWithVideo:video];
        
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
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
}

- (void)toggle
{
    if (self.isPlayingVideo)
    {
        [self stop];
    }
    else
    {
        [self playOnView:nil withURLs:self.videoModelsArray];
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
            [UIDevice currentDevice].proximityMonitoringEnabled = NO;
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

- (void)_updateViewedVideoCounterWithVideoDomainModel:(ZZVideoDomainModel*)playedVideoModel
{
    
    
    TBMVideo* viewedVideo = [ZZVideoDataProvider findWithVideoId:playedVideoModel.videoID];
    if (!ANIsEmpty(viewedVideo))
    {
        if (viewedVideo.statusValue == ZZVideoIncomingStatusDownloaded)
        {
            viewedVideo.status = @(ZZVideoIncomingStatusViewed);
            if (playedVideoModel.relatedUser.unviewedCount > 0)
            {
                playedVideoModel.relatedUser.unviewedCount--;
            }
            else
            {
                playedVideoModel.relatedUser.unviewedCount = 0;
            }
            [viewedVideo.managedObjectContext MR_saveToPersistentStoreAndWait];
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
        
        TBMVideo* lastVideo = [ZZVideoDataProvider findWithVideoId:lastModel.videoID];
        self.isPlayingVideo = NO;
        [self.delegate videoPlayerURLWasFinishedPlaying:[ZZVideoDataProvider videoUrlWithVideo:lastVideo] withPlayedUserModel:self.playedFriend];
        [self.moviePlayerController.view removeFromSuperview];
        self.playedFriend = nil;
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        
    }
    
    if (nextUrl)
    {
        ZZVideoDomainModel* playedVideoModel = self.videoModelsArray[index];
        self.playedFriend = playedVideoModel.relatedUser;
        self.currentPlayedUrl = nextUrl;
        
        TBMVideo* viewedVideo = [ZZVideoDataProvider findWithVideoId:playedVideoModel.videoID];
        
        if ((viewedVideo.statusValue == ZZVideoIncomingStatusDownloaded ||
            viewedVideo.statusValue == ZZVideoIncomingStatusViewed) &&
            [ZZFileHelper isFileExistsAtURL:self.currentPlayedUrl])
        {
            //save video state
            [self _updateViewedVideoCounterWithVideoDomainModel:playedVideoModel];
            
            self.moviePlayerController.contentURL = nextUrl;
            
            TBMFriend* friend = [ZZFriendDataProvider entityFromModel:playedVideoModel.relatedUser];
            [friend setViewedWithIncomingVideo:viewedVideo];
            //        [self.playedVideoUrls removeObject:nextUrl];
            [ZZRemoteStoageTransportService updateRemoteStatusForVideoWithItemID:viewedVideo.videoId
                                                                        toStatus:ZZRemoteStorageVideoStatusViewed
                                                                      friendMkey:friend.mkey
                                                                      friendCKey:friend.ckey];
            
            [self.delegate videoPlayerURLWasStartPlaying:nextUrl];
            
            self.isPlayingVideo = YES;
            [UIDevice currentDevice].proximityMonitoringEnabled = [ZZGridActionStoredSettings shared].earpieceHintWasShown;
            
            
            [self.moviePlayerController play];
        }
        else
        {
            [self _playNextOrStop];
        }
    }
}

- (void)updateWithFriendModel:(ZZFriendDomainModel *)friendModel
{
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    NSArray* acutalVideos = [friendModel.videos sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    NSMutableArray* videoModelsCopy = [self.videoModelsArray mutableCopy];
    ZZVideoDomainModel* lastVideoModel = [acutalVideos lastObject];
    
    TBMVideo* lastVideo = [ZZVideoDataProvider findWithVideoId:lastVideoModel.videoID];
    
    
    
    if (!ANIsEmpty(lastVideo))
    {
        NSURL* lastVideoUrl = [ZZVideoDataProvider videoUrlWithVideo:lastVideo];
        if (![self.playedVideoUrls containsObject:lastVideoUrl])
        {
            [self.playedVideoUrls addObject:lastVideoUrl];
            [videoModelsCopy addObject:lastVideoModel];
            self.videoModelsArray = videoModelsCopy;
        }
    }
}

- (void)_playerStateWasUpdated
{
    if (self.moviePlayerController.playbackState == MPMoviePlaybackStatePlaying)
    {
        [self.delegate videoPlayerURLWasStartPlaying:self.moviePlayerController.contentURL];
    }
}

- (BOOL)isDeviceNearEar
{
    return [UIDevice currentDevice].proximityState;
}

- (ZZFriendDomainModel*)playedFriendModel
{
    return self.playedFriend;
}

#pragma mark - Lazy Load

- (MPMoviePlayerController *)moviePlayerController
{
    if (!_moviePlayerController)
    {
        _moviePlayerController = [MPMoviePlayerController new];
        [_moviePlayerController setScalingMode:MPMovieScalingModeFill];
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

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
#import "TBMRemoteStorageHandler.h"
#import "iToast.h"
#import "ZZFriendDomainModel.h"

@interface ZZVideoPlayer ()

@property (nonatomic, strong) MPMoviePlayerController* moviePlayerController;
@property (nonatomic, strong) UIButton* tapButton;
@property (nonatomic, strong) NSArray* videoModelsArray;
@property (nonatomic, strong) ZZFriendDomainModel* playedFriend;

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
    
    
    if (view != self.moviePlayerController.view.superview && view)
    {
        self.moviePlayerController.view.frame = view.bounds;
        [view addSubview:self.moviePlayerController.view];
        [view bringSubviewToFront:self.moviePlayerController.view];
    }
    if (!ANIsEmpty(URLs))//&& ![self.currentPlayQueue isEqualToArray:URLs]) //TODO: if current playback state is equal to user's play list
    {
        ZZVideoDomainModel* playedVideoModel = [self.videoModelsArray firstObject];
        TBMVideo* viewedVideo = [TBMVideo findWithVideoId:playedVideoModel.videoID];
        self.playedFriend = playedVideoModel.relatedUser;
        self.moviePlayerController.contentURL = viewedVideo.videoUrl;//firstVideoUrl;
        
        //save video state
        [self _updateViewedVideoCounterWithVideoDomainModel:playedVideoModel];
        
        self.moviePlayerController.view.frame = view.bounds;
        [view addSubview:self.moviePlayerController.view];
       
        [self.moviePlayerController play];
  
        [self.delegate videoPlayerURLWasStartPlaying:viewedVideo.videoUrl];
        
        self.isPlayingVideo = YES;
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
        
        //TODO:coredata
        TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:playedVideoModel.relatedUser.idTbm];
        [friend setViewedWithIncomingVideo:viewedVideo];
        [TBMRemoteStorageHandler setRemoteIncomingVideoStatus:REMOTE_STORAGE_STATUS_VIEWED
                                                      videoId:viewedVideo.videoId
                                                       friend:friend];
    }
}

- (void)stop
{
    if (self.isPlayingVideo)
    {
        self.isPlayingVideo = NO;
        [self.moviePlayerController.view removeFromSuperview];
        [self.moviePlayerController stop];
        self.playedFriend.isVideoStopped = YES;
        [self.delegate videoPlayerURLWasFinishedPlaying:self.moviePlayerController.contentURL
                                    withPlayedUserModel:self.playedFriend];
        
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    }
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
    OB_DEBUG(@"VideoPlayer#playbackDidFinishNotification: %@", notification.userInfo);
    NSError *error = (NSError *) notification.userInfo[@"error"];
    if ( error != nil){
        OB_ERROR(@"VideoPlayer#playbackDidFinishNotification: %@", error);
        ANDispatchBlockToMainQueue(^{
            [[iToast makeText:NSLocalizedString(@"video-player-not-playable", nil)] show];
        });
        self.isPlayingVideo = NO;
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
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
    TBMVideo* viewedVideo = [TBMVideo findWithVideoId:playedVideoModel.videoID];
    if (!ANIsEmpty(viewedVideo))
    {
        if (viewedVideo.statusValue == INCOMING_VIDEO_STATUS_DOWNLOADED)
        {
            viewedVideo.status = @(INCOMING_VIDEO_STATUS_VIEWED);
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

- (void)_playNext
{
    
    __block NSInteger index;
    [self.videoModelsArray enumerateObjectsUsingBlock:^(ZZVideoDomainModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TBMVideo* viewedVideo = [TBMVideo findWithVideoId:obj.videoID];
        if ([viewedVideo.videoUrl.path isEqualToString:self.moviePlayerController.contentURL.path])
        {
            index = idx;
            *stop = YES;
        }
    }];
    
    index++;
    
    NSURL* nextUrl = nil;
    
    if (index < self.videoModelsArray.count)
    {
        
        ZZVideoDomainModel* nextModel = self.videoModelsArray[index];
        TBMVideo* nextVideo = [TBMVideo findWithVideoId:nextModel.videoID];
        nextUrl = nextVideo.videoUrl;
    }
    else
    {
        ZZVideoDomainModel* lastModel = [self.videoModelsArray lastObject];
        TBMVideo* lastVideo = [TBMVideo findWithVideoId:lastModel.videoID];
        
        [self.delegate videoPlayerURLWasFinishedPlaying:lastVideo.videoUrl withPlayedUserModel:self.playedFriend];
        [self.moviePlayerController.view removeFromSuperview];
        self.isPlayingVideo = NO;
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    }
    
    if (nextUrl)
    {
        ZZVideoDomainModel* playedVideoModel = self.videoModelsArray[index];
        TBMVideo* viewedVideo = [TBMVideo findWithVideoId:playedVideoModel.videoID];
        self.playedFriend = playedVideoModel.relatedUser;
        //save video state
        [self _updateViewedVideoCounterWithVideoDomainModel:playedVideoModel];
        
        self.moviePlayerController.contentURL = nextUrl;
        
        TBMFriend* friend = [ZZFriendDataProvider entityFromModel:playedVideoModel.relatedUser];
        [friend setViewedWithIncomingVideo:viewedVideo];
        [TBMRemoteStorageHandler setRemoteIncomingVideoStatus:REMOTE_STORAGE_STATUS_VIEWED
                                                      videoId:viewedVideo.videoId
                                                       friend:friend];
        
        [self.delegate videoPlayerURLWasStartPlaying:nextUrl];
        [self.moviePlayerController play];
        
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

#pragma mark - Lazy Load

- (MPMoviePlayerController *)moviePlayerController
{
    if (!_moviePlayerController)
    {
        _moviePlayerController = [MPMoviePlayerController new];
        [_moviePlayerController setScalingMode:MPMovieScalingModeFill];
        _moviePlayerController.controlStyle = MPMovieControlStyleNone;
        _moviePlayerController.view.backgroundColor = [UIColor clearColor];
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

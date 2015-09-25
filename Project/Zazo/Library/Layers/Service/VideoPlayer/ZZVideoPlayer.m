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
@property (nonatomic, assign) BOOL isPlayingVideo;
@property (nonatomic, strong) UIButton* tapButton;
@property (nonatomic, strong) NSArray* currentPlayQueue;
@property (nonatomic, strong) NSArray* videoModelsArray;
@property (nonatomic, strong) ZZFriendDomainModel* playedFriend;

@end

@implementation ZZVideoPlayer

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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(changeAudioOutput)
//                                                 name:UIDeviceProximityStateDidChangeNotification
//                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stop)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isPlaying
{
    return (self.moviePlayerController.playbackState == MPMoviePlaybackStatePlaying);
}

- (void)playOnView:(UIView*)view withURLs:(NSArray*)URLs
{
    
    self.moviePlayerController.contentURL = nil;
    self.videoModelsArray = URLs;
    if (view != self.moviePlayerController.view.superview && view)
    {
        self.moviePlayerController.view.frame = view.bounds;
        [view addSubview:self.moviePlayerController.view];
        [view bringSubviewToFront:self.moviePlayerController.view];
        
        NSArray* videoUrls = [[URLs.rac_sequence map:^id(ZZVideoDomainModel* value) {
            return value.videoURL;
        }] array];
        
        self.currentPlayQueue = videoUrls;
    
    }
    if (!ANIsEmpty(URLs))//&& ![self.currentPlayQueue isEqualToArray:URLs]) //TODO: if current playback state is equal to user's play list
    {

        NSURL* firstVideoUrl = [self.currentPlayQueue firstObject];
        ZZVideoDomainModel* playedVideoModel = [self.videoModelsArray firstObject];
        TBMVideo* viewedVideo = [TBMVideo findWithVideoId:playedVideoModel.videoID];

        self.moviePlayerController.contentURL = firstVideoUrl;
        
        //save video state
        [self updateViewedVideoCounterWithVideoDomainModel:playedVideoModel];
        
        self.moviePlayerController.view.frame = view.bounds;
        [view addSubview:self.moviePlayerController.view];
       
        [self.moviePlayerController play];
  
        [self.delegate videoPlayerURLWasStartPlaying:firstVideoUrl];
        
        self.isPlayingVideo = YES;
        TBMFriend* friend = [ZZFriendDataProvider entityFromModel:playedVideoModel.relatedUser];
        [friend setViewedWithIncomingVideo:viewedVideo];
        [TBMRemoteStorageHandler setRemoteIncomingVideoStatus:REMOTE_STORAGE_STATUS_VIEWED
                                                      videoId:viewedVideo.videoId
                                                       friend:friend];
        
    }
}


- (void)updateViewedVideoCounterWithVideoDomainModel:(ZZVideoDomainModel*)playedVideoModel
{
    
    TBMVideo* viewedVideo = [TBMVideo findWithVideoId:playedVideoModel.videoID];
    viewedVideo.status = @(INCOMING_VIDEO_STATUS_VIEWED);
    if (playedVideoModel.relatedUser.unviewedCount > 0)
    {
        playedVideoModel.relatedUser.unviewedCount--;
    }
    else
    {
        playedVideoModel.relatedUser.unviewedCount = 0;
    }
    self.playedFriend = playedVideoModel.relatedUser;
    [viewedVideo.managedObjectContext MR_saveToPersistentStoreAndWait];
}

- (void)stop
{
    self.isPlayingVideo = NO;
    [self.moviePlayerController.view removeFromSuperview];
    [self.delegate videoPlayerURLWasFinishedPlaying:self.moviePlayerController.contentURL
                                withPlayedUserModel:self.playedFriend];
    [self.moviePlayerController stop];
}

- (void)toggle
{
    if (self.isPlayingVideo)
    {
        [self stop];
    }
    else
    {
        [self playOnView:nil withURLs:self.currentPlayQueue];
    }
}

//- (BOOL)isPlaying
//{
//    return self.isPlayingVideo;
//}


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
    }
    else
    {
        [self _playNext];
    }
}

- (void)_playNext
{
    NSInteger index = [self.currentPlayQueue indexOfObject:self.moviePlayerController.contentURL];
    index++;
    
    NSURL* nextUrl = nil;
    
    if (index < self.currentPlayQueue.count)
    {
        nextUrl = self.currentPlayQueue[index];
    }
    else
    {
        [self.delegate videoPlayerURLWasFinishedPlaying:[self.currentPlayQueue lastObject] withPlayedUserModel:self.playedFriend];
        [self.moviePlayerController.view removeFromSuperview];
    }
    
    if (nextUrl)
    {
        ZZVideoDomainModel* playedVideoModel = self.videoModelsArray[index];
        TBMVideo* viewedVideo = [TBMVideo findWithVideoId:playedVideoModel.videoID];
        
        //save video state
        [self updateViewedVideoCounterWithVideoDomainModel:playedVideoModel];
        
//        [self.delegate videoPlayerURLWasFinishedPlaying:self.moviePlayerController.contentURL];
        
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

//#pragma mark - Change Output
//
//- (void)changeAudioOutput
//{
//    if ([self isDeviceNearEar])
//    {
//        
//    
//    }
//}

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

//
//  ZZVideoPlayer.m
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import MediaPlayer;

#import "ZZVideoPlayer.h"
#import "ZZVideoDomainModel.h"

@interface ZZVideoPlayer ()

@property (nonatomic, strong) MPMoviePlayerController* moviePlayerController;
@property (nonatomic, assign) BOOL isPlayingVideo;
@property (nonatomic, strong) UIButton* tapButton;
@property (nonatomic, strong) NSArray* currentPlayQueue;

@end

@implementation ZZVideoPlayer

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_playNext)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_playerStateWasUpdated)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)playOnView:(UIView*)view withURLs:(NSArray*)URLs
{
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
        ZZVideoDomainModel* videoModel = [URLs firstObject];
        NSURL* firstVideoUrl = videoModel.videoURL;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[firstVideoUrl path]])
        {
            NSLog(@"asdf");
        }
        else
        {
            NSLog(@"asdf");
        }
        self.moviePlayerController.contentURL = videoModel.videoURL;
        self.isPlayingVideo = YES;
        [self.moviePlayerController play];
    }
}


- (void)stop
{
    self.isPlayingVideo = NO;
    [self.moviePlayerController.view removeFromSuperview];
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

- (BOOL)isPlaying
{
    return self.isPlayingVideo;
}


#pragma mark - Private

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
        [self.moviePlayerController.view removeFromSuperview];
    }
    
    
    if (nextUrl)
    {
        [self.delegate videoPlayerURLWasFinishedPlaying:self.moviePlayerController.contentURL];
        self.moviePlayerController.contentURL = nextUrl;
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


#pragma mark - Lazy Load

- (MPMoviePlayerController *)moviePlayerController
{
    if (!_moviePlayerController)
    {
        _moviePlayerController = [MPMoviePlayerController new];
        _moviePlayerController.controlStyle = MPMovieControlStyleNone;
        _moviePlayerController.view.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
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

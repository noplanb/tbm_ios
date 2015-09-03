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
#import "ZZVideoRecorder.h"


@interface ZZVideoPlayer () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView * presentedView;
@property (nonatomic, strong) MPMoviePlayerController* moviePlayerController;

@property (nonatomic, strong) AVPlayer* avplayer;
@property (nonatomic, strong) AVPlayerLayer* avPlayerLayer;
@property (nonatomic, strong) UITapGestureRecognizer *recognizer;
@property (nonatomic, assign) BOOL isPlayVideo;
@property (nonatomic, strong) UIButton* tapButton;

@end

@implementation ZZVideoPlayer

- (instancetype)initWithVideoPlayerView:(UIView *)presentedView
{
    if (self == [super init])
    {
        self.presentedView = presentedView;
        self.tapButton = [UIButton new];
    }
    
    return self;
}

- (void)setupMoviePlayerWithContentUrl:(NSURL *)contentUrl
{
    self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:contentUrl];
    self.moviePlayerController.controlStyle = MPMovieControlStyleNone;
    [[self.moviePlayerController view] setFrame:self.presentedView.bounds];
    self.moviePlayerController.view.backgroundColor = [UIColor clearColor];
    
    [self.moviePlayerController.view addSubview:self.tapButton];
    
    [self.tapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.moviePlayerController.view);
    }];
    [self.tapButton addTarget:self action:@selector(stopVideo) forControlEvents:UIControlEventTouchUpInside];
}

- (void)playVideo
{
    self.isPlayVideo = YES;
    [self.presentedView addSubview:self.moviePlayerController.view];
    [self.presentedView bringSubviewToFront:self.moviePlayerController.view];
    [self.moviePlayerController play];
}

- (void)stopVideo
{
    self.isPlayVideo = NO;
    [self.moviePlayerController.view removeFromSuperview];
    [self.moviePlayerController stop];
    
}

- (BOOL)isPlaying
{
    return self.isPlayVideo;
}

@end

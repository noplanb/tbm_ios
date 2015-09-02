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


@interface ZZVideoPlayer ()

@property (nonatomic, weak) UIView <ZZVideoPlayerDelegate>* presentedView;
@property (nonatomic, strong) MPMoviePlayerController* moviePlayerController;

@property (nonatomic, strong) AVPlayer* avplayer;
@property (nonatomic, strong) AVPlayerLayer* avPlayerLayer;

@end

@implementation ZZVideoPlayer

- (instancetype)initWithVideoPalyerView:(UIView <ZZVideoPlayerDelegate> *)presentedView
{
    if (self == [super init])
    {
        self.presentedView = presentedView;
        [self configureMoviePlayer];
    }
    
    return self;
}

- (void)configureMoviePlayer
{
//    self.moviePlayerController = [[MPMoviePlayerController alloc] init];
//    self.moviePlayerController.controlStyle = MPMovieControlStyleNone;
//    [self.presentedView addSubview:self.moviePlayerController.view];
//    [self.moviePlayerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.presentedView);
//    }];
//    
//    
//    [self.presentedView bringSubviewToFront:self.moviePlayerController.view];
//    self.moviePlayerController.view.hidden = YES;
}


- (void)setupMoviePlayerWithContentUrl:(NSURL *)contentUrl
{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample_iTunes" ofType:@"mov"];
    NSURL *url = [NSURL fileURLWithPath:path];

    BOOL exist =  [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    
//    self.avplayer = [[AVPlayer alloc] ini];
//    self.avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avplayer];
//    [self.avPlayerLayer setFrame:self.presentedView.frame];
//  
//    [self.presentedView.layer addSublayer:self.avPlayerLayer];
//
//    
//    [self.avplayer seekToTime:kCMTimeZero];
//    self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    [self.avplayer play];
//    
    
    self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:contentUrl];
    self.moviePlayerController.controlStyle = MPMovieControlStyleNone;
    [[self.moviePlayerController view] setFrame:self.presentedView.bounds];
    
    [self.presentedView addSubview:self.moviePlayerController.view];
    [self.presentedView bringSubviewToFront:self.moviePlayerController.view];
    [self.moviePlayerController prepareToPlay];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.moviePlayerController play];
    });
    
}

- (void)playVideo
{
    [self.moviePlayerController play];
}

- (void)stopVideo
{
    [self.moviePlayerController stop];
}

@end

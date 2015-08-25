//
//  ZZVideoPlayer.m
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import MediaPlayer;

#import "ZZVideoPlayer.h"

@interface ZZVideoPlayer ()

@property (nonatomic, weak) UIView <ZZVideoPlayerDelegate>* presentedView;
@property (nonatomic, strong) MPMoviePlayerController* moviePlayerController;

@end

@implementation ZZVideoPlayer

- (instancetype)initWithVideoPalyerView:(UIView <ZZVideoPlayerDelegate> *)presentedView
{
    if (self == [super init])
    {
        self.presentedView = presentedView;
//        [self configureMoviePlayer];
    }
    
    return self;
}

- (void)configureMoviePlayer
{
    self.moviePlayerController = [[MPMoviePlayerController alloc] init];
    self.moviePlayerController.controlStyle = MPMovieControlStyleNone;
    [self.presentedView addSubview:self.moviePlayerController.view];
    
    [self.moviePlayerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.presentedView);
    }];
}

- (void)playVideoWithContentUrl:(NSURL *)contentUrl
{
    self.moviePlayerController.view.hidden = NO;
    [self.moviePlayerController play];
}

@end

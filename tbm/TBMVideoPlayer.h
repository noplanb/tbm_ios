//
//  TBMVideoPlayer.h
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaPlayer/MediaPlayer.h"
#import "TBMSoundEffect.h"
#import "TBMVideo.h"
#import "TBMFriend.h"
#import "TBMGridElement.h"

@interface TBMVideoPlayer : NSObject <TBMVideoStatusNotificationProtocol>

@property (nonatomic, strong) TBMGridElement *gridElement;
@property (nonatomic, strong) TBMVideo *video;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;
@property (nonatomic, strong) UIView *gridView;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIImageView *thumbView;
@property (nonatomic, strong) CALayer *viewedIndicatorLayer;
@property (nonatomic, strong) TBMSoundEffect *messageTone;

// Create
- (instancetype)initWithGridElement:(TBMGridElement *)gridElement view:(UIView *)view;

// Instance methods
- (void)togglePlay;
- (BOOL)isPlaying;
- (void)updateView;
- (void)printSelf;
@end

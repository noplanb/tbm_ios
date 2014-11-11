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

@property (nonatomic, weak) TBMGridElement *gridElement;
@property (nonatomic) TBMVideo *video;
@property (nonatomic) MPMoviePlayerController *moviePlayerController;
@property (nonatomic) UIView *gridView;
@property (nonatomic) UIView *playerView;
@property (nonatomic) UIImageView *thumbView;
@property (nonatomic) CALayer *viewedIndicatorLayer;
@property (nonatomic) TBMSoundEffect *messageTone;

// Create
+ (instancetype)createWithGridElement:(TBMGridElement *)gridElement;

// Instance methods
- (void)togglePlay;
- (BOOL)isPlaying;
- (void)updateView;

@end

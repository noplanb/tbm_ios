//
//  TBMAudioSessionRouter.h
//  Zazo
//
//  Created by Kirill Kirikov on 02.04.15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TBMVideoPlayer.h"

typedef enum : NSUInteger {
    Idle,
    Playing,
    Recording
} AudioSessionState;

@interface TBMAudioSessionRouter : NSObject <TBMVideoPlayerEventNotification>
@property (nonatomic) AVAudioSession *session;
@property (nonatomic) AudioSessionState state;
+ (TBMAudioSessionRouter * ) sharedInstance;
@end

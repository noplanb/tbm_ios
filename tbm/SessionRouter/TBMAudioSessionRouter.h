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


@interface TBMAudioSessionRouter : NSObject
@property (nonatomic) AVAudioSession *session;
+ (void) setup;
@end

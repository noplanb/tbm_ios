//
//  ZZSoundPlayer.h
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@import AVFoundation;

#import <Foundation/Foundation.h>

@interface ZZSoundPlayer : NSObject

@property (nonatomic, strong) AVAudioPlayer *player;

- (id)initWithSoundNamed:(NSString *)filename;
- (void)play;

@end

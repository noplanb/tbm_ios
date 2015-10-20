//
//  TBMSoundEffect.m
//  tbm
//
//  Created by Sani Elfishawy on 5/15/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "ZZSoundEffectPlayer.h"

@interface ZZSoundEffectPlayer ()

@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation ZZSoundEffectPlayer

- (instancetype)initWithSoundNamed:(NSString *)filename
{
    self = [super init];
    if (self)
    {
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if (url)
        {
            NSError *error;
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        }
    }
    return self;
}

- (void)play
{
    [self.player play];
}

@end

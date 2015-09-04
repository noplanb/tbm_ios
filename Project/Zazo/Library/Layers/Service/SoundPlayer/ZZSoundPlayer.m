//
//  ZZSoundPlayer.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSoundPlayer.h"


@implementation ZZSoundPlayer

- (id)initWithSoundNamed:(NSString *)filename
{
    if ((self = [super init]))
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

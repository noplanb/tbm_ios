//
//  TBMSoundEffect.m
//  tbm
//
//  Created by Sani Elfishawy on 5/15/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMSoundEffect.h"

// Note I had to change from using system sounds because they are silence during a recording session
// and our app has a recording session running fulltime.
@implementation TBMSoundEffect
- (id)initWithSoundNamed:(NSString *)filename{
    if ((self = [super init])){
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if (url){
            NSError *error;
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        }
    }
    return self;
}


- (void)play
{
    [_player play];
}

@end

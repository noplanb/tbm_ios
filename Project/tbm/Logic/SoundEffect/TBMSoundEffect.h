//
//  TBMSoundEffect.h
//  tbm
//
//  Created by Sani Elfishawy on 5/15/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"

@interface TBMSoundEffect : NSObject
@property AVAudioPlayer *player;

- (id)initWithSoundNamed:(NSString *)filename;
- (void)play;
@end

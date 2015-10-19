//
//  TBMSoundEffect.h
//  tbm
//
//  Created by Sani Elfishawy on 5/15/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

@import AVFoundation;

@interface ZZSoundEffectPlayer : NSObject

- (instancetype)initWithSoundNamed:(NSString*)filename;
- (void)play;

@end

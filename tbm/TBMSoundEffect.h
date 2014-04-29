//
//  TBMSoundEffect.h
//  tbm
//
//  Created by Sani Elfishawy on 4/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>

@interface TBMSoundEffect : NSObject
@property SystemSoundID soundId;
- (id)initWithSoundNamed:(NSString *)filename;
- (void)play;
@end
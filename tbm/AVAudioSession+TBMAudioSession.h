//
//  AVAudioSession+TBMAudioSession.h
//  Zazo
//
//  Created by Sani Elfishawy on 5/10/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@protocol TBMAudioSessionDelegate <NSObject>
- (void)willDeactivateAudioSession;
@end

@interface AVAudioSession (TBMAudioSession)

-(void)setupApplicationAudioSession;
-(void)addTBMAudioSessionDelegate:(id <TBMAudioSessionDelegate>)delegate;

@end


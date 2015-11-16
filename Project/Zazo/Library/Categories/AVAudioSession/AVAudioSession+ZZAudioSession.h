//
//  AVAudioSession+ZZAudioSession.h
//  Zazo
//
//  Created by Sani Elfishawy on 5/10/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@import AVFoundation;

@protocol ZZAudioSessionDelegate <NSObject>

- (void)willDeactivateAudioSession;

@end

@interface AVAudioSession (ZZAudioSession)

- (void)setupApplicationAudioSession;
- (NSError*)activate;
- (void)addZZAudioSessionDelegate:(id <ZZAudioSessionDelegate>)delegate;

@end


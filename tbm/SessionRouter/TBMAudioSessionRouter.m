//
//  TBMAudioSessionRouter.m
//  Zazo
//
//  Created by Kirill Kirikov on 02.04.15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAudioSessionRouter.h"
#import "TBMVideoRecorder.h"
#import <UIKit/UIKit.h>

@interface TBMAudioSessionRouter()
@property (nonatomic, assign) BOOL hfpFound;
@end

@implementation TBMAudioSessionRouter

#pragma mark - Singleton

+ (TBMAudioSessionRouter * ) sharedInstance {
    
    static dispatch_once_t pred;
    static TBMAudioSessionRouter *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[TBMAudioSessionRouter alloc] init];
    });
    
    return shared;
}

#pragma mark - Initialization methods

- (instancetype) init {
    self = [super init];
    if (self) {
        [self subscribeToNotifications];
        [self initAudioSessionRouting];
        [self findAvailbleBluetoothDevices];
    }
    
    return self;
}

- (void)initAudioSessionRouting
{
    self.session = [AVAudioSession sharedInstance];
    [self updateAudioSessionParams];
}

- (void) subscribeToNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveProximityChangedNotification:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAudioSessionRoutChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAudioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTBMVideoRecorderDidFinishRecordingNotification:) name:TBMVideoRecorderDidFinishRecording object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTBMVideoRecorderShouldStartRecordingNotification:) name:TBMVideoRecorderShouldStartRecording object:nil];
}

#pragma mark - Notifications handling

- (void) didReceiveTBMVideoRecorderDidFinishRecordingNotification:(NSNotification *)notification {
    [self setState:Idle];
}

- (void) didReceiveTBMVideoRecorderShouldStartRecordingNotification:(NSNotification *)notification {
    [self setState:Recording];
}

- (void) didReceiveAVAudioSessionSilenceSecondaryAudioHintNotification:(NSNotification *)notification {
    [self interrupt];
}

- (void) didReceiveAudioSessionInterruptionNotification:(NSNotification *)notification {
    [self interrupt];
}

- (void) didReceiveAudioSessionRoutChangeNotification:(NSNotification *)notification {

    AVAudioSessionRouteChangeReason reason = [[notification.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] intValue];
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
        default:
            break;
    }
}

- (void) didReceiveProximityChangedNotification:(NSNotification *)notification {
    if (self.state == Idle) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    } else {
        [self updateAudioSessionParams];
    }
}

#pragma mark - Audio managing

- (void) interrupt {
    [self setState:Idle];
}

- (void) setState:(AudioSessionState)state {
    if (_state != state) {
        _state = state;
        [self updateAudioSessionParams];
    }
}

#pragma mark - Update Audio Session params

- (void) updateAudioSessionParams {
    
    switch (self.state) {
        case Playing:
            [self switchToPlayingState];
            break;
        case Recording:
            [self switchToRecordingState];
            break;
        default:
        case Idle:
            [self switchToIdleState];
            break;
    }
}


#warning - we should find a better way
- (void) findAvailbleBluetoothDevices {
    
    [self.session setMode:AVAudioSessionModeVoiceChat error:nil];
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [self.session setActive:YES error:nil];

    self.hfpFound = NO;
    NSArray *inputs = [self.session.currentRoute inputs];
    for (AVAudioSessionPortDescription *input in inputs) {
        if ([input.portType isEqualToString:AVAudioSessionPortBluetoothHFP]) {
            //we have HFP connected, we should use VoiceChat.
            self.hfpFound = YES;
        }
    }
    
    [self.session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

/**
 * We enable proximity monitoring here
 * We use proximity to understand what
 * category should we use: Voice chat for earpiece 
 * and Video chat for loud speaker
 */
- (void) switchToPlayingState {
    if (self.hfpFound) {
        [self.session setMode:AVAudioSessionModeVoiceChat error:nil];
        [self.session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    } else if ([UIDevice currentDevice].proximityState) {
        [self.session setMode:AVAudioSessionModeVoiceChat error:nil];
        [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [self.session setMode:AVAudioSessionModeVideoChat error:nil];
        [self.session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
}

- (void) switchToRecordingState {
    [self.session setActive:NO error:nil];
    [self.session setMode:AVAudioSessionModeVideoChat error:nil];
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [self.session setActive:YES error:nil];
}

- (void) switchToIdleState {
    [self.session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [self.session setMode:AVAudioSessionModeDefault error:nil];
    [self.session setCategory:AVAudioSessionCategoryAmbient error:nil];
}

#pragma mark - TBMVideoPlayerEventNotification

- (void)videoPlayerStartedIndex:(NSInteger)index {
    [self setState:Playing];
}

- (void)videoPlayerStopped {
    [self setState:Idle];
}

@end

//
//  TBMAudioSessionRouter.m
//  Zazo
//
//  Created by Kirill Kirikov on 02.04.15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAudioSessionRouter.h"
#import <UIKit/UIKit.h>

NSString * const TBMAudioSessionRouterInterruptionNotification = @"AudioSessionRouterInterruption";

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAVAudioSessionSilenceSecondaryAudioHintNotification:) name:AVAudioSessionSilenceSecondaryAudioHintNotification object:nil];
    
}

#pragma mark - Notifications handling

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
    [self updateAudioSessionParams];
}

#pragma mark - Audio managing

- (void) interrupt {
    if (self.state != Idle) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TBMAudioSessionRouterInterruptionNotification object:self];
        [self setState:Idle];
    }
}

- (void) setState:(AudioSessionState)state {
    if (_state != state) {
        _state = state;
        [self updateAudioSessionParams];
    }
}

- (void) updateAudioSessionParams {
    

    switch (self.state) {
        case Playing:
            
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
            
            [self.session setActive:NO error:nil];
            if ([UIDevice currentDevice].proximityState) {
                [self.session setMode:AVAudioSessionModeVoiceChat error:nil];
                [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            } else {
                [self.session setMode:AVAudioSessionModeVideoChat error:nil];
                [self.session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
            }
            [self.session setActive:YES error:nil];
            break;
        case Recording:
            [self.session setActive:NO error:nil];
            [self.session setMode:AVAudioSessionModeVideoChat error:nil];
            [self.session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
            [self.session setActive:YES error:nil];
            break;
        default:
        case Idle:
            
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            
            [self.session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
            [self.session setMode:AVAudioSessionModeDefault error:nil];
            [self.session setCategory:AVAudioSessionCategoryAmbient error:nil];
            
            break;
    }
}

@end

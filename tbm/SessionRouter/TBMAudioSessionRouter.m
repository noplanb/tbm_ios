//
//  TBMAudioSessionRouter.m
//  Zazo
//
//  Created by Kirill Kirikov on 02.04.15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAudioSessionRouter.h"
#import "TBMVideoRecorder.h"
#import <OBLogger/OBLogger.h>
#import <UIKit/UIKit.h>


@interface TBMAudioSessionRouter()
@property (nonatomic, assign) BOOL isPlaying;
@end

@implementation TBMAudioSessionRouter

#pragma mark - Singleton

+ (void) setup {
    static dispatch_once_t pred;
    static TBMAudioSessionRouter *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[TBMAudioSessionRouter alloc] init];
    });
}

#pragma mark - Initialization methods

- (instancetype) init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup {
    [self subscribeToNotifications];
    [self initAudioSessionRouting];
}


/**
 * Setup the default mode and category for audio session,
 * this params will be used when audio session will be activated
 */
- (void)initAudioSessionRouting
{
    self.session = [AVAudioSession sharedInstance];
    [self.session setMode:AVAudioSessionModeVoiceChat error:nil];
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [self sendAudioToSpeakerPort];
}

- (void) subscribeToNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveProximityChangedNotification:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAudioSessionRoutChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAudioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTBMVideoRecorderDidFinishRecordingNotification:) name:TBMVideoRecorderDidFinishRecording object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTBMVideoRecorderShouldStartRecordingNotification:) name:TBMVideoRecorderShouldStartRecording object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTBMVideoPlayerDidStartPlayingNotification:) name:TBMVideoPlayerDidStartPlaying object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTBMVideoPlayerDidFinishPlayingNotification:) name:TBMVideoPlayerDidFinishPlaying object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUIApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUIApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];

}

#pragma mark - Notifications handling

- (void) didReceiveUIApplicationDidBecomeActiveNotification:(NSNotification *)notification {
#ifdef ALWAYS_KEEP_ACTIVE_AUDIO_SESSION
    [self.session setActive:YES error:nil];
#endif
}

- (void) didReceiveUIApplicationDidEnterBackgroundNotification:(NSNotification *)notification {
#ifdef ALWAYS_KEEP_ACTIVE_AUDIO_SESSION
    [self.session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
#endif
}

/**
 * Video player starts playing video
 */
- (void) didReceiveTBMVideoPlayerDidStartPlayingNotification:(NSNotification *)notification {
    
    if (self.isPlaying) {
        return;
    }
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [self activateAudioSession];
    [self setIsPlaying:YES];
    
    //We don't know about HFP device connected before we set override port to None
    [self sendAudioToDefaultPort];
    if (![self isHeadsetAvailableInRoute:self.session.currentRoute]) {
        [self sendAudioToSpeakerPort];
    }
}

/**
 * Video player finished playing video
 */
- (void) didReceiveTBMVideoPlayerDidFinishPlayingNotification:(NSNotification *)notification {

    if (!self.isPlaying) {
        return;
    }
    
//  We should disable proximity sensor only when user will remove phone from his ear
//  because only in this case we will receive notification about proximity changing next time
    
    if (![UIDevice currentDevice].proximityState) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
    
    [self sendAudioToSpeakerPort];
    [self deactivateAudioSession];
    [self setIsPlaying:NO];
}

/**
 * Video recorder finished recording video
 */
- (void) didReceiveTBMVideoRecorderDidFinishRecordingNotification:(NSNotification *)notification {
    [self deactivateAudioSession];
}

/**
 * Video recorder starts recording video
 */
- (void) didReceiveTBMVideoRecorderShouldStartRecordingNotification:(NSNotification *)notification {
    [self activateAudioSession];
}

/**
 * Here we can handle a situation when our app is in background and 
 * another app starts playing music
 */
- (void) didReceiveAVAudioSessionSilenceSecondaryAudioHintNotification:(NSNotification *)notification {
}

/**
 * Here we can react on interruptions
 * e.g. we can handle situation when user receives a phone call
 */
- (void) didReceiveAudioSessionInterruptionNotification:(NSNotification *)notification {
}

/**
 * We watch for the audio session route updates and change output port if needed
 * e.g: when user connects wired headset
 */
- (void) didReceiveAudioSessionRoutChangeNotification:(NSNotification *)notification {

    AVAudioSessionRouteChangeReason reason = [[notification.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] intValue];
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            [self handleRouteChangeReasonNewDeviceAvailable:[notification.userInfo objectForKey:AVAudioSessionRouteChangePreviousRouteKey]];
            break;
        case AVAudioSessionRouteChangeReasonOverride:
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            [self handleRouteChangeReasonOldDeviceUnavailable:[notification.userInfo objectForKey:AVAudioSessionRouteChangePreviousRouteKey]];
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
        default:
            break;
    }
}

/** 
 * if old route has connected headset and new route hasn't then
 * -> if has proximity, do nothing
 * -> else we should send audio to speaker
 */
- (void) handleRouteChangeReasonOldDeviceUnavailable:(AVAudioSessionRouteDescription *)prevRoute
{
    if ([self isHeadsetAvailableInRoute:prevRoute] && ![self isHeadsetAvailableInRoute:self.session.currentRoute] && ![UIDevice currentDevice].proximityState) {
        [self sendAudioToSpeakerPort];
    }
}

/**
 * Here we do a check: if we connect a headset then we should use it
 */
- (void) handleRouteChangeReasonNewDeviceAvailable:(AVAudioSessionRouteDescription *)prevRoute
{
    if (![self isHeadsetAvailableInRoute:prevRoute] && [self isHeadsetAvailableInRoute:self.session.currentRoute]) {
        [self sendAudioToDefaultPort];
    }
}

/**
 * We check if user has his phone near the ear we send audio to default port (earpiece)
 * else we use speaker.
 * if sound isn't playing we should disable proximity sensor
 */
- (void) didReceiveProximityChangedNotification:(NSNotification *)notification {
    
    if ([UIDevice currentDevice].proximityState) {
        [self sendAudioToDefaultPort];
    } else if (![self isHeadsetAvailableInRoute:self.session.currentRoute]){
        [self sendAudioToSpeakerPort];
    }
    
    if (!self.isPlaying) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
}

/**
 * Override audio session output to speaker,
 * so if we have connected bluetooth speaker it will be used for playing audio
 * else audio will be playing through built in speaker.
 */
- (void) sendAudioToSpeakerPort {
    NSError *error = nil;
    [self.session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if (error) {
        OB_WARN(@"Cannot override port to Speaker: %@", error);
    }
}

/**
 * Override audio session output port to default value,
 * so if we have connected wired or bluetooth headset it will be used for playing audio
 * else audio will be playing through built in earpiece.
 */
- (void) sendAudioToDefaultPort {
    NSError *error = nil;
    [self.session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    if (error) {
        OB_WARN(@"Cannot override port to None: %@", error);
    }
}

#pragma mark - Utils

/**
 * Use this method to determine that
 * we have connected wired headset or bluetooth headset
 * in given audio session route
 */
- (BOOL) isHeadsetAvailableInRoute:(AVAudioSessionRouteDescription *)route {
    NSArray *outputs = [route outputs];
    for (AVAudioSessionPortDescription *output in outputs) {
        if ([output.portType isEqualToString:AVAudioSessionPortBluetoothHFP] ||
            [output.portType isEqualToString:AVAudioSessionPortHeadphones]
            )
        {
            return YES;
        }
    }
    return NO;
}

/**
 * Enable audio session
 * Just helper method that handle error
 */
- (void) activateAudioSession {
    
#ifndef ALWAYS_KEEP_ACTIVE_AUDIO_SESSION
    NSError *error = nil;
    [self.session setActive:YES error:&error];
    if (error) {
        OB_WARN(@"Cannot activate audio session, error: %@", error);
    }
#endif
}

/**
 * Disable audio session
 * Just helper method that handle error
 */
- (void) deactivateAudioSession {
#ifndef ALWAYS_KEEP_ACTIVE_AUDIO_SESSION
    NSError *error = nil;
    [self.session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        OB_WARN(@"Cannot deactivate audio session, error: %@", error);
    }
#endif
}

#pragma mark -

@end

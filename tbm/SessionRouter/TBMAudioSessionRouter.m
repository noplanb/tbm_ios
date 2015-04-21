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
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
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
    self.sessionQueue = dispatch_queue_create("audiosessionrouterqueue", DISPATCH_QUEUE_SERIAL);
    self.session = [AVAudioSession sharedInstance];
    [self setDefaultMode];
}

/**
 Use when we playing or idle
 */
- (void) setDefaultMode {
    [self.session setActive:YES error:nil];
    [self.session setMode:AVAudioSessionModeMoviePlayback error:nil];
    [self.session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
}

/**
 Use when phone is near the ear
 */
- (void) setEarMode {
    [self.session setMode:AVAudioSessionModeVoiceChat error:nil];
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [self.session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
}

/**
 Use when we doing recording
 */
- (void) setRecordingMode {
    dispatch_async(self.sessionQueue, ^{
        [self.session setMode:AVAudioSessionModeVoiceChat error:nil];
        [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [self.session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    });
}

/**
 Use when we have the application in background
 */
- (void) setDisableMode {
    [self.session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
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
    [self.session setActive:YES error:nil];
}

- (void) didReceiveUIApplicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [self.session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

/**
 * Video player starts playing video
 */
- (void) didReceiveTBMVideoPlayerDidStartPlayingNotification:(NSNotification *)notification {
    
    if (self.isPlaying) {
        return;
    }
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [self setDefaultMode];
    [self setIsPlaying:YES];
}

/**
 * Video player finished playing video
 */
- (void) didReceiveTBMVideoPlayerDidFinishPlayingNotification:(NSNotification *)notification {

    if (!self.isPlaying) {
        return;
    }
    
    if (![UIDevice currentDevice].proximityState) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
    [self setIsPlaying:NO];
}

/**
 * Video recorder finished recording video
 */
- (void) didReceiveTBMVideoRecorderDidFinishRecordingNotification:(NSNotification *)notification {
    [self setDefaultMode];
}

/**
 * Video recorder starts recording video
 */
- (void) didReceiveTBMVideoRecorderShouldStartRecordingNotification:(NSNotification *)notification {
    [self setRecordingMode];
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
}

/**
 * Here we do a check: if we connect a headset then we should use it
 */
- (void) handleRouteChangeReasonNewDeviceAvailable:(AVAudioSessionRouteDescription *)prevRoute
{

}

/**
 * We check if user has his phone near the ear we send audio to default port (earpiece)
 * else we use speaker.
 * if sound isn't playing we should disable proximity sensor
 */
- (void) didReceiveProximityChangedNotification:(NSNotification *)notification {
    
    if ([UIDevice currentDevice].proximityState) {
        [self setEarMode];
    } else {
        [self setDefaultMode];
    }
    
    if (!self.isPlaying) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
}

#pragma mark - Utils

/**
 * Use this method to determine that
 * we have connected wired headset or bluetooth headset
 * in given audio session route
 */
- (BOOL) isBTAvailableInRoute:(AVAudioSessionRouteDescription *)route {
    NSArray *outputs = [route outputs];
    for (AVAudioSessionPortDescription *output in outputs) {
        if ([output.portType isEqualToString:AVAudioSessionPortBluetoothA2DP])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark -

@end

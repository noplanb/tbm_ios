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

- (void)initAudioSessionRouting
{
    self.session = [AVAudioSession sharedInstance];
    [self.session setMode:AVAudioSessionModeVoiceChat error:nil];
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [self overridePortToSpeaker];
}

- (void) subscribeToNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveProximityChangedNotification:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAudioSessionRoutChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAudioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTBMVideoRecorderDidFinishRecordingNotification:) name:TBMVideoRecorderDidFinishRecording object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTBMVideoRecorderShouldStartRecordingNotification:) name:TBMVideoRecorderShouldStartRecording object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTBMVideoPlayerDidStartPlayingNotification:) name:TBMVideoPlayerDidStartPlaying object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTBMVideoPlayerDidFinishPlayingNotification:) name:TBMVideoPlayerDidFinishPlaying object:nil];
}

#pragma mark - Notifications handling

- (void) didReceiveTBMVideoPlayerDidStartPlayingNotification:(NSNotification *)notification {
    
    if (self.isPlaying) {
        return;
    }
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    [self.session setActive:YES error:nil];
    self.isPlaying = YES;
    
    //We don't know about HFP device connected before we set override port to None
    [self overridePortNone];
    if (![self isHFPDeviceAvailableInRoute:self.session.currentRoute]) {
        [self overridePortToSpeaker];
    }
}

- (void) didReceiveTBMVideoPlayerDidFinishPlayingNotification:(NSNotification *)notification {

    if (!self.isPlaying) {
        return;
    }
    
    /**
     * We should disable proximity sensor only when user will remove phone from his ear
     * because only in this case we will receive notification about proximity changing next time
     */
    if (![UIDevice currentDevice].proximityState) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
    
    [self overridePortToSpeaker];
    [self.session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    self.isPlaying = NO;
}

- (void) didReceiveTBMVideoRecorderDidFinishRecordingNotification:(NSNotification *)notification {
    [self.session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void) didReceiveTBMVideoRecorderShouldStartRecordingNotification:(NSNotification *)notification {
    [self.session setActive:YES error:nil];
}

- (void) didReceiveAVAudioSessionSilenceSecondaryAudioHintNotification:(NSNotification *)notification {
}

- (void) didReceiveAudioSessionInterruptionNotification:(NSNotification *)notification {
}

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
 * if old route has HFP and new route hasn't then
 * -> if has proximity, do nothing
 * -> else we should override audio port to speaker
 */
- (void) handleRouteChangeReasonOldDeviceUnavailable:(AVAudioSessionRouteDescription *)prevRoute
{
    if ([self isHFPDeviceAvailableInRoute:prevRoute] && ![self isHFPDeviceAvailableInRoute:self.session.currentRoute] && ![UIDevice currentDevice].proximityState) {
        [self overridePortToSpeaker];
    }
}

- (void) handleRouteChangeReasonNewDeviceAvailable:(AVAudioSessionRouteDescription *)prevRoute
{
    if (![self isHFPDeviceAvailableInRoute:prevRoute] && [self isHFPDeviceAvailableInRoute:self.session.currentRoute]) {
        [self overridePortNone];
    }
}

- (void) didReceiveProximityChangedNotification:(NSNotification *)notification {
    
    if ([UIDevice currentDevice].proximityState) {
        [self overridePortNone];
    } else if (![self isHFPDeviceAvailableInRoute:self.session.currentRoute]){
        [self overridePortToSpeaker];
    }
    
    if (!self.isPlaying) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
}

- (void) overridePortToSpeaker {
    NSError *error = nil;
    [self.session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if (error) {
        OB_WARN(@"Cannot override port to Speaker: %@", error);
    }
}

- (void) overridePortNone {
    NSError *error = nil;
    [self.session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    if (error) {
        OB_WARN(@"Cannot override port to None: %@", error);
    }
}

#pragma mark - Utils

- (BOOL) isHFPDeviceAvailableInRoute:(AVAudioSessionRouteDescription *)route {
    NSArray *outputs = [route outputs];
    for (AVAudioSessionPortDescription *output in outputs) {
        if ([output.portType isEqualToString:AVAudioSessionPortBluetoothHFP]) {
            return YES;
        }
    }
    return NO;
}


#pragma mark -

@end

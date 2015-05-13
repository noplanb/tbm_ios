//
//  AVAudioSession+TBMAudioSession.m
//  Zazo
//
//  Created by Sani Elfishawy on 5/10/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "AVAudioSession+TBMAudioSession.h"
#import "OBLogger.h"
@import UIKit;

static NSMutableSet *TBMDelegates;

@implementation AVAudioSession (TBMAudioSession)

#pragma mark Interface methods

-(void)setupApplicationAudioSession {
    OB_INFO(@"TBMAudioSession: setupApplicationAudioSession");
    [self setApplicationCategory];
    [self addObservers];
}

-(void)addTBMAudioSessionDelegate:(id <TBMAudioSessionDelegate>)delegate{
    if (TBMDelegates == nil) TBMDelegates = [[NSMutableSet alloc] init];
    [TBMDelegates addObject: delegate];
}


#pragma mark Audio Session Control

-(void)resetAudioSession {
    OB_INFO(@"TBMAudioSession: resetAudioSession");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeRouteChangeObserver];
        [self setApplicationCategory];
        [self setPortOverride];
        [self addRouteChangeObserver];
    });
}

- (void)setApplicationCategory{
    OB_DEBUG(@"TBMAudioSession: setApplicationCategory");
    NSError *error = nil;
    [self setCategory:AVAudioSessionCategoryPlayAndRecord
//   Eliminate play from bluetooth see v2.2.1 release notes
//          withOptions:AVAudioSessionCategoryOptionAllowBluetooth
            withOptions:0
                error:&error];
    if (error != nil) OB_ERROR(@"TBMAudioSession#setApplicationCategory: Error setting category: %@", error);
}

-(void)activate{
    OB_INFO(@"TBMAudioSession#activate:");
    NSError *error = nil;
    [self setApplicationCategory];
    [self setPortOverride];
    [self setActive:YES error:&error];
    if (error !=nil) OB_ERROR(@"TBMAudioSession#activate: %@", error);
    [self addRouteChangeObserver];
}

-(void)deactivate {
    OB_INFO(@"TBMAudioSession#deactivate:");
    [self notifyDelegatesOfDeactivation];
    [self removeRouteChangeObserver];
    NSError *error = nil;
    [self setActive:NO
        withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
              error:&error];
    if (error != nil) OB_ERROR(@"TBMAudioSession#deactivate: %@", error);
}

-(void)notifyDelegatesOfDeactivation{
    for (id <TBMAudioSessionDelegate> delegate in TBMDelegates){
        if ([delegate respondsToSelector:@selector(willDeactivateAudioSession)]) [delegate willDeactivateAudioSession];
    }
}

- (void)setPortOverride {
    if ([self hasNoExternalOutputs]) {
        OB_INFO(@"TBMAudioSession: setPortOverride: no external outputs");
        NSError *error = nil;
        if ([self nearTheEar]){
            OB_INFO(@"TBMAudioSession: near the ear");
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone
                                                               error: &error];
        } else {
            OB_INFO(@"TBMAudioSession: far from the ear");
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                                               error: &error];
        }
        if (error!=nil) OB_ERROR(@"TBMAudioSession#setPortOverride: %@", error);
    } else {
        OB_INFO(@"TBMAudioSession: setPortOverride: Yes external outputs");
    }
}


#pragma mark Observers

-(void)addObservers {
    UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = YES;
    
    [self addRouteChangeObserver];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProximityChange:)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioSessionInteruption)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)removeRouteChangeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

-(void)addRouteChangeObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
}

#pragma mark Event Handlers

-(void)handleRouteChange:(NSNotification *)notification{
    OB_INFO(@"TBMAudioSession: handleRouteChange: %@", notification.userInfo[AVAudioSessionRouteChangeReasonKey]);
    AVAudioSessionRouteDescription *previousRoute = (AVAudioSessionRouteDescription *) notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
    
    [self printOutputsWithPrefix:@"previousRoute:" Route:previousRoute];
    [self printOutputsWithPrefix:@"currentRoute:" Route:[self currentRoute]];
    
    // GARF: This is a hack. For some reason when changing route from bluetooth back to the built in spearker for
    // example when bluetooth is turned off it will play through earpiece and ignore the override unless I set the category
    // again. resetAudioSession does this.
    if (![self isOutputBuiltInWithRoute:previousRoute] &&
        [self isOutputBuiltInWithRoute:[self currentRoute]]) [self resetAudioSession];
}

-(void)handleProximityChange:(NSNotification *)notification{
    OB_INFO(@"TBMAudioSession: handleProximityChange");
    [self setPortOverride];
}

-(void)appDidBecomeActive{
    [self activate];
}

-(void)appWillResignActive{
    [self deactivate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
    });
}

-(void)handleAudioSessionInteruption{
    OB_INFO(@"TBMAudioSession: AudioSessionInteruption");
}


#pragma mark Route characteristics methods

- (BOOL)isOutputBuiltInWithRoute: (AVAudioSessionRouteDescription *)route{
    BOOL r = NO;
    for ( AVAudioSessionPortDescription *port in route.outputs ) {
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker] ||
            [port.portType isEqualToString:AVAudioSessionPortBuiltInReceiver]){
            r = YES;
        }
    }
    return r;
}

- (void)printOutputsWithPrefix:(NSString *)prefix Route: (AVAudioSessionRouteDescription *)route{
    for ( AVAudioSessionPortDescription *port in route.outputs ) {
        OB_INFO(@"TBMAudioSession: %@ portType: %@", prefix, port.portType);
    }
}

-(BOOL)hasExternalOutputs {
    return [self currentRouteHasBluetoothOutput] || [self currentRouteHasHeadphonesOutput];
}

- (BOOL)hasNoExternalOutputs {
    return ![self hasExternalOutputs];
}


-(BOOL)currentRouteHasBluetoothOutput {
    BOOL hasBluetoothOutput = NO;
    for (AVAudioSessionPortDescription *port in self.currentRoute.outputs) {
        if ([port.portType isEqualToString:AVAudioSessionPortBluetoothHFP] ||
            [port.portType isEqualToString:AVAudioSessionPortBluetoothA2DP])
        {
            hasBluetoothOutput = YES;
        }
    }
    return hasBluetoothOutput;
}

-(BOOL)currentRouteHasHeadphonesOutput {
    BOOL hasHeadphonesOutput = NO;
    for (AVAudioSessionPortDescription *port in self.currentRoute.outputs) {
        if ([port.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            hasHeadphonesOutput = YES;
        }
    }
    return hasHeadphonesOutput;
}



#pragma mark Proximity

- (BOOL)nearTheEar{
    return [UIDevice currentDevice].proximityState;
}



@end

//
//  AVAudioSession+ZZAudioSession.m
//  Zazo
//
//  Created by Sani Elfishawy on 5/10/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "AVAudioSession+ZZAudioSession.h"
#import "OBLogger.h"

static NSMutableSet *ZZDelegates;
static BOOL zzAudioSessionIsSetup = NO;

@implementation AVAudioSession (ZZAudioSession)

#pragma mark Interface methods

-(void)setupApplicationAudioSession
{
    if (!zzAudioSessionIsSetup) {
        ZZLogInfo(@"setupApplicationAudioSession");
        [self setApplicationCategory];
        [self addObservers];
        zzAudioSessionIsSetup = YES;
    }
}

-(void)addZZAudioSessionDelegate:(id <ZZAudioSessionDelegate>)delegate{
    if (ZZDelegates == nil) ZZDelegates = [[NSMutableSet alloc] init];
    [ZZDelegates addObject: delegate];
}

-(NSError *)activate
{
    ZZLogInfo(@"activate:");
    NSError *error = nil;
    [self removeRouteChangeObserver];
    [self setApplicationCategory];
    [self setPortOverride];
    [self setActive:YES error:&error];
    
    if (!ANIsEmpty(error))
    {
        ZZLogWarning(@"activate: %@", error);
    }
    else
    {
        [self addRouteChangeObserver];
    }
    
    return error;
}

#pragma mark Audio Session Control

-(void)resetAudioSession {
    ZZLogInfo(@"resetAudioSession");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeRouteChangeObserver];
        [self setApplicationCategory];
        [self setPortOverride];
        [self addRouteChangeObserver];
    });
}

- (void)setApplicationCategory{
    ZZLogDebug(@"setApplicationCategory");
    NSError *error = nil;
    [self setCategory:AVAudioSessionCategoryPlayAndRecord
//   Eliminate play from bluetooth see v2.2.1 release notes
//          withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                error:&error];
    if (error != nil) ZZLogError(@"Error setting category: %@", error);
}

-(void)deactivate {
    ZZLogInfo(@"deactivate:");
    [self notifyDelegatesOfDeactivation];
    [self removeRouteChangeObserver];
    NSError *error = nil;
    [self setActive:NO
        withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
              error:&error];
    if (error != nil) ZZLogError(@"%@", error);
}

-(void)notifyDelegatesOfDeactivation{
    for (id <ZZAudioSessionDelegate> delegate in ZZDelegates){
        if ([delegate respondsToSelector:@selector(willDeactivateAudioSession)]) [delegate willDeactivateAudioSession];
    }
}

- (void)setPortOverride {
        if ([self hasNoExternalOutputs]) {
            ZZLogInfo(@"setPortOverride: no external outputs");
            NSError *error = nil;
            if ([self nearTheEar])
            {
                ZZLogInfo(@"setPortOverride: nearEar");
                AVAudioSession* session = [AVAudioSession sharedInstance];
                [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
            } else {
                ZZLogInfo(@"setPortOverride: farFromEar");
                AVAudioSession* session = [AVAudioSession sharedInstance];
                [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
            }
            if (error!=nil) ZZLogError(@"%@", error);
        } else {
            ZZLogInfo(@"Yes external outputs");
        }
}


#pragma mark Observers

-(void)addObservers {
    
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

-(void)handleRouteChange:(NSNotification *)notification
{
        ZZLogInfo(@"handleRouteChange: %@", notification.userInfo[AVAudioSessionRouteChangeReasonKey]);
        AVAudioSessionRouteDescription *previousRoute = (AVAudioSessionRouteDescription *) notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
        
        [self printOutputsWithPrefix:@"previousRoute:" Route:previousRoute];
        [self printOutputsWithPrefix:@"currentRoute:" Route:[self currentRoute]];
        
        // GARF: This is a hack. For some reason when changing route from bluetooth back to the built in spearker for
        // example when bluetooth is turned off it will play through earpiece and ignore the override unless I set the category
        // again. resetAudioSession does this.
        if (![self isOutputBuiltInWithRoute:previousRoute] &&
            [self isOutputBuiltInWithRoute:[self currentRoute]])
        {
            [self resetAudioSession];
        }
}

-(void)handleProximityChange:(NSNotification *)notification{
    ZZLogInfo(@"handleProximityChange");
    [self setPortOverride];
}

-(void)appDidBecomeActive{
    // This is handled explicitly in boot preflight so user is forced to ensure an audio session before using the app.
    //    [self activate];
}

-(void)appWillResignActive{
    // We wait here to give the video recorder time to stop preview before we deactivate audio session
    // so we dont get an error.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [self deactivate];
    });
}

-(void)handleAudioSessionInteruption{
    ZZLogInfo(@"AudioSessionInteruption");
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
        ZZLogInfo(@"%@ portType: %@", prefix, port.portType);
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

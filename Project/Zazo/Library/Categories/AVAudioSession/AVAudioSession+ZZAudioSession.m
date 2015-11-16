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
        [self _setApplicationCategory];
        [self _addObservers];
        zzAudioSessionIsSetup = YES;
    }
}

-(NSError *)activate
{
    ZZLogInfo(@"activate:");
    NSError *error = nil;
    [self _setApplicationCategory];
    [self setActive:YES error:&error];
    
    if (error)
    {
        ZZLogWarning(@"activate: %@", error);
    }
    return error;
}

- (void)startPlaying
{
    if (zzAudioSessionIsSetup)
    {
        ZZLogDebug(@"startPlaying");
        [self _setModePlay];
        [self _playBasedOnProximityAndRoute];
    }
}

- (void)startRecording
{
    if (zzAudioSessionIsSetup)
    {
        ZZLogDebug(@"startRecording");
        [self _setModeRecord];
        [self _playFromSpeaker];
    }
}

#pragma mark Audio Session Control

- (void)_setApplicationCategory{
    ZZLogDebug(@"setApplicationCategory");
    NSError *error = nil;
    [self setCategory:AVAudioSessionCategoryPlayAndRecord
//   Eliminate play from bluetooth see v2.2.1 release notes
//          withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                error:&error];
    if (error) ZZLogError(@"_setApplicationCategory: Error setting category: %@", error);
}

- (void)_setModeRecord
{
    [self _setApplicationCategory];
    ZZLogDebug(@"_setModeRecord");
    NSError *error = nil;
    [self setMode:AVAudioSessionModeVideoRecording error:&error];
    if (error) ZZLogError(@"_setModeRecord: Error setting mode: %@", error);
}

- (void)_setModePlay
{
    [self _setApplicationCategory];
    ZZLogDebug(@"_setModePlay");
    NSError *error = nil;
    [self setMode:AVAudioSessionModeDefault error:&error];
    if (error) ZZLogError(@"_setModePlay: Error setting mode: %@", error);
}

-(void)_deactivate {
    ZZLogInfo(@"deactivate:");
    NSError *error = nil;
    [self setActive:NO
        withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
              error:&error];
    if (error != nil) ZZLogError(@"%@", error);
}

- (void)_playBasedOnProximityAndRoute
{
    ZZLogInfo(@"playBasedOnProximity: nearEar=%d", [self _isNearTheEar]);
    
    if ([self _currentRouteHasHeadphonesOutput])
    {
        ZZLogDebug(@"playBasedOnProximity: headphones:");
        [self _playFromEar];
    }
    else
    {
        ZZLogDebug(@"playBasedOnProximity: noHeadphones:");
        if ([self _isNearTheEar])
        {
            [self _playFromEar];
        } else {
            [self _playFromSpeaker];
        }
    }
}

- (void)_playFromEar
{
    ZZLogInfo(@"playFromEar");
    NSError *error = nil;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    if (error!=nil) ZZLogError(@"%@", error);
}

- (void)_playFromSpeaker
{
    ZZLogInfo(@"playFromSpeaker");
    NSError *error = nil;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if (error!=nil) ZZLogError(@"%@", error);
}

#pragma mark Observers

-(void)_addObservers {
    // We do not allow external calls to enable or disable proximity sensor. There seems to be a bug with UIDeviceProximityStateDidChangeNotification. 3 out of 10 times or so the first time that the user changes the proximity after enabling proximity monitoring we do not receive the notification. The second change and later ones we always receive the notification. This is a annoying as it makes the hold to ear feature feel like it works only intermittently. The current solution is to always enable proximity. The implication is that even if user is not playing a video screen will dim when proximity sensor is covered. This is better than an feature that feels like it works intermittently.
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleProximityChange:)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleAudioSessionInteruption)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleAppDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleAppWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
}


#pragma mark Event Handlers

-(void)_handleRouteChange:(NSNotification *)notification
{
    ZZLogInfo(@"handleRouteChange: %@", notification.userInfo[AVAudioSessionRouteChangeReasonKey]);
    AVAudioSessionRouteDescription *previousRoute = (AVAudioSessionRouteDescription *) notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
    
    [self _printOutputsWithPrefix:@"previousRoute:" Route:previousRoute];
    [self _printOutputsWithPrefix:@"currentRoute:" Route:[self currentRoute]];
    
    [self _playBasedOnProximityAndRoute];
    
        // GARF: This is a hack. For some reason when changing route from bluetooth back to the built in spearker for
        // example when bluetooth is turned off it will play through earpiece and ignore the override unless I set the category
        // again. resetAudioSession does this.
//        if (![self isOutputBuiltInWithRoute:previousRoute] &&
//            [self isOutputBuiltInWithRoute:[self currentRoute]])
//        {
//            [self resetAudioSession];
//        }
    
}

-(void)_handleProximityChange:(NSNotification *)notification{
    ZZLogInfo(@"handleProximityChange");
    [self _playBasedOnProximityAndRoute];
}

-(void)_handleAppDidBecomeActive{
    // This is handled explicitly in boot preflight so user is forced to ensure an audio session before using the app.
    //    [self activate];
}

-(void)_handleAppWillResignActive{
    // We wait here to give the video recorder time to stop preview before we deactivate audio session
    // so we dont get an error.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [self _deactivate];
    });
}

-(void)_handleAudioSessionInteruption{
    ZZLogInfo(@"AudioSessionInteruption");
}


#pragma mark Route characteristics methods

- (void)_printOutputsWithPrefix:(NSString *)prefix Route: (AVAudioSessionRouteDescription *)route{
    for ( AVAudioSessionPortDescription *port in route.outputs ) {
        ZZLogInfo(@"%@ portType: %@", prefix, port.portType);
    }
}

-(BOOL)_currentRouteHasHeadphonesOutput {
    BOOL hasHeadphonesOutput = NO;
    for (AVAudioSessionPortDescription *port in self.currentRoute.outputs) {
        if ([port.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            hasHeadphonesOutput = YES;
        }
    }
    return hasHeadphonesOutput;
}



#pragma mark Proximity

- (BOOL)_isNearTheEar{
    return [UIDevice currentDevice].proximityState;
}

@end

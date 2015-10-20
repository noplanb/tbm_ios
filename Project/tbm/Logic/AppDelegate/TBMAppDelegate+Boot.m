//
//  TBMHomeViewController+Boot.m
//  tbm
//
//  Created by Sani Elfishawy on 5/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAlertController.h"
#import "TBMAppDelegate+Boot.h"
#import "TBMAppDelegate+AppSync.h"
#import "TBMUser.h"
#import "AVFoundation/AVFoundation.h"

#import "AVAudioSession+TBMAudioSession.h"
#import "ZZUserDataProvider.h"
#import "ZZUserDomainModel.h"
#import "ZZFileHelper.h"

@implementation TBMAppDelegate (Boot)

- (void)boot
{
    OB_INFO(@"Boot");
    [self ensurePushNotification]; // TODO: find correct place for calling this method, only for test
}

- (void)performDidBecomeActiveActions
{
    OB_INFO(@"performDidBecomeActiveActions: registered: %d", [ZZUserDataProvider authenticatedUser].isRegistered);
    
    if ([ZZUserDataProvider authenticatedUser].isRegistered)
    {
        [self ensureResources];
    }
}

#pragma mark - Ensure resources

/**
* Note these are all daisy chained together so that each resource check blocks until
* the user has satisfied it then it calls the next resource check in the list.
* It is a bit spagetti like. There is probably a more elegant way to do this.
* Daisy chain is:
* ensureFreeStorageSpace -> ensureAllMediaAccess (videoAccess -> audioAccess)
* -> ensureAudioSession -> onResourcesAvailable -> ensurePushNotification
*
* Note that we call onResources available BEFORE we ensurePushNotification because on IOS7 
* we do not get any callback if user declines notifications.
*/
- (void)ensureResources
{
    [self ensureFreeStorage];
}

- (void)ensureFreeStorage
{
    OB_INFO(@"Boot: ensureFreeStorage:");
    if ([ZZFileHelper loadFreeDiskspaceValue] < 250LL * 1024 * 1024)
        [self requestStorage];
    else
        [self ensureAllMediaAccess];
}

- (void)ensureAllMediaAccess {
    [self requestVideoAccess];
}

- (void)onResourcesAvailable {
    OB_INFO(@"onResourcesAvailable");
    [TBMVideo printAll];
    [self handleStuckDownloadsWithCompletionHandler:^{
        [self retryPendingFileTransfers];
        [self getAndPollAllFriends];
    }];
}

#pragma mark Ensure access for video camera and mic

- (void)onAllMediaAccessGranted {
    OB_INFO(@"Boot: onAllMediaAccessGranted");
    [self ensureAudioSession];
}


- (void)onVideoAccessGranted {
    OB_INFO(@"Boot: onVideoAccessGranted");
    [self requestAudioAccess];
}

- (void)onVideoAccessNotGranted
{
    OB_INFO(@"Boot: onVideoAccessNotGranted");

    NSString *msg;
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        msg = [NSString stringWithFormat:@"You must grant access to CAMERA for %@. Please close %@. Go your device home screen. Click Settings/Privacy/Camera and grant access for %@.", appName, appName, appName];
    } else {
        msg = [NSString stringWithFormat:@"You must grant access to CAMERA for %@. Please close %@. Go your device home screen. Click Settings/%@ and grant access for CAMERA.", appName, appName, appName];
    }

    NSString *closeBtn = [NSString stringWithFormat:@"Close %@", appName];
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Need Permission"
                                                                     message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:closeBtn style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        exit(0);
    }]];
    [alert presentWithCompletion:nil];
}

- (void)onAudioAccessGranted {
    OB_INFO(@"Boot: onAudioAccessGranted");
    [self onAllMediaAccessGranted];
}

- (void)onAudioAccessNotGranted
{
    OB_INFO(@"Boot: onAudioAccessNotGranted");
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    NSString *msg;

    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        msg = [NSString stringWithFormat:@"You must grant access to MICROPHONE for %@. Please close %@. Go your device home screen. Click Settings/privacy/microphone and grant access for %@.", appName, appName, appName];
    } else {
        msg = [NSString stringWithFormat:@"You must grant access to MICROPHONE for %@. Please close %@. Go your device home screen. Click Settings/%@ and grant access for MICROPHONE.", appName, appName, appName];
    }

    NSString *closeBtn = [NSString stringWithFormat:@"Close %@", appName];
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Need Permission"
                                                                     message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:closeBtn style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        exit(0);
    }]];
    [alert presentWithCompletion:nil];
}

- (void)requestVideoAccess {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            [self performSelectorOnMainThread:@selector(onVideoAccessGranted) withObject:nil waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(onVideoAccessNotGranted) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (void)requestAudioAccess {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if (granted) {
            [self performSelectorOnMainThread:@selector(onAudioAccessGranted) withObject:nil waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(onAudioAccessNotGranted) withObject:nil waitUntilDone:NO];
        }
    }];
}

#pragma mark Ensure free storage space

- (void)requestStorage
{
    OB_INFO(@"Boot: requestStorage");
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    NSString *msg = [NSString stringWithFormat:@"No available storage on device. Close %@. Delete some videos and photos. Be sure to delete permanently from recently deleted folder. Then try again.", appName];
    NSString *closeBtn = [NSString stringWithFormat:@"Close %@", appName];
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"No Available Storage"
                                                                     message:msg];

    [alert addAction:[SDCAlertAction actionWithTitle:closeBtn style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        // In case the user backgrounds the app we will create stacked alerts here.
        // I exit so that when the user dismisses the alert we start fresh.
        // A better solution would be to automatically dismiss all alerts when app goes to background.
        // But this is a pain when supporting both ios7 and ios8 type alerts.
        exit(0);
    }]];
    [alert presentWithCompletion:nil];
}

#pragma mark Ensure Audio Session

- (void)ensureAudioSession {
    OB_INFO(@"ensureAudioSession");
    [[AVAudioSession sharedInstance] setupApplicationAudioSession];
    if ([[AVAudioSession sharedInstance] activate] != nil){
        OB_INFO(@"Boot: No Audio Session");
        [self alertEndProbablePhoneCall];
    } else {
        OB_INFO(@"Boot: Audio Session Granted");
        /**
         * Note that we call onResources available BEFORE we ensurePushNotification because on IOS7
         * we do not get any callback if user declines notifications.
         */
        [self onResourcesAvailable];
        [self ensurePushNotification];
    }
}

- (void)ensurePushNotification {
    [self registerForPushNotification];
}

- (void)alertEndProbablePhoneCall {
    OB_INFO(@"alertProbablePhoneCall");
    NSString *msg = @"Unable to acquire audio. Perhaps you are on a phone call?";
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"On a Call?" message:msg];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Try Again"
                                               style:SDCAlertActionStyleDefault
                                             handler:^(SDCAlertAction *action) {
                                                 // In case the user backgrounds the app we will create stacked alerts here.
                                                 // I exit so that when the user dismisses the alert we start fresh.
                                                 // A better solution would be to automatically dismiss all alerts when app goes to background.
                                                 // But this is a pain when supporting both ios7 and ios8 type alerts.
                                                 exit(0);
                                             }]];
    [alert presentWithCompletion:nil];
}

#pragma mark Ensure push notifications

//- (void)_onGrantedPushAccess
//{
//    OB_INFO(@"BOOT: Push access granted");
//    // Note we do not call onResourcesAvailable here since it is called prior to ensuring push notification. This is because
//    // on io7 we do not get a callback from the os if the user declines notifications.
//}

- (void)_onFailPushAccess
{
    OB_INFO(@"BOOT: Push access not granted");
    if (self.pushAlreadyFailed) {
        return;
    }
    self.pushAlreadyFailed = YES;
    OB_INFO(@"onFailPushAccess");
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    NSString *closeBtn = [NSString stringWithFormat:@"Close %@", appName];
    NSString *msg = @"You must grant permission for NOTIFICATIONS."
            " Go your device home screen. "
            "Click Settings/Zazo and allow notifications for Zazo. "
            "Zazo is a messaging app and requires notifications to operate.";

    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Need Permission" message:msg];

    [alert addAction:[SDCAlertAction actionWithTitle:closeBtn style:SDCAlertActionStyleDefault
                                             handler:^(SDCAlertAction *action) {
                                                 exit(0);
                                             }]];

    [alert presentWithCompletion:nil];
}

@end

//
//  TBMHomeViewController+Boot.m
//  tbm
//
//  Created by Sani Elfishawy on 5/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAlertController.h"
#import "TBMConfig.h"
#import "TBMAppDelegate+Boot.h"
#import "TBMAppDelegate+PushNotification.h"
#import "TBMAppDelegate+AppSync.h"
#import "TBMS3CredentialsManager.h"
#import "TBMUser.h"
#import "TBMDispatch.h"
#import "AVFoundation/AVFoundation.h"
#import "TBMFileUtils.h"
#import "AVAudioSession+TBMAudioSession.h"

@implementation TBMAppDelegate (Boot)

- (void)boot {
    OB_INFO(@"Boot");
    [TBMDispatch enable];
    TBMUser *user = [TBMUser getUser];
    if (!user.isRegistered) {
        self.window.rootViewController = [self registerViewController];
    } else {
        self.window.rootViewController = [self homeViewController];
        [self postRegistrationBoot];
    }
}

- (void)didCompleteRegistration {
    OB_INFO(@"didCompleteRegistration");
    [[self registerViewController] presentViewController:[self homeViewController] animated:YES completion:nil];
    [self postRegistrationBoot];
    [self performDidBecomeActiveActions];
}

- (void)postRegistrationBoot {
    [TBMS3CredentialsManager refreshFromServer:nil];
}

- (void)performDidBecomeActiveActions {
    OB_INFO(@"performDidBecomeActiveActions: registered: %d", [TBMUser getUser].isRegistered);
    if (![TBMUser getUser].isRegistered)
        return;

    [self ensureResources];
}

#pragma mark - Ensure resources

/**
* Note these are all daisy chained together so that each resource check blocks until
* the user has satisfied it then it calls the next resource check in the list.
* It is a bit spagetti like. There is probably a more elegant way to do this.
* Daisy chain is:
* ensureFreeStorageSpace -> ensureAllMediaAccess (videoAccess -> audioAccess)
* -> ensureAudioSession -> ensurePushNotification -> onResourcesAvailable
*/
- (void)ensureResources {
    [self ensureFreeStorage];
}

- (void)ensureFreeStorage {
    OB_INFO(@"Boot: ensureFreeStorage:");
    if ([TBMFileUtils getFreeDiskspace] < 250LL * 1024 * 1024)
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

- (void)onVideoAccessNotGranted {
    OB_INFO(@"Boot: onVideoAccessNotGranted");

    NSString *msg;

    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        msg = [NSString stringWithFormat:@"You must grant access to CAMERA for %@. Please close %@. Go your device home screen. Click Settings/Privacy/Camera and grant access for %@.", CONFIG_APP_NAME, CONFIG_APP_NAME, CONFIG_APP_NAME];
    } else {
        msg = [NSString stringWithFormat:@"You must grant access to CAMERA for %@. Please close %@. Go your device home screen. Click Settings/%@ and grant access for CAMERA.", CONFIG_APP_NAME, CONFIG_APP_NAME, CONFIG_APP_NAME];
    }

    NSString *closeBtn = [NSString stringWithFormat:@"Close %@", CONFIG_APP_NAME];
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

- (void)onAudioAccessNotGranted {
    OB_INFO(@"Boot: onAudioAccessNotGranted");

    NSString *msg;

    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        msg = [NSString stringWithFormat:@"You must grant access to MICROPHONE for %@. Please close %@. Go your device home screen. Click Settings/privacy/microphone and grant access for %@.", CONFIG_APP_NAME, CONFIG_APP_NAME, CONFIG_APP_NAME];
    } else {
        msg = [NSString stringWithFormat:@"You must grant access to MICROPHONE for %@. Please close %@. Go your device home screen. Click Settings/%@ and grant access for MICROPHONE.", CONFIG_APP_NAME, CONFIG_APP_NAME, CONFIG_APP_NAME];
    }

    NSString *closeBtn = [NSString stringWithFormat:@"Close %@", CONFIG_APP_NAME];
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

- (void)requestStorage {
    OB_INFO(@"Boot: requestStorage");
    NSString *msg = [NSString stringWithFormat:@"No available storage on device. Close %@. Delete some videos and photos. Be sure to delete permanently from recently deleted folder. Then try again.", CONFIG_APP_NAME];
    NSString *closeBtn = [NSString stringWithFormat:@"Close %@", CONFIG_APP_NAME];
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
    if ([[AVAudioSession sharedInstance] activate] != nil)
        [self alertEndProbablePhoneCall];
    else
        [self ensurePushNotification];
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

- (void)onGrantedPushAccess {
    [self onResourcesAvailable];
}

- (void)onFailPushAccess {
    if (self.pushAlreadyFailed) {
        return;
    }
    OB_INFO(@"onFailPushAccess");
    NSString *closeBtn = [NSString stringWithFormat:@"Close %@", CONFIG_APP_NAME];
    NSString *msg = @"You must grant permission for notifications."
            " Please close Zazo. Go your device home screen. "
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

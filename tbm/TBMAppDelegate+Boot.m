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
#import "TBMFriend.h"
#import "OBLogger.h"
#import "TBMDispatch.h"
#import "AVFoundation/AVFoundation.h"
#import "TBMFileUtils.h"
#import "TBMAudioSessionRouter.h"
#import "TBMDeviceHandler.h"

@implementation TBMAppDelegate (Boot)

- (void) boot{
    OB_INFO(@"Boot");

    [TBMDispatch enable];
    
    if (![TBMUser getUser].isRegistered){
        self.window.rootViewController = [self registerViewController];
    } else {
        self.window.rootViewController = [self homeViewController];
        [self postRegistrationBoot];
    }
}

- (void)didCompleteRegistration{
    OB_INFO(@"didCompleteRegistration");
    [[self registerViewController] presentViewController:[self homeViewController] animated:YES completion:nil];
    [self postRegistrationBoot];
    [self performDidBecomeActiveActions];
}

- (void)postRegistrationBoot{
    [self setupPushNotificationCategory];
    [self registerForPushNotification];
    [TBMS3CredentialsManager refreshFromServer:nil];
}

- (void)performDidBecomeActiveActions{
    OB_INFO(@"performDidBecomeActiveActions: registered: %d", [TBMUser getUser].isRegistered);
    if (![TBMUser getUser].isRegistered)
        return;
    
    [self ensureResources];
#warning Kirill I disconnected the audiosession router here because I found it quite buggy when testing the video recorder.
//    [[TBMAudioSessionRouter sharedInstance] findAvailbleBluetoothDevices];
}

- (void)ensureResources{
    // Note these are all daisy chained together so that each resource check blocks until
    // the user has satisfied it then it calls the next resource check in the list.
    // It is a bit spagetti like. There is probably a more elegant way to do this.
    // Daisy chain is:
    // ensureFreeStorageSpace -> ensureAllMediaAccess (videoAccess -> audioAccess) -> onResourcesAvailable
    
    [self ensureFreeStorage];
}

- (void)onResourcesAvailable{
    OB_ERROR(@"TBMDeviceHandler.isCameraConnected: %d", [TBMDeviceHandler isCameraConnected]);
    OB_ERROR(@"TBMDeviceHandler.isMicrophoneConnected: %d", [TBMDeviceHandler isMiccrophoneConnected]);
    OB_ERROR(@"AudioSessionInputAvailable: %d", [AVAudioSession sharedInstance].inputAvailable);
    OB_ERROR(@"TBMDeviceHandler#getAudioInputWithError: %@", [TBMDeviceHandler getAudioInputWithError:nil]);

    [TBMVideo printAll];
    [self handleStuckDownloadsWithCompletionHandler:^{
        [self retryPendingFileTransfers];
        [self getAndPollAllFriends];
    }];
}

//---------------------------------------
// Ensure access for video camera and mic
//---------------------------------------
- (void)ensureAllMediaAccess{
    [self requestVideoAccess];
}

- (void)onAllMediaAccessGranted{
    OB_INFO(@"Boot: onAllMediaAccessGranted");
    [self onResourcesAvailable];
}


- (void)onVideoAccessGranted{
    OB_INFO(@"Boot: onVideoAccessGranted");
    [self requestAudioAccess];
}

- (void)onVideoAccessNotGranted{
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

- (void)onAudioAccessGranted{
    OB_INFO(@"Boot: onAudioAccessGranted");
    [self onAllMediaAccessGranted];
}

- (void)onAudioAccessNotGranted{
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

- (void)requestVideoAccess{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted){
            [self performSelectorOnMainThread:@selector(onVideoAccessGranted) withObject:nil waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(onVideoAccessNotGranted) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (void)requestAudioAccess{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if (granted){
            [self performSelectorOnMainThread:@selector(onAudioAccessGranted) withObject:nil waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(onAudioAccessNotGranted) withObject:nil waitUntilDone:NO];
        }
    }];
}


//--------------------------
// Ensure free storage space
//--------------------------

- (void)ensureFreeStorage{
    OB_INFO(@"Boot: ensureFreeStorage:");
    if ([TBMFileUtils getFreeDiskspace] < 250LL * 1024 * 1024)
        [self requestStorage];
    else
        [self ensureAllMediaAccess];
}


- (void) requestStorage{
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
@end

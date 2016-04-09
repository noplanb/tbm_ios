//
//  ZZApplicationPermissionsHandler.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZApplicationPermissionsHandler.h"
#import "ZZFileHelper.h"
#import "TBMAlertController.h"

@import AVFoundation;
#import "AVAudioSession+ZZAudioSession.h"
#import "NSObject+ANRACAdditions.h"

@import PermissionScope;

static PermissionScope *permissionScope;

static BOOL hasDeclinedNotifications = NO; // TODO: remp solution, removed property

typedef NS_ENUM(NSInteger, ZZApplicationPermissionType)
{
    ZZApplicationPermissionTypeNone,
    ZZApplicationPermissionTypeVideo,
    ZZApplicationPermissionTypeAudio,
    ZZApplicationPermissionTypeFreeStorage,
    ZZApplicationPermissionTypePush,
    ZZApplicationPermissionTypeAudioSessionState
};

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

@implementation ZZApplicationPermissionsHandler

+ (RACSignal*)checkApplicationPermissions
{
    if (permissionScope)
    {
        return nil; // another permission check in progress;
    }
    
    return [[[[self _checkFreeSpace]
               
               flattenMap:^RACStream *(id value) {
                   
                   return [self _askPermissionsStep1];
                   
               }] flattenMap:^RACStream *(id value) {
                   
                   return [self _askPermissionsStep2];
                   
               }] flattenMap:^RACStream *(id value) {
        
                   return [self _checkAudioSession];
    }];
}

#pragma mark - Access Checks

+ (RACSignal *)_askForPermissions:(NSArray <id <Permission>> * _Nonnull)permissions
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        permissionScope = [[PermissionScope alloc] initWithBackgroundTapCancels:NO];
        permissionScope.closeButton.hidden = YES;
        
        [permissions enumerateObjectsUsingBlock:^(id<Permission>  _Nonnull permission, NSUInteger idx, BOOL * _Nonnull stop) {
            [permissionScope addPermission:permission
                                   message:[self _messageForPermission:permission]];
        }];
        
        [permissionScope show:^(BOOL completed, NSArray<PermissionResult *> * _Nonnull result) {
            if (completed)
            {
                [subscriber sendNext:result];
            }
        } cancelled:^(NSArray<PermissionResult *> * _Nonnull result) {
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

+ (NSString *)_messageForPermission:(id<Permission>)permission
{
    switch (permission.type)
    {
        case PermissionTypeContacts:
            return @"Text for contacts";
            break;
        case PermissionTypeNotifications:
            return @"Text for notifications";
            break;
        case PermissionTypeMicrophone:
            return @"Text for Mic";
            break;
        case PermissionTypeCamera:
            return @"Text for camera";
            break;
            
        default:
            break;
    }
    
    return nil;
}

+ (RACSignal *)_askPermissionsStep1
{
    return [self _askForPermissions:@[
                                      [MicrophonePermission new],
                                      [CameraPermission new]
                                      ]];
}

+ (RACSignal *)_askPermissionsStep2
{
    return [self _askForPermissions:@[
                                      [[NotificationsPermission alloc] initWithNotificationCategories:nil],
                                      [ContactsPermission new]
                                      ]];
}

+ (RACSignal*)_checkFreeSpace
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        BOOL hasSpace = ([ZZFileHelper loadFreeDiskspaceValue] > 250LL * 1024 * 1024);
        NSError* error = hasSpace ? nil : [self _errorWithPermissionType:ZZApplicationPermissionTypeFreeStorage];
        [self an_handleSubcriber:subscriber withObject:@(hasSpace) error:error];
        return [RACDisposable disposableWithBlock:^{}];
    }];
}

+ (RACSignal*)_checkAudioSession
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        ZZLogInfo(@"ensureAudioSession");
        [[AVAudioSession sharedInstance] setupApplicationAudioSession];
        
        BOOL isReady = ([[AVAudioSession sharedInstance] activate] == nil);
        NSError* error = isReady ? nil : [self _errorWithPermissionType:ZZApplicationPermissionTypeAudioSessionState];
        [NSObject an_handleSubcriber:subscriber withObject:@(YES) error:error];

        return [RACDisposable disposableWithBlock:^{}];
    }];
}


//#pragma mark - Private
//
//+ (void)_handlePermissionError:(NSError*)error
//{
//    
//    ZZApplicationPermissionType state = error.code;
//    
//    switch (state)
//    {
//        case ZZApplicationPermissionTypeVideo:
//        {
//            [self _showVideoAccessDeclinedAlert];
//        }  break;
//            
//        case ZZApplicationPermissionTypeAudio:
//        {
//            [self _showAudioAccessDeclinedAlert];
//        } break;
//            
//        case ZZApplicationPermissionTypeFreeStorage:
//        {
//            [self _showNotEnoughFreeStorageAlert];
//        } break;
//            
//        case ZZApplicationPermissionTypePush:
//        {
//            [self showUserDeclinedPushAccessAlert];
//            
//        } break;
//        case ZZApplicationPermissionTypeAudioSessionState:
//        {
//            //[self _showUserProbableOnCallAlert];
//        } break;
//        default: break;
//    }
//}


//#pragma mark - Private Alerts
////TODO: ZZAlertBuilder + localized strings
//
+ (void)showUserDeclinedPushAccessAlert
{
    
}
//
//+ (void)_showNotEnoughFreeStorageAlert
//{
//    ZZLogInfo(@"Boot: requestStorage");
//    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
//    NSString *msg = [NSString stringWithFormat:@"No available storage on device. Close %@. Delete some videos and photos. Be sure to delete permanently from recently deleted folder. Then try again.", appName];
//    NSString *closeBtn = [NSString stringWithFormat:@"Close %@", appName];
//    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"No Available Storage"
//                                                                     message:msg];
//    
//    [alert addAction:[SDCAlertAction actionWithTitle:closeBtn style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
//        // In case the user backgrounds the app we will create stacked alerts here.
//        // I exit so that when the user dismisses the alert we start fresh.
//        // A better solution would be to automatically dismiss all alerts when app goes to background.
//        // But this is a pain when supporting both ios7 and ios8 type alerts.
//        exit(0);
//    }]];
//    
//    [self _presentAlertController:alert];
//}
//
//+ (void)_showAudioAccessDeclinedAlert
//{
//    ZZLogInfo(@"Boot: onAudioAccessNotGranted");
//    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
//    NSString *msg;
//    
//    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
//    {
//        msg = [NSString stringWithFormat:@"You must grant access to MICROPHONE for %@. Please close %@. Go your device home screen. Click Settings/privacy/microphone and grant access for %@.", appName, appName, appName];
//    }
//    else
//    {
//        msg = [NSString stringWithFormat:@"You must grant access to MICROPHONE for %@. Please close %@. Go your device home screen. Click Settings/%@ and grant access for MICROPHONE.", appName, appName, appName];
//    }
//    
//    NSString *closeBtn = [NSString stringWithFormat:@"Close %@", appName];
//    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Need Permission"
//                                                                     message:msg];
//    [alert addAction:[SDCAlertAction actionWithTitle:closeBtn style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
//        exit(0);
//    }]];
//    
//    [self _presentAlertController:alert];
//}
//
//+ (void)_showVideoAccessDeclinedAlert
//{
//    ZZLogInfo(@"Boot: onVideoAccessNotGranted");
//    
//    NSString *msg;
//    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
//    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
//    {
//        msg = [NSString stringWithFormat:@"You must grant access to CAMERA for %@. Please close %@. Go your device home screen. Click Settings/Privacy/Camera and grant access for %@.", appName, appName, appName];
//    }
//    else
//    {
//        msg = [NSString stringWithFormat:@"You must grant access to CAMERA for %@. Please close %@. Go your device home screen. Click Settings/%@ and grant access for CAMERA.", appName, appName, appName];
//    }
//    
//    NSString *closeBtn = [NSString stringWithFormat:@"Close %@", appName];
//    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Need Permission"
//                                                                     message:msg];
//    [alert addAction:[SDCAlertAction actionWithTitle:closeBtn style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
//        exit(0);
//    }]];
//    
//    [self _presentAlertController:alert];
//}
//
//+ (void)_showUserProbableOnCallAlert
//{
//    ZZLogInfo(@"alertProbablePhoneCall");
//    NSString *msg = @"Unable to acquire audio. Perhaps you are on a phone call?";
//    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"On a Call?" message:msg];
//    [alert addAction:[SDCAlertAction actionWithTitle:@"Try Again"
//                                               style:SDCAlertActionStyleDefault
//                                             handler:^(SDCAlertAction *action) {
//                                                 // In case the user backgrounds the app we will create stacked alerts here.
//                                                 // I exit so that when the user dismisses the alert we start fresh.
//                                                 // A better solution would be to automatically dismiss all alerts when app goes to background.
//                                                 // But this is a pain when supporting both ios7 and ios8 type alerts.
//                                                 exit(0);
//                                             }]];
//    [alert presentWithCompletion:nil];
//}
//
//+ (void)_presentAlertController:(TBMAlertController*)alert
//{
//    ANDispatchBlockToMainQueue(^{
//        [alert presentWithCompletion:nil];
//    });
//}

+ (NSError*)_errorWithPermissionType:(ZZApplicationPermissionType)type
{
    return [NSError errorWithDomain:@"com.zazo.zazo" code:type userInfo:nil];
}

@end

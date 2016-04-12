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

+ (RACSignal *)checkApplicationPermissions
{
    if (permissionScope)
    {
        return nil; // another permission check in progress;
    }
    
    return [[[[[self _checkFreeSpace]
               
               flattenMap:^RACStream *(id value) {
                   
                   return [self _askPermissions];
                   
               }] flattenMap:^RACStream *(id value) {
        
                   return [self _checkAudioSession];
    }] doError:^(NSError *error) {
        [self _handlePermissionError:error];
    }] doCompleted:^{
        permissionScope = nil;
    }];
}

#pragma mark - Access Checks

+ (RACSignal *)_askForPermissions:(NSArray <id <Permission>> * _Nonnull)permissions
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        permissionScope = [[PermissionScope alloc] initWithBackgroundTapCancels:NO];
        permissionScope.closeButton.hidden = YES;
        
        permissionScope.headerLabel.text = @"Permissions";
        permissionScope.headerLabel.font = [UIFont zz_boldFontWithSize:21];
        permissionScope.bodyLabel.text = @"Zazo is a video messaging app";
        permissionScope.bodyLabel.font = [UIFont zz_regularFontWithSize:16];
        
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
        case PermissionTypeNotifications:
            return @"To receive messages";
            break;
        case PermissionTypeMicrophone:
            return @"To record messages";
            break;
        case PermissionTypeCamera:
            return @"To record messages";
            break;
            
        default:
            break;
    }
    
    return nil;
}

+ (RACSignal *)_askPermissions
{
    return [self _askForPermissions:@[
                                      [CameraPermission new],
                                      [MicrophonePermission new],
                                      [[NotificationsPermission alloc] initWithNotificationCategories:nil]
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

#pragma mark - Private

+ (void)_handlePermissionError:(NSError*)error
{
    ZZApplicationPermissionType state = error.code;
    
    switch (state)
    {
            
        case ZZApplicationPermissionTypeFreeStorage:
        {
            [self _showNotEnoughFreeStorageAlert];
        } break;
            
        default: break;
    }
}

+ (void)_showNotEnoughFreeStorageAlert
{
    ZZLogInfo(@"Boot: requestStorage");
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    
    NSString *message =
    [NSString stringWithFormat:@"No available storage on device. Close %@. Delete some videos and photos. Be sure to delete permanently from recently deleted folder. Then try again.", appName];
    
    TBMAlertController *alert =
    [TBMAlertController alertControllerWithTitle:@"No Available Storage"
                                         message:message];
    
    [self _presentAlertController:alert];
}

+ (void)_presentAlertController:(TBMAlertController*)alert
{
    [alert dismissWithApplicationAutomatically];
    
    ANDispatchBlockToMainQueue(^{
        [alert presentWithCompletion:nil];
    });
}

+ (NSError *)_errorWithPermissionType:(ZZApplicationPermissionType)type
{
    return [NSError errorWithDomain:@"com.zazo.zazo" code:type userInfo:nil];
}

@end

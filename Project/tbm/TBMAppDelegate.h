//
//  TBMAppDelegate.h
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMRegisterViewController.h"
@class TBMHomeViewController;

@protocol TBMAppDelegateEventNotificationProtocol <NSObject>

- (void)appWillEnterForeground;
- (void)appDidBecomeActive;

@end

@interface TBMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TBMRegisterViewController *registerViewController;
@property (strong, nonatomic) TBMHomeViewController *homeViewController;

@property (nonatomic) BOOL isForeground;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (copy) void (^backgroundUploadSessionCompletionHandler)();
@property (copy) void (^backgroundDownloadSessionCompletionHandler)();

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;

@property(nonatomic) UIUserNotificationType notificationAllowedTypes;

@property(nonatomic) BOOL pushAlreadyFailed;

-(void)onGrantedPushAccess;
-(void)onFailPushAccess;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void) requestBackground;
- (void)setLifeCycleEventNotificationDelegate:(id)delegate;

@end

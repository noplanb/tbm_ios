//
//  TBMAppDelegate.m
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate.h"
#import "TBMAppDelegate+PushNotification.h"
#import "TBMAppDelegate+AppSync.h"
#import "TBMStringUtils.h"
#import "OBFileTransferManager.h"

@implementation TBMAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // See doc/notification.txt for why we dont use this in our app.
    [OBLogger instance].writeToConsole = YES;
    [[OBLogger instance] reset];
    DebugLog(@"willFinishLaunchingWithOptions:");
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    OB_INFO(@"didFinishLaunchingWithOptions:");
    
    [self setupPushNotificationCategory];
    
    // See doc/notification.txt for why we handle the payload here as well as in didReceiveRemoteNotification:fetchCompletionHandler
    // for the case where app is launching from a terminated state due to user clicking on notification. Even though both this method
    // and the didReceiveRemoteNotification:fetchCompletionHandler are called in that case.
    NSDictionary *remoteNotificationUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationUserInfo) [self handleNotificationPayload:remoteNotificationUserInfo];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application{
    OB_INFO(@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    OB_INFO(@"applicationDidEnterBackground: backgroundTimeRemaining = %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
    [self saveContext];
    [[OBLogger instance] logEvent:OBLogEventAppBackground];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    OB_INFO(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    OB_INFO(@"applicationDidBecomeActive");
    // GARF: Need to implement this in the new architecture.
    // This makes retry start immediately and from a count of 0 when the user comes back to the app presumabably after
    // fixing whatever network problem was preventing the downloads or uploads.
//    _uploadManager = [TBMUploadManagerDeprecated sharedManager];
//    [_uploadManager restartTasksPendingRetry];
//    
//    _downloadManager = [TBMDownloadManagerDeprecated sharedManager];
//    [_downloadManager restartTasksPendingRetry];
    [[OBLogger instance] logEvent:OBLogEventAppForeground];
    [self clearNotifcationCenter];
    [self pollAllFriends];
    [self retryPendingFileTransfers];
}

- (void)applicationWillTerminate:(UIApplication *)application{
    OB_INFO(@"applicationWillTerminate: backgroundTimeRemaining = %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext{
    OB_INFO(@"saveContext");
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"tbm" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"tbm.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    OB_INFO(@"handleEventsForBackgroundURLSession: for sessionId=%@",identifier);
    OBFileTransferManager *tm = [OBFileTransferManager instance];
    [tm initSession];
    if ([[tm session].configuration.identifier isEqual:identifier]){
        tm.backgroundSessionCompletionHandler = completionHandler;
    } else {
        OB_ERROR(@"handleEventsForBakcgroundURLSession passed us a different identifier from the one we instantiated our background session with.");
    }
}

//-------------------
// Request Background
//-------------------
-(void) requestBackground{
    OB_INFO(@"requestBackground");
    if ( self.backgroundTaskId == UIBackgroundTaskInvalid ) {
        self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            OB_INFO(@"Ending background tasks");
            self.backgroundTaskId = UIBackgroundTaskInvalid;
            [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTaskId];
        }];
    }
}


@end

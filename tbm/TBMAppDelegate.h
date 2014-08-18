//
//  TBMAppDelegate.h
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (copy) void (^backgroundUploadSessionCompletionHandler)();
@property (copy) void (^backgroundDownloadSessionCompletionHandler)();


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

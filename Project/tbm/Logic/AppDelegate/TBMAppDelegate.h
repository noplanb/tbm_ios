//
//  TBMAppDelegate.h
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "ZZAppDependencies.h"

@interface TBMAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
@property (nonatomic) UIUserNotificationType notificationAllowedTypes;
@property (nonatomic) BOOL pushAlreadyFailed;

//temp in public
@property (nonatomic, strong) ZZAppDependencies* appDependencies;

- (NSURL*)applicationDocumentsDirectory;
- (void) requestBackground;

@end

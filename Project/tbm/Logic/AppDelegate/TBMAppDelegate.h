//
//  TBMAppDelegate.h
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "ZZAppDependencies.h"

static NSString* const kNotificationSendMessage = @"sendMessageNotification";

@class TBMHomeViewController;

@protocol TBMAppDelegateEventNotificationProtocol <NSObject>

- (void)appWillEnterForeground;
- (void)appDidBecomeActive;

@end

@interface TBMAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic) BOOL isForeground;

@property (copy) void (^backgroundUploadSessionCompletionHandler)();
@property (copy) void (^backgroundDownloadSessionCompletionHandler)();

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;

@property(nonatomic) UIUserNotificationType notificationAllowedTypes;

@property(nonatomic) BOOL pushAlreadyFailed;

@property (nonatomic, strong) NSString* pushVideoId;

//temp in public
@property (nonatomic, strong) ZZAppDependencies* appDependencies;
@property (nonatomic, strong) NSArray* myFriends;

-(void)onGrantedPushAccess;
-(void)onFailPushAccess;

- (NSURL*)applicationDocumentsDirectory;
- (void) requestBackground;

@end

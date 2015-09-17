//
//  TBMAppDelegate.h
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "ZZAppDependencies.h"
#import "TBMEventsFlowModuleInterface.h"

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

//temp in public
@property (nonatomic, strong) ZZAppDependencies* appDependencies;
@property (nonatomic, strong) NSArray* myFriends;

@property (nonatomic, strong) id<TBMEventsFlowModuleInterface> eventsFlowModule;

-(void)onGrantedPushAccess;
-(void)onFailPushAccess;

- (NSURL*)applicationDocumentsDirectory;
- (void) requestBackground;
- (void)setLifeCycleEventNotificationDelegate:(id)delegate;

@end

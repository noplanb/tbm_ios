//
//  ZZRootStateObserver.h
//  Zazo
//
//  Created by ANODA on 10/29/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

typedef NS_ENUM(NSInteger, ZZRootStateObserverEvents)
{
    ZZRootStateObserverEventsNone,
    ZZRootStateObserverEventsUserAuthorized,
    ZZRootStateObserverEventsFriendsAfterAuthorizationLoaded,
    ZZRootStateObserverEventDownloadedMkeys,
    ZZRootStateObserverEventFriendWasAddedToGridWithVideo,
    ZZRootStateObserverEventFriendInContactChangeStauts,
    ZZRootStateObserverEventResetAllLoaderTask,
    ZZRootStateObserverEventFriendAbilitiesChanged,
    ZZRootStateObserverEventAvatarChanged,
    
};

@protocol ZZRootStateObserverDelegate <NSObject>

- (void)handleEvent:(ZZRootStateObserverEvents)event notificationObject:(id)notificationObject;

@end

@interface ZZRootStateObserver : NSObject

+ (id)sharedInstance;

- (void)addRootStateObserver:(id <ZZRootStateObserverDelegate>)observer;

- (void)removeRootStateObserver:(id <ZZRootStateObserverDelegate>)observer;

- (void)notifyWithEvent:(ZZRootStateObserverEvents)event notificationObject:(id)notificationObject;

@end

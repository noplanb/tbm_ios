//
//  ZZRootStateObserver.m
//  Zazo
//
//  Created by ANODA on 10/29/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZRootStateObserver.h"

@interface ZZRootStateObserver ()

@property (nonatomic, strong) NSMutableArray *observers;

@end

@implementation ZZRootStateObserver

+ (id)sharedInstance
{
    static ZZRootStateObserver *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.observers = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Observer Storage

- (void)addRootStateObserver:(id <ZZRootStateObserverDelegate>)observer
{
    [self.observers addObject:observer];
}

- (void)removeRootStateObserver:(id <ZZRootStateObserverDelegate>)observer
{
    [self.observers removeObject:observer];
}


#pragma mark - Notify observers

- (void)notifyWithEvent:(ZZRootStateObserverEvents)event
     notificationObject:(id)notificationObject;
{
    for (id <ZZRootStateObserverDelegate> observer in self.observers)
    {
        [observer handleEvent:event notificationObject:notificationObject];
    }
}

@end

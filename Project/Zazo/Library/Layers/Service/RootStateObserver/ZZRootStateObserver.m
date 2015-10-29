//
//  ZZRootStateObserver.m
//  Zazo
//
//  Created by ANODA on 10/29/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZRootStateObserver.h"

@interface ZZRootStateObserver ()

@property (nonatomic, strong) NSMutableArray* obeservers;

@end

@implementation ZZRootStateObserver

+ (id)sharedInstance {
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
        self.obeservers = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Observer Storage

- (void)addRootStateObserver:(id<ZZRootStateObserverDelegate>)observer
{
    [self.obeservers addObject:observer];
}

- (void)removeRootStateObserver:(id<ZZRootStateObserverDelegate>)observer
{
    [self.obeservers removeObject:observer];
}


#pragma mark - Notify observers

- (void)notifyWithEvent:(ZZRootStateObserverEvents)event
{
    for (id <ZZRootStateObserverDelegate> observer in self.obeservers)
    {
        [observer handleEvent:event];
    }
}

@end

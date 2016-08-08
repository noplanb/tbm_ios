//
//  ZZMessageGroup.m
//  Zazo
//
//  Created by Rinat on 08/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZMessageGroup.h"
#import "ZZMessageDomainModel.h"

@interface ZZMessageGroup ()

@property (nonatomic, strong, readwrite) NSArray <ZZMessageDomainModel *> *messages;

@end

@implementation ZZMessageGroup

- (instancetype)init
{
    self = [super init];
    if (self) {
        _messages = @[];
    }
    return self;
}

- (void)addMessage:(ZZMessageDomainModel *)message
{
    if (![message isKindOfClass:[ZZMessageDomainModel class]]) {
        return;
    }
    
    self.messages = [self.messages arrayByAddingObject:message];
}

// ZZPlaybackQueueItem

- (NSTimeInterval)timestamp
{
    return [self.messages.firstObject timestamp];
}

- (ZZIncomingEventType)type
{
    return ZZIncomingEventTypeMessage;
}

@end

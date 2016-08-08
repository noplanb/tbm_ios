//
//  ZZPlaybackQueueItem.h
//  Zazo
//
//  Created by Server on 02/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZPlaybackQueueItem.h"

@implementation ZZVideoDomainModel (ZZPlaybackQueueItem)

- (NSTimeInterval)timestamp
{
    return self.videoID.doubleValue / 1000;
}

- (ZZIncomingEventType)type
{
    return ZZIncomingEventTypeVideo;
}

@end

@implementation ZZMessageDomainModel (ZZPlaybackQueueItem)


- (NSTimeInterval)timestamp
{
    return self.messageID.doubleValue / 1000;
}

- (ZZIncomingEventType)type
{
    return ZZIncomingEventTypeMessage;
}

@end


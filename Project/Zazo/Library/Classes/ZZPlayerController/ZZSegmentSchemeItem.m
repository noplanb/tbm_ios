//
//  ZZSegmentSchemeItem.h
//  Zazo
//
//  Created by Server on 02/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZSegmentSchemeItem.h"

@implementation ZZVideoDomainModel (ZZSegmentSchemeItem)

- (NSTimeInterval)timestamp
{
    return self.videoID.doubleValue / 1000;
}

- (ZZIncomingEventType)type
{
    return ZZIncomingEventTypeVideo;
}

@end

@implementation ZZMessageDomainModel (ZZSegmentSchemeItem)


- (NSTimeInterval)timestamp
{
    return self.messageID.doubleValue;
}

- (ZZIncomingEventType)type
{
    return ZZIncomingEventTypeMessage;
}

@end


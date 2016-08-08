//
//  SegmentSchemeItem.h
//  Zazo
//
//  Created by Server on 02/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

@import Foundation;

#import "ZZVideoDomainModel.h"
#import "ZZMessageDomainModel.h"

@protocol ZZPlaybackQueueItem

- (NSTimeInterval)timestamp;
- (ZZIncomingEventType)type;

@end

@interface ZZVideoDomainModel (ZZPlaybackQueueItem) <ZZPlaybackQueueItem>

@end

@interface ZZMessageDomainModel (ZZPlaybackQueueItem) <ZZPlaybackQueueItem>

@end
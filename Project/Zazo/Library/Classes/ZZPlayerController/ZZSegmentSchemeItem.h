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

@protocol ZZSegmentSchemeItem

- (NSTimeInterval)timestamp;
- (ZZIncomingEventType)type;

@end

@interface ZZVideoDomainModel (ZZSegmentSchemeItem) <ZZSegmentSchemeItem>

@end

@interface ZZMessageDomainModel (ZZSegmentSchemeItem) <ZZSegmentSchemeItem>

@end
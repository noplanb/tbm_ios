//
//  ZZDebugStateDataSource.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/27/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZDebugStateCell.h"

@class ANMemoryStorage;
@class ZZDebugStateDomainModel;

typedef NS_ENUM(NSInteger, ZZDebugStateSections)
{
    ZZDebugStateSectionsIncomingVideos,
    ZZDebugStateSectionsOutgoingVideos,
    ZZDebugStateSectionsDandlingIncomingVideos,
    ZZDebugStateSectionsDandlingOutgoingVideos
};

@interface ZZDebugStateDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;

- (void)setupWithModel:(ZZDebugStateDomainModel*)model;

@end

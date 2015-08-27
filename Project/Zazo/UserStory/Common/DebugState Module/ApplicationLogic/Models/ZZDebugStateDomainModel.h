//
//  ZZDebugStateDomainModel.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/26/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ANBaseDomainModel.h"

@interface ZZDebugStateDomainModel : NSObject

@property (nonatomic, strong) NSArray* incomingVideosItemIDs;
@property (nonatomic, strong) NSArray* outgoingVideosItemIDs;

@property (nonatomic, strong) NSArray* incomingDanglingVideosItemIDs;
@property (nonatomic, strong) NSArray* outgoingDanglingVideosItemIDs;

@end

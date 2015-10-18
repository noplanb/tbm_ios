//
//  ZZDebugStateDomainModel.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/26/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ANBaseDomainModel.h"

@interface ZZDebugStateDomainModel : NSObject

@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* userID;

@property (nonatomic, strong) NSArray* incomingVideoItems;
@property (nonatomic, strong) NSArray* outgoingVideoItems;

@end

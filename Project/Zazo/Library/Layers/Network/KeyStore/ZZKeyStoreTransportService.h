//
//  ZZKeyStoreTransportService.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/2/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZKeyStoreTransportService : NSObject

+ (RACSignal*)getAllIncomingVideoIds;
+ (RACSignal*)getAllOutgoingVideoStatus;

@end

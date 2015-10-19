//
//  ZZKeyStoreTransportService.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/2/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@interface ZZKeyStoreTransportService : NSObject

+ (RACSignal*)updateKey1:(NSString*)key1 key2:(NSString*)key2 value:(NSString*)value;
+ (RACSignal*)deleteValueWithKey1:(NSString*)key1 key2:(NSString*)key2;
+ (RACSignal*)loadValueWithKey1:(NSString*)key1;

@end

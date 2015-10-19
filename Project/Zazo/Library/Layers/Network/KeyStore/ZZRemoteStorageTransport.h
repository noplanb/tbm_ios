//
//  ZZKeyStoreTransport.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/2/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@interface ZZRemoteStorageTransport : NSObject

+ (RACSignal*)updateKeyValueWithParameters:(NSDictionary*)parameters;
+ (RACSignal*)deleteKeyValueWithParameters:(NSDictionary*)parameters;
+ (RACSignal*)loadKeyValueWithParameters:(NSDictionary*)parameters;

@end

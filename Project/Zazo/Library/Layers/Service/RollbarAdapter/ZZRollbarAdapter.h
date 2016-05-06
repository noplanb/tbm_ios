//
//  ZZRollbarAdapter.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/18/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZRollbarConstants.h"

@interface ZZRollbarAdapter : NSObject

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, assign) ZZDispatchEndpoint endpointType;

+ (instancetype)shared;

- (void)updateUserFullName:(NSString *)fullName phone:(NSString *)phone itemID:(NSString *)itemID;

- (void)logMessage:(NSString *)message;

- (void)logMessage:(NSString *)message level:(ZZDispatchLevel)level;

@end

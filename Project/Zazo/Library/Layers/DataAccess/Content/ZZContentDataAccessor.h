//
//  ZZContentDataAcessor.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/1/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@import MagicalRecord;

@interface ZZContentDataAccessor : NSObject

+ (void)startWithCompletionBlock:(ANCodeBlock)completionBlock;
+ (void)saveDataBase;

+ (NSManagedObjectContext*)mainThreadContext;

+ (void)refreshContext:(NSManagedObjectContext*)context;

@end

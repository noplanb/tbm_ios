//
//  ZZContentDataAcessor.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/1/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@interface ZZContentDataAcessor : NSObject

+ (void)startWithCompletionBlock:(ANCodeBlock)completionBlock;
+ (void)saveDataBase;

+ (NSManagedObjectContext*)contextForCurrentThread;

+ (void)refreshContext:(NSManagedObjectContext*)context;

+ (void)removeAllUserData;

@end

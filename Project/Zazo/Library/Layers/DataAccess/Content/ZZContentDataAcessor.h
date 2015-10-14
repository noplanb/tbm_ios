//
//  ZZContentDataAcessor.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/1/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "MagicalRecord.h"

@interface ZZContentDataAcessor : NSObject

+ (void)start;
+ (void)saveDataBase;

+ (NSManagedObjectContext*)contextForCurrentThread;

+ (void)refreshContext:(NSManagedObjectContext*)context;

@end

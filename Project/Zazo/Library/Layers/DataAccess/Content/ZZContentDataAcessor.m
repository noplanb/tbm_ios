//
//  ZZContentDataAcessor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/1/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZContentDataAcessor.h"
#import "TBMFriend.h"

@implementation ZZContentDataAcessor

+ (void)start
{
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kContentDBName];
    if ([NSManagedObjectContext MR_rootSavingContext])
    {
        OB_INFO(@"Successfull Core Data migration. Trying to fill new fields"); // TODO: cleanup
        ANDispatchBlockToBackgroundQueue(^{
           [TBMFriend fillAfterMigration];
        });
    }
}

+ (void)saveDataBase
{
    [[self contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (NSManagedObjectContext *)contextForCurrentThread
{
    return [NSManagedObjectContext MR_contextForCurrentThread];
}
#pragma GCC diagnostic pop

@end









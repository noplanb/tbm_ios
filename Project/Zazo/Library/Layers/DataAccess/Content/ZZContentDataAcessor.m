//
//  ZZContentDataAcessor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/1/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZContentDataAcessor.h"
#import "MagicalRecord.h"
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
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

@end









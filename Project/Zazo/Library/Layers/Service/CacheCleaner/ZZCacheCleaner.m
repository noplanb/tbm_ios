//
// Created by Rinat on 13/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZCacheCleaner.h"

static NSString *ZZCacheCleaningNeededKeyName = @"ZZCacheCleaningNeededKeyName";

@interface ZZCacheCleaner ()

@property (nonatomic, assign) BOOL isCleaningNeeded;

@end

@implementation ZZCacheCleaner

@dynamic isCleaningNeeded;

+ (void)setNeedsCacheCleaning
{
    [self setIsCleaningNeeded:YES];
}

+ (void)cleanIfNeeded
{
    if ([self isCleaningNeeded])
    {
        [self setIsCleaningNeeded:NO];
        [self _clearCache];
    }
}

+ (void)_clearCache
{
    NSFileManager *manager = [NSFileManager defaultManager];

    NSString *cacheFolderPath =
            NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;

    NSArray <NSString *> *items;
    {
        NSError *error;

        items = [manager contentsOfDirectoryAtPath:cacheFolderPath error:&error];

        if (error)
        {
            ZZLogWarning(@"clearCache contentsOfDirectoryAtPath error: %@", error);
            return;
        }
    }

    NSMutableArray *deletedItems = [NSMutableArray new];

    [items enumerateObjectsUsingBlock:^(NSString *_Nonnull item, NSUInteger idx, BOOL *_Nonnull stop) {
        NSError *error;

        NSString *itemPath = [cacheFolderPath stringByAppendingPathComponent:item];

        if ([manager removeItemAtPath:itemPath error:&error])
        {
            [deletedItems addObject:item];
        }
        else if (error)
        {
            ZZLogWarning(@"clearCache removeItemAtPath error: %@", error);
        }
    }];

    ZZLogEvent(@"clearCache deleted %lu items : %@", (unsigned long)deletedItems.count, deletedItems);
}

+ (void)setIsCleaningNeeded:(BOOL)isCleaningNeeded
{
    [[NSUserDefaults standardUserDefaults] setBool:isCleaningNeeded forKey:ZZCacheCleaningNeededKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isCleaningNeeded
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:ZZCacheCleaningNeededKeyName];
}

@end
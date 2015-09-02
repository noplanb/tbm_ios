//
//  TBMGridElement.m
//  tbm
//
//  Created by Sani Elfishawy on 11/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMGridElement.h"
#import "MagicalRecord.h"

@implementation TBMGridElement

+ (instancetype)create
{
    return [self MR_createEntityInContext:[self _context]];
}

+ (instancetype)createInContext:(NSManagedObjectContext *)context
{
    return [self MR_createEntityInContext:context];
}


+ (void)destroyAll
{
    [self MR_truncateAllInContext:[self _context]];
    [[self _context] MR_saveToPersistentStoreAndWait];
}

+ (NSArray *)all
{
    return [self MR_findAllInContext:[self _context]];
}

+ (NSArray *)allSorted
{
    NSString* sortKey = TBMGridElementAttributes.index;
    return [TBMGridElement MR_findAllSortedBy:sortKey ascending:YES inContext:[self _context]];
}


+ (instancetype)findWithIntIndex:(NSInteger)index
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementAttributes.index, @(index)];
    return [[TBMGridElement MR_findAllWithPredicate:predicate inContext:[self _context]] firstObject];
}

+ (instancetype)findWithFriend:(TBMFriend *)friend
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementRelationships.friend, friend];
    return [[TBMGridElement MR_findAllWithPredicate:predicate inContext:[self _context]] firstObject];
}

+ (BOOL)friendIsOnGrid:(TBMFriend *)friend
{
    return [TBMGridElement findWithFriend:friend] != nil;
}

+ (instancetype)firstEmptyGridElement
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementRelationships.friend, nil];
    NSArray* result = [TBMGridElement MR_findAllSortedBy:TBMGridElementAttributes.index
                                               ascending:YES
                                           withPredicate:predicate
                                               inContext:[self _context]];
    
    TBMGridElement* entity = [result firstObject];
    return entity;
}

+ (BOOL)hasSentVideos:(NSUInteger)index
{
    TBMFriend *friend = [TBMGridElement findWithIntIndex:index].friend;
    return [friend hasOutgoingVideo];
}

- (void)setIntIndex:(NSInteger)index
{
    self.index = @(index);
}

- (NSInteger)getIntIndex
{
    return [self.index integerValue];
}


#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [NSManagedObjectContext MR_context];
}


@end

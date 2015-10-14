//
//  TBMGridElement.m
//  tbm
//
//  Created by Sani Elfishawy on 11/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMGridElement.h"
#import "MagicalRecord.h"
#import "ZZContentDataAcessor.h"

@implementation TBMGridElement

+ (TBMGridElement *)findWithIntIndex:(NSInteger)i
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementAttributes.index, @(i)];
    return [[TBMGridElement MR_findAllWithPredicate:predicate inContext:[self _context]] firstObject];
}

+ (TBMGridElement *)findWithFriend:(TBMFriend*)item
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementRelationships.friend, item];
    return [[TBMGridElement MR_findAllWithPredicate:predicate inContext:[self _context]] firstObject];
}

+ (BOOL)friendIsOnGrid:(TBMFriend *)friend
{
    return [TBMGridElement findWithFriend:friend] != nil;
}

+ (BOOL)hasSentVideos:(NSUInteger)index
{
    TBMFriend *friend = [TBMGridElement findWithIntIndex:index].friend;
    return [friend hasOutgoingVideo];
}


#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor contextForCurrentThread];
}


@end

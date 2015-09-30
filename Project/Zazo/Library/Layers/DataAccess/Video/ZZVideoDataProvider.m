//
//  ZZVideoDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoDataProvider.h"
#import "ZZVideoModelsMapper.h"
#import "ZZVideoDomainModel.h"
#import "TBMVideo.h"
#import "MagicalRecord.h"
#import "ZZVideoStatuses.h"
#import "ZZFriendDataProvider.h"

@implementation ZZVideoDataProvider

+ (TBMVideo*)entityFromModel:(ZZVideoDomainModel*)model
{
    TBMVideo* entity = [self entityWithID:model.videoID];
    if (!entity)
    {
        entity = [TBMVideo MR_createEntityInContext:[self _context]];
    }
    return [ZZVideoModelsMapper fillEntity:entity fromModel:model];
}

+ (ZZVideoDomainModel*)modelFromEntity:(TBMVideo*)entity
{
    return [ZZVideoModelsMapper fillModel:[ZZVideoDomainModel new] fromEntity:entity];
}


#pragma mark - CRUD

+ (void)deleteItem:(ZZVideoDomainModel*)model
{
    TBMVideo* entity = [self entityFromModel:model];
    [entity MR_deleteEntityInContext:[self _context]];
    
    [[self _context] MR_saveToPersistentStoreAndWait];
}

+ (ZZVideoDomainModel*)itemWithID:(NSString*)itemID
{
    ZZVideoDomainModel* model;
    if (!ANIsEmpty(itemID))
    {
        TBMVideo* entity = [[TBMVideo MR_findByAttribute:TBMVideoAttributes.videoId withValue:itemID inContext:[self _context]] firstObject];
        model = [self modelFromEntity:entity];
    }
    return model;
}

+ (TBMVideo*)entityWithID:(NSString*)itemID
{
    TBMVideo* item = nil;
    if (!ANIsEmpty(itemID))
    {
        NSArray* items = [TBMVideo MR_findByAttribute:TBMVideoAttributes.videoId withValue:itemID inContext:[self _context]];
        if (items.count > 1)
        {
            ANLogWarning(@"TBMVideo contains dupples for %@", itemID);
        }
        item = [items firstObject];
    }
    return item;
}


#pragma mark - Load

+ (NSArray*)loadUnviewedVideos
{
    NSArray* result = [TBMVideo MR_findByAttribute:TBMVideoAttributes.status
                                         withValue:@(ZZVideoIncomingStatusDownloaded)
                                         inContext:[self _context]];
    return [[result.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
}

+ (NSUInteger)countDownloadedUnviewedVideos
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoAttributes.status, @(ZZVideoIncomingStatusDownloaded)];
    return [TBMVideo MR_countOfEntitiesWithPredicate:predicate inContext:[self _context]];
}

+ (NSArray*)loadDownloadingVideos
{
    NSArray* result = [TBMVideo MR_findByAttribute:TBMVideoAttributes.status
                                         withValue:@(ZZVideoIncomingStatusDownloading)
                                         inContext:[self _context]];
    return [[result.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
}

+ (NSUInteger)countDownloadingVideos
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoAttributes.status, @(ZZVideoIncomingStatusDownloading)];
    return [TBMVideo MR_countOfEntitiesWithPredicate:predicate inContext:[self _context]];
}

+ (NSUInteger)countTotalUnviewedVideos
{
    return [self countDownloadingVideos] + [self countDownloadedUnviewedVideos];
}

+ (NSArray*)loadAllVideos
{
    NSArray* result = [TBMVideo MR_findAllInContext:[self _context]];
    
    return [[result.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
}

+ (NSUInteger)countAllVideos
{
    return [TBMVideo MR_countOfEntitiesWithContext:[self _context]];
}

+ (NSArray*)sortedIncomingVideosForUser:(ZZFriendDomainModel*)friendModel
{
    TBMFriend* friendEntity = [ZZFriendDataProvider entityFromModel:friendModel];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoRelationships.friend, friendEntity];
    NSArray* videos = [TBMVideo MR_findAllSortedBy:TBMVideoAttributes.videoId ascending:YES withPredicate:predicate inContext:[self _context]];
    
    return [[videos.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
}


#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [NSManagedObjectContext MR_rootSavingContext];
}

@end

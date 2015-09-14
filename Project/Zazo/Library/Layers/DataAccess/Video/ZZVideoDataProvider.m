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
#import "NSManagedObject+ANAdditions.h"
#import "MagicalRecord.h"
#import "ZZVideoStatuses.h"

@implementation ZZVideoDataProvider

+ (TBMVideo*)entityFromModel:(ZZVideoDomainModel*)model
{
    TBMVideo* entity = [TBMVideo an_objectWithItemID:model.idTbm context:[self _context]];
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


#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [NSManagedObjectContext MR_rootSavingContext];
}

@end

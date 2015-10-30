//
//  ZZVideoDataUpdater.m
//  Zazo
//
//  Created by ANODA on 10/28/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoDataUpdater.h"
#import "TBMVideo.h"
#import "MagicalRecord.h"
#import "ZZVideoDataProvider.h"
#import "ZZThumbnailGenerator.h"
#import "ZZVideoDomainModel.h"
#import "ZZVideoModelsMapper.h"
#import "ZZContentDataAcessor.h"

@implementation ZZVideoDataUpdater

//+ (void)deleteItem:(ZZVideoDomainModel*)model
//{
//    TBMVideo* entity = [self entityFromModel:model];
//    [entity MR_deleteEntityInContext:[self _context]];
//
//    [[self _context] MR_saveToPersistentStoreAndWait];
//}

//+ (TBMVideo*)entityWithID:(NSString*)itemID
//{
//    TBMVideo* item = nil;
//    if (!ANIsEmpty(itemID))
//    {
//        NSArray* items = [TBMVideo MR_findByAttribute:TBMVideoAttributes.videoId withValue:itemID inContext:[self _context]];
//        if (items.count > 1)
//        {
//            ANLogWarning(@"TBMVideo contains dupples for %@", itemID);
//        }
//        item = [items firstObject];
//    }
//    return item;
//}

+ (void)destroy:(TBMVideo *)video
{
    NSManagedObjectContext* context = video.managedObjectContext;
    [video MR_deleteEntity];
    [context MR_saveToPersistentStoreAndWait];
}


+ (void)deleteVideoFileWithVideo:(TBMVideo*)video
{
    ZZLogInfo(@"deleteVideoFile");
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    [fm removeItemAtURL:[ZZVideoDataProvider videoUrlWithVideo:video] error:&error];
}

+ (void)deleteFilesForVideo:(TBMVideo*)video
{
    [self deleteVideoFileWithVideo:video];
    ZZVideoDomainModel* videoModel = [ZZVideoDataProvider modelFromEntity:video];
    [ZZThumbnailGenerator deleteThumbFileForVideo:videoModel];
}

//+ (TBMVideo*)entityFromModel:(ZZVideoDomainModel*)model
//{
//    TBMVideo* entity = [ZZVideoDataProvider entityWithID:model.videoID];
//    if (!entity)
//    {
//        entity = [TBMVideo MR_createEntityInContext:[self _context]];
//    }
//    return [ZZVideoModelsMapper fillEntity:entity fromModel:model];
//}


#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor contextForCurrentThread];
}


@end

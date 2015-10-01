//
//  TBMVideo.m
//  tbm
//
//  Created by Sani Elfishawy on 8/5/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "AVFoundation/AVFoundation.h"

#import "TBMVideo.h"
#import "TBMFriend.h"
#import "TBMAppDelegate.h"
#import "OBLogger.h"
#import "MagicalRecord.h"
#import "ZZVideoDataProvider.h"
#import "ZZThumbnailGenerator.h"

@implementation TBMVideo

+ (NSManagedObjectContext*)_context
{
    return [NSManagedObjectContext MR_rootSavingContext];
}

//-------------------
// Create and destroy
//-------------------
+ (instancetype)createOncontext:(NSManagedObjectContext*)context // TODO: dangerous
{
    TBMVideo* video = [self MR_createEntityInContext:context];
    video.downloadRetryCount = @(0);
    video.status = INCOMING_VIDEO_STATUS_NEW;
    [video.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    return video;
}

+ (instancetype)newWithVideoId:(NSString *)videoId onContext:(NSManagedObjectContext *)context
{
    __block TBMVideo *video = nil;
    ANDispatchBlockToMainQueue(^{
        video = [TBMVideo createOncontext:context];
        video.videoId = videoId;
        [video.managedObjectContext MR_saveToPersistentStoreAndWait];
    });
    return video;
}

+ (void)destroy:(TBMVideo *)video
{
    NSManagedObjectContext* context = video.managedObjectContext;
    [video MR_deleteEntity];
    [context MR_saveToPersistentStoreAndWait];
}

//--------
// Finders
//--------

+ (instancetype)findWithVideoId:(NSString *)videoId
{
    return [self findWithAttributeKey:@"videoId" value:videoId];
}


+ (instancetype)findWithAttributeKey:(NSString *)key value:(id)value
{
    return [[self findAllWithAttributeKey:key value:value] lastObject];
}

+ (NSArray *)findAllWithAttributeKey:(NSString *)key value:(id)value
{
    return [self MR_findByAttribute:key withValue:value];
}

+ (NSArray *)downloadedUnviewed
{
    return [TBMVideo findAllWithAttributeKey:@"status" value:[NSNumber numberWithInt:INCOMING_VIDEO_STATUS_DOWNLOADED]];
}

+ (NSUInteger)downloadedUnviewedCount
{
    return [[TBMVideo downloadedUnviewed] count];
}

+ (NSArray *)downloading
{
    return [TBMVideo findAllWithAttributeKey:@"status" value:[NSNumber numberWithInt:INCOMING_VIDEO_STATUS_DOWNLOADING]];
}

+ (NSUInteger)downloadingCount
{
    return [[TBMVideo downloading] count];
}
+ (NSUInteger)unviewedCount
{
    return [TBMVideo downloadedUnviewedCount] + [TBMVideo downloadingCount];
}

+ (NSArray *)all
{
    return [self MR_findAllInContext:[self _context]];
}

+ (NSUInteger)count
{
    return [self MR_countOfEntitiesWithContext:[self _context]];
}

+ (void)printAll
{
    OB_INFO(@"All Videos (%lu)", (unsigned long)[TBMVideo count]);
    for (TBMVideo * v in [TBMVideo all]){
        OB_INFO(@"%@ %@ status=%@", v.friend.firstName, v.videoId, v.status);
    }
}

//=================
// Instance methods
//=================

- (void)deleteFiles
{
    [self deleteVideoFile];
    ZZVideoDomainModel* videoModel = [ZZVideoDataProvider modelFromEntity:self];
    [ZZThumbnailGenerator deleteThumbFileForVideo:videoModel];
}

//----------------
// Video URL stuff
//----------------
- (NSURL *)videoUrl{
    NSString *filename = [NSString stringWithFormat:@"incomingVidFromFriend_%@-VideoId_%@", self.friend.idTbm, self.videoId];
     NSURL* videosURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [videosURL URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mp4"]];
}

- (NSString *)videoPath{
    return [self videoUrl].path;
}

- (BOOL)videoFileExists{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self videoPath]];
}

- (unsigned long long)videoFileSize{
    if (![self videoFileExists])
        return 0;
    
    NSError *error;
    NSDictionary *fa = [[NSFileManager defaultManager] attributesOfItemAtPath:[self videoPath] error:&error];
    if (error)
        return 0;
    
    return fa.fileSize;
}

- (BOOL) hasValidVideoFile{
    return [self videoFileSize] > 0;
}

- (void)deleteVideoFile{
    DebugLog(@"deleteVideoFile");
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    [fm removeItemAtURL:[self videoUrl] error:&error];
}


//---------------------------
// Status convenience methods
//---------------------------
- (BOOL)isStatusDownloading
{
    return (self.statusValue == INCOMING_VIDEO_STATUS_DOWNLOADING);
}


+ (NSString *)nameForStatus:(TBMIncomingVideoStatus)status
{
    NSString *name = @"UNKNOWN";
    switch (status) {
        case INCOMING_VIDEO_STATUS_NEW:
            name = @"NEW";
            break;
        case INCOMING_VIDEO_STATUS_DOWNLOADING:
            name = @"DOWNLOADING";
            break;
        case INCOMING_VIDEO_STATUS_DOWNLOADED:
            name = @"DOWNLOADED";
            break;
        case INCOMING_VIDEO_STATUS_VIEWED:
            name = @"VIEWED";
            break;
        case INCOMING_VIDEO_STATUS_FAILED_PERMANENTLY:
            name = @"PERMANENTLY";
            break;
    }
    return name;
}

- (NSString *)statusName
{
    return [TBMVideo nameForStatus:self.statusValue];
}

@end

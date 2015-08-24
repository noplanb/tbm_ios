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
#import "TBMConfig.h"
#import "OBLogger.h"


@implementation TBMVideo

@dynamic status;
@dynamic videoId;
@dynamic friend;
@dynamic downloadRetryCount;


//==============
// Class methods
//==============
+ (TBMAppDelegate *)appDelegate{
    return [[UIApplication sharedApplication] delegate];
}

+ (NSManagedObjectContext *)managedObjectContext{
    return [[TBMVideo appDelegate] managedObjectContext];
}

+ (NSEntityDescription *)entityDescription{
    return [NSEntityDescription entityForName:@"TBMVideo" inManagedObjectContext:[TBMVideo managedObjectContext]];
}


//-------------------
// Create and destroy
//-------------------
+ (instancetype)new{
    __block TBMVideo *video;
    [[TBMVideo managedObjectContext] performBlockAndWait:^{
        video = (TBMVideo *)[[NSManagedObject alloc] initWithEntity:[TBMVideo entityDescription] insertIntoManagedObjectContext:[TBMVideo managedObjectContext]];
        video.downloadRetryCount = [NSNumber numberWithInt:0];
        video.status = INCOMING_VIDEO_STATUS_NEW;
    }];
    return video;
}

+ (instancetype) newWithVideoId:(NSString *)videoId{
    TBMVideo *video = [TBMVideo new];
    video.videoId = videoId;
    return video;
}

+ (void) destroy:(TBMVideo *)video{
    [[TBMVideo managedObjectContext] performBlockAndWait:^{
        [[TBMVideo managedObjectContext] deleteObject:video];
    }];
}

//--------
// Finders
//--------
+ (NSFetchRequest *)fetchRequest{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[TBMVideo entityDescription]];
    return request;
}

+ (instancetype)findWithVideoId:(NSString *)videoId{
    return [self findWithAttributeKey:@"videoId" value:videoId];
}


+ (instancetype)findWithAttributeKey:(NSString *)key value:(id)value{
    return [[self findAllWithAttributeKey:key value:value] lastObject];
}

+ (NSArray *)findAllWithAttributeKey:(NSString *)key value:(id)value{
    __block NSArray *result;
    __block NSError *error = nil;
    [[TBMVideo managedObjectContext] performBlockAndWait:^{
        NSFetchRequest *request = [TBMVideo fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, value];
        [request setPredicate:predicate];
        result =  [[TBMVideo managedObjectContext] executeFetchRequest:request error:&error];
    }];
    return result;
}

+ (NSArray *)downloadedUnviewed{
    return [TBMVideo findAllWithAttributeKey:@"status" value:[NSNumber numberWithInt:INCOMING_VIDEO_STATUS_DOWNLOADED]];
}

+ (NSUInteger)downloadedUnviewedCount{
    return [[TBMVideo downloadedUnviewed] count];
}

+ (NSArray *)downloading{
    return [TBMVideo findAllWithAttributeKey:@"status" value:[NSNumber numberWithInt:INCOMING_VIDEO_STATUS_DOWNLOADING]];
}

+ (NSUInteger)downloadingCount{
    return [[TBMVideo downloading] count];
}
+ (NSUInteger)unviewedCount{
    return [TBMVideo downloadedUnviewedCount] + [TBMVideo downloadingCount];
}

+ (NSArray *)all{
    __block NSError *error;
    __block NSArray *result;
    [[TBMVideo managedObjectContext] performBlockAndWait:^{
        [[TBMVideo managedObjectContext] executeFetchRequest:[TBMVideo fetchRequest] error:&error];
    }];
    return result;
}

+ (NSUInteger)count{
    return [[TBMVideo all] count];
}

+ (void)printAll{
    OB_INFO(@"All Videos (%lu)", (unsigned long)[TBMVideo count]);
    for (TBMVideo * v in [TBMVideo all]){
        OB_INFO(@"%@ %@ status=%ld", v.friend.firstName, v.videoId, v.status);
    }
}

//=================
// Instance methods
//=================

- (void) deleteFiles{
    [self deleteVideoFile];
    [self deleteThumbFile];
}

//----------------
// Video URL stuff
//----------------
- (NSURL *)videoUrl{
    NSString *filename = [NSString stringWithFormat:@"incomingVidFromFriend_%@-VideoId_%@", self.friend.idTbm, self.videoId];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mp4"]];
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


//----------------
// Thumb URL stuff
//----------------
- (NSURL *)thumbUrl{
    NSString *filename = [NSString stringWithFormat:@"thumbFromFriend_%@-VideoId_%@", self.friend.idTbm, self.videoId];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"png"]];
}

- (NSString *)thumbPath{
    return [self thumbUrl].path;
}

- (BOOL)hasThumb{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self thumbPath]];
}

- (BOOL)generateThumb{
    DebugLog(@"generateThumb vid: %@ for %@",self.videoId, self.friend.firstName);
    if (![self hasValidVideoFile]){
        OB_ERROR(@"generateThumb: vid: %@ !hasValidVideoFile", self.videoId);
        return NO;
    }
    
    AVAsset *asset = [AVAsset assetWithURL:[self videoUrl]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime duration = asset.duration;
    CMTime secondsFromEnd = CMTimeMake(2, 1);
    CMTime thumbTime = CMTimeSubtract(duration, secondsFromEnd);
    CMTime actual;
    NSError *err = nil;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbTime actualTime:&actual error:&err];
    if (err != nil){
        OB_ERROR(@"generateThumb: %@", err);
        return NO;
    }
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    [UIImagePNGRepresentation(thumbnail) writeToURL:[self thumbUrl] atomically:YES];
    return YES;
}

- (void)deleteThumbFile{
    DebugLog(@"deleteThumbFile");
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    [fm removeItemAtURL:[self thumbUrl] error:&error];
}

//---------------------------
// Status convenience methods
//---------------------------
- (BOOL)isStatusDownloading{
    return self.status == INCOMING_VIDEO_STATUS_DOWNLOADING;
}

+ (NSString *)nameForStatus:(TBMIncomingVideoStatus)status {
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

- (NSString *)statusName {
    return [TBMVideo nameForStatus:self.status];
}

@end

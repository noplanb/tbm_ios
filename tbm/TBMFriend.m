//
//  Friend.m
//  tbm
//
//  Created by Sani Elfishawy on 4/26/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "AVFoundation/AVFoundation.h"

#import "TBMFriend.h"
#import "TBMAppDelegate.h"
#import "TBMConfig.h"
#import "TBMUser.h"
#import "TBMStringUtils.h"
#import "TBMDownloadManager.h"
#import "TBMVideoIdUtils.h"

#import "TBMHomeViewController.h"
@implementation TBMFriend

@dynamic firstName;
@dynamic lastName;
@dynamic outgoingVideoStatus;
@dynamic incomingVideoStatus;
@dynamic outgoingVideoId;
@dynamic lastOutgoingVideoId;
@dynamic incomingVideoId;
@dynamic lastVideoStatusEventType;
@dynamic viewIndex;
@dynamic uploadRetryCount;
@dynamic downloadRetryCount;
@dynamic idTbm;

static NSMutableArray * videoStatusNotificationDelegates;

//==============
// Class methods
//==============
+ (TBMAppDelegate *)appDelegate{
    return [[UIApplication sharedApplication] delegate];
}

+ (NSManagedObjectContext *)managedObjectContext{
    return [[TBMFriend appDelegate] managedObjectContext];
}

+ (NSEntityDescription *)entityDescription{
    return [NSEntityDescription entityForName:@"TBMFriend" inManagedObjectContext:[TBMFriend managedObjectContext]];
}


//--------
// Finders
//--------
+ (NSFetchRequest *)fetchRequest{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[TBMFriend entityDescription]];
    return request;
}

+ (NSArray *)all{
    NSError *error;
    return [[TBMFriend managedObjectContext] executeFetchRequest:[TBMFriend fetchRequest] error:&error];
}

+ (NSMutableArray *)whereUploadPendingRetry{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (TBMFriend *friend in [TBMFriend all]){
        if ([friend hasUploadPendingRetry])
            [result addObject:friend];
    }
    return result;
}

+ (NSMutableArray *)whereDownloadPendingRetry{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (TBMFriend *friend in [TBMFriend all]){
        if ([friend hasDownloadPendingRetry])
            [result addObject:friend];
    }
    return result;
}

+ (instancetype)findWithIncomingVideoId:(NSString *)videoId{
    return [self findWithAttributeKey:@"incomingVideoId" value:videoId];
}

+ (instancetype)findWithId:(NSString *)idTbm{
    return [self findWithAttributeKey:@"idTbm" value:idTbm];
}

+ (instancetype)findWithViewIndex:(NSNumber *)viewIndex{
    return [self findWithAttributeKey:@"viewIndex" value:viewIndex];
}

+ (instancetype)findWithAttributeKey:(NSString *)key value:(id)value{
    return [[self findAllWithAttributeKey:key value:value] lastObject];
}

+ (NSArray *)findAllWithAttributeKey:(NSString *)key value:(id)value{
    NSFetchRequest *request = [TBMFriend fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, value];
    [request setPredicate:predicate];
    NSError *error = nil;
    return [[TBMFriend managedObjectContext] executeFetchRequest:request error:&error];
}

+ (NSUInteger)count{
    return [[TBMFriend all] count];
}

+ (int)unviewedCount{
    return [[self findAllWithAttributeKey:@"incomingVideoStatus" value:[NSNumber numberWithInt:INCOMING_VIDEO_STATUS_DOWNLOADED]] count];
}

//-------------------
// Create and destroy
//-------------------
+ (id)newWithId:(NSString *)idTbm
{
    TBMFriend *friend = (TBMFriend *)[[NSManagedObject alloc] initWithEntity:[TBMFriend entityDescription] insertIntoManagedObjectContext:[TBMFriend managedObjectContext]];
    friend.idTbm = idTbm;
    [TBMFriend saveAll];
    return friend;
}

+ (NSUInteger)destroyAll
{
    NSArray *allFriends = [TBMFriend all];
    NSUInteger count = [allFriends count];
    for (TBMFriend *friend in allFriends) {
        [[TBMFriend managedObjectContext] deleteObject:friend];
    }
    return count;
}

+ (void)destroyWithId:(NSString *)idTbm
{
    TBMFriend *friend = [TBMFriend findWithId:idTbm];
    if ( friend != nil ){
        [[TBMFriend managedObjectContext] deleteObject:friend];
    }
}

+ (void)saveAll{
    [[self appDelegate] saveContext];
}

//=================
// Instance methods
//=================

//----------------
// Video URL stuff
//----------------
- (NSURL *)incomingVideoUrl{
    NSString *filename = [NSString stringWithFormat:@"incomingVidFromFriend%@", self.idTbm];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mp4"]];
}

- (NSString *)incomingVideoPath{
    return [self incomingVideoUrl].path;
}

- (BOOL)incomingVideoFileExists{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self incomingVideoPath]];
}

- (unsigned long long)incomingVideoFileSize{
    if (![self incomingVideoFileExists])
        return 0;
    
    NSError *error;
    NSDictionary *fa = [[NSFileManager defaultManager] attributesOfItemAtPath:[self incomingVideoPath] error:&error];
    if (error)
        return 0;
    
    return fa.fileSize;
}

- (BOOL) hasValidIncomingVideoFile{
    return [self incomingVideoFileSize] > 0;
}

- (void)deleteIncomingVideo{
    DebugLog(@"deleteIncomingVideo");
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    [fm removeItemAtURL:[self incomingVideoUrl] error:&error];
}


- (void)loadIncomingVideoWithUrl:(NSURL *)location{
    DebugLog(@"loadIncomingVideoWithUrl for %@", self.firstName);
    [self deleteIncomingVideo];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    DebugLog(@"moveIncomingVideo");
    [fm moveItemAtURL:location toURL:[self incomingVideoUrl] error:&error];
    if (error){
        DebugLog(@"loadIncomingVideoWithUrl: ERROR. This should never occur");
        return;
    }
    NSDictionary *fa = [fm attributesOfItemAtPath:[self incomingVideoPath] error:&error];
    DebugLog(@"Incoming video %@ size = %lld", [self incomingVideoPath], fa.fileSize);
    [self generateThumb];
}


//----------------
// Thumb URL stuff
//----------------
- (NSURL *)thumbUrl{
    NSString *filename = [NSString stringWithFormat:@"thumbFromFriend%@", self.idTbm];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"png"]];
}

- (NSString *)thumbPath{
    return [self thumbUrl].path;
}

- (BOOL)hasThumb{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self thumbPath]];
}

- (void)generateThumb{
    DebugLog(@"generateThumb for %@", self.firstName);
    if (![self hasValidIncomingVideoFile])
        return;
    
    AVAsset *asset = [AVAsset assetWithURL:[self incomingVideoUrl]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMake(1, 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    [UIImagePNGRepresentation(thumbnail) writeToURL:[self thumbUrl] atomically:YES];
}

- (NSURL *)thumbUrlOrThumbMissingUrl{
    if ([self hasThumb]) {
        return [self thumbUrl];
    } else {
        return [TBMConfig thumbMissingUrl];
    }
}

- (UIImage *)thumbImageOrThumbMissingImage{
    return [UIImage imageWithContentsOfFile:[self thumbUrlOrThumbMissingUrl].path];
}

//-------------
// VideoStatus
//-------------
// I just could not get KVO to work reliably on attributes of a managedModel.
// So I rolled my own notification registry.
// In hindsight I should have probably used the NSNotificationCenter for this rather than rolling my own.

+ (void)addVideoStatusNotificationDelegate:(id)delegate{
    if (!videoStatusNotificationDelegates) {
        videoStatusNotificationDelegates = [[NSMutableArray alloc] init];
    }
    [TBMFriend removeVideoStatusNotificationDelegate:delegate];
    [videoStatusNotificationDelegates addObject:delegate];
}

+ (void)removeVideoStatusNotificationDelegate:(id)delegate{
    [videoStatusNotificationDelegates removeObject:delegate];
}

- (void)notifyVideoStatusChangeOnMainThread{
    DebugLog(@"notifyVideoStatusChangeOnMainThread");
    [self performSelectorOnMainThread:@selector(notifyVideoStatusChange) withObject:nil waitUntilDone:YES];
}

- (void)notifyVideoStatusChange{
    DebugLog(@"notifyVideoStatusChange for %@ on %lu delegates", self.firstName, (unsigned long)[videoStatusNotificationDelegates count]);
    for (id<TBMVideoStatusNotoficationProtocol> delegate in videoStatusNotificationDelegates){
        [delegate videoStatusDidChange:self];
    }
}

- (NSString *)videoStatusString{
    if (self.lastVideoStatusEventType == OUTGOING_VIDEO_STATUS_EVENT_TYPE) {
        return [self outgoingVideoStatusString];
    } else {
        return [self incomingVideoStatusString];
    }
}

- (NSString *)incomingVideoStatusString{
    if (self.incomingVideoStatus == INCOMING_VIDEO_STATUS_DOWNLOADING){
        if ([self.downloadRetryCount intValue] == 0){
            return @"Downloading...";
        } else {
            return [NSString stringWithFormat:@"Downloading r%@", self.downloadRetryCount];
        }
    } else {
        return self.firstName;
    }
}

- (NSString *)outgoingVideoStatusString{
    NSString *statusString;
    switch (self.outgoingVideoStatus) {
        case OUTGOING_VIDEO_STATUS_NEW:
            statusString = nil;
            break;
        case OUTGOING_VIDEO_STATUS_UPLOADING:
            if ([self getUploadRetryCount] == 0) {
                statusString = @"p...";
            } else {
                statusString = [NSString stringWithFormat:@"r%lu...", (long)[self getUploadRetryCount]];
            }
            break;
        case OUTGOING_VIDEO_STATUS_UPLOADED:
            statusString = @".s..";
            break;
        case OUTGOING_VIDEO_STATUS_DOWNLOADED:
            statusString = @"..p.";
            break;
        case OUTGOING_VIDEO_STATUS_VIEWED:
            statusString = @"v!";
            break;
        default:
            statusString = nil;
    }
    
    NSString *fn = (!statusString || self.outgoingVideoStatus == OUTGOING_VIDEO_STATUS_VIEWED) ? self.firstName : [self shortFirstName];
    return [NSString stringWithFormat:@"%@ %@", fn, statusString];
}

- (NSString *)shortFirstName{
    return [self.firstName substringWithRange:NSMakeRange(0, MIN(6, [self.firstName length]))];
}

- (void)setAndNotifyOutgoingVideoStatus:(TBMOutgoingVideoStatus)newStatus{
    if (newStatus != self.outgoingVideoStatus){
        self.lastVideoStatusEventType = OUTGOING_VIDEO_STATUS_EVENT_TYPE;
        self.outgoingVideoStatus = newStatus;
        [self notifyVideoStatusChangeOnMainThread];
    }
}

- (void)setAndNotifyIncomingVideoStatus:(TBMIncomingVideoStatus)newStatus{
    DebugLog(@"setAndNotifyIncomingVideoStatus for %@", self.firstName);
    if (newStatus != self.incomingVideoStatus){
        self.lastVideoStatusEventType = INCOMING_VIDEO_STATUS_EVENT_TYPE;
        self.incomingVideoStatus = newStatus;
        [self notifyVideoStatusChangeOnMainThread];
    }
}

- (void)setIncomingViewed{
    [self setAndNotifyIncomingVideoStatus:INCOMING_VIDEO_STATUS_VIEWED];
    [TBMFriend saveAll];
}


// ------------
// Retry Counts
// ------------

// UPLOADING
- (void)setUploadRetryCountWithInteger:(NSInteger)count{
    [self setAndNotifyUploadRetryCount:[NSNumber numberWithInteger:count]];
}

- (NSInteger)getUploadRetryCount{
    return [self.uploadRetryCount integerValue];
}

- (void)incrementUploadRetryCount{
    NSInteger count = [self getUploadRetryCount] + 1;
    [self setUploadRetryCountWithInteger:count];
}

- (BOOL)hasUploadPendingRetry{
    return self.outgoingVideoStatus == OUTGOING_VIDEO_STATUS_UPLOADING && [self getUploadRetryCount] > 0;
}


- (void)setAndNotifyUploadRetryCount:(NSNumber *)newRetryCount{
    if (newRetryCount != self.uploadRetryCount){
        self.uploadRetryCount = newRetryCount;
        [self notifyVideoStatusChangeOnMainThread];
    }
}

// DOWNLOADING
- (void)setDownloadRetryCountWithInteger:(NSInteger)count{
    [self setAndNotifyDownloadRetryCount:[NSNumber numberWithInteger:count]];
}

- (NSInteger)getDownloadRetryCount{
    return [self.downloadRetryCount integerValue];
}

- (void)incrementDownloadRetryCount{
    NSInteger count = [self getDownloadRetryCount] + 1;
    [self setDownloadRetryCountWithInteger:count];
}

- (BOOL)hasDownloadPendingRetry{
    return self.incomingVideoStatus == INCOMING_VIDEO_STATUS_DOWNLOADING && [self getDownloadRetryCount] > 0;
}


- (void)setAndNotifyDownloadRetryCount:(NSNumber *)newRetryCount{
    if (newRetryCount != self.downloadRetryCount){
        self.downloadRetryCount = newRetryCount;
        [self notifyVideoStatusChangeOnMainThread];
    }
}


// --------------------------------
// Adjust status for various events
// --------------------------------
- (void)handleAfterOutgoingVideoCreated{
    [self setUploadRetryCountWithInteger:0];
    [self setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_NEW];
    [self generateAndSetOutgoingVideoId];
    [TBMFriend saveAll];
}

// -------------
// videoId stuff
// -------------

- (void)generateAndSetOutgoingVideoId{
    self.lastOutgoingVideoId = self.outgoingVideoId;
    self.outgoingVideoId = [TBMVideoIdUtils generateOutgoingVideoIdWithFriend:self];
}


// --------------
// Download stuff
// --------------

- (void)addToDownloadQueueWithVideoId:(NSString *)videoId{
    if ([videoId isEqual:self.incomingVideoId]) {
        DebugLog(@"addToDownloadQueueWithVideoId: Ignoring duplicate request for id:%@", videoId);
        return;
    }
    self.incomingVideoId = videoId;
    [[TBMDownloadManager sharedManager] fileTransferWithFriendId:self.idTbm];
}

@end

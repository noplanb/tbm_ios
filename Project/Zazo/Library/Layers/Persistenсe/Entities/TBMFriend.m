
//
//  TBMFriend.m
//  tbm
//
//  Created by Sani Elfishawy on 8/18/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMFriend.h"
#import "TBMVideoIdUtils.h"
#import "MagicalRecord.h"
#import "TBMGridElement.h"
#import "ZZUserPresentationHelper.h"
#import "ZZContentDataAcessor.h"
#import "ZZPhoneHelper.h"
#import "ZZVideoDataProvider.h"
#import "ZZVideoDataUpdater.h"
#import "ZZApplicationRootService.h"
#import "ZZNotificationsConstants.h"

@implementation TBMFriend

static NSMutableSet *videoStatusNotificationDelegates;

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor contextForCurrentThread];
}

+ (NSArray *)all
{
    return [self MR_findAllInContext:[self _context]];
}
//
//+ (NSUInteger)allUnviewedCount
//{
//    NSUInteger result = 0;
//    for (TBMFriend *friend in [self all])
//    {
//        result += friend.unviewedCount;
//    }
//    return result;
//}


+ (instancetype)findWithId:(NSString *)idTbm
{
    return [self findWithAttributeKey:@"idTbm" value:idTbm];
}

+ (instancetype)findWithMkey:(NSString *)mkey
{
    return [self findWithAttributeKey:@"mkey" value:mkey];
}

+ (instancetype)findWithAttributeKey:(NSString *)key value:(id)value
{
    return [[self findAllWithAttributeKey:key value:value] lastObject];
}

+ (NSArray *)findAllWithAttributeKey:(NSString *)key value:(id)value
{
    return [self MR_findByAttribute:key withValue:value inContext:[self _context]];
}

+ (NSUInteger)count
{
    return [self MR_countOfEntitiesWithContext:[self _context]];
}


//-----------
// UI helpers
//-----------
- (NSString *)displayName
{
    int maxLength = 100;
    NSString *d;

    if ([self firstNameIsUnique])
        d = self.firstName;
    else
        d = [NSString stringWithFormat:@"%@. %@", [self firstInitial], self.lastName];

    // Limit to 12 characgters
    if (d.length > maxLength)
        d = [d substringWithRange:NSMakeRange(0, maxLength - 1)];

    return d;
}

- (BOOL)firstNameIsUnique
{
    for (TBMFriend *f in [TBMFriend all])
    {
        if (![self isEqual:f] && [self.firstName isEqualToString:f.firstName])
            return NO;
    }
    return YES;
}

- (NSString *)firstInitial
{
    return [self.firstName substringToIndex:1];
}

//----------------
// Incoming Videos
//----------------
#pragma mark Incoming Videos

- (NSArray *)sortedIncomingVideos
{
    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:@"videoId" ascending:YES];
    return [self.videos sortedArrayUsingDescriptors:@[d]];
}

- (TBMVideo *)newestIncomingVideo
{
    return [[self sortedIncomingVideos] lastObject];
}

- (BOOL)hasIncomingVideoId:(NSString*)videoId
{
    NSArray* videos = [self.videos.allObjects copy];
    for (TBMVideo *v in videos)
    {
        if ([v.videoId isEqualToString:videoId])
            return true;
    }
    return false;
}

- (BOOL)isNewestIncomingVideo:(TBMVideo *)video
{
    return [video isEqual:[self newestIncomingVideo]];
}

- (TBMVideo *)createIncomingVideoWithVideoId:(NSString *)videoId   
{
    TBMVideo *video = [ZZVideoDataProvider newWithVideoId:videoId onContext:self.managedObjectContext];;
    [self addVideosObject:video];
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    return video;
}

- (void)deleteAllViewedOrFailedVideos
{
    ZZLogInfo(@"deleteAllViewedVideos");
    NSArray *all = [self sortedIncomingVideos];
    for (TBMVideo *v in all)
    {
        if (v.statusValue == ZZVideoIncomingStatusViewed ||
            v.statusValue == ZZVideoIncomingStatusFailedPermanently)
        {
            [self deleteVideo:v];
        }
    }
}

- (void)deleteVideo:(TBMVideo*)video
{
    [ZZVideoDataUpdater deleteFilesForVideo:video];
    [self removeVideosObject:video];
    [ZZVideoDataUpdater destroy:video];
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
}

//- (TBMVideo *)firstPlayableVideo
//{
//    TBMVideo *video = nil;
//    for (TBMVideo *v in [self sortedIncomingVideos])
//    {
//        if ([ZZVideoDataProvider videoFileExistsForVideo:v])
//        {
//            video = v;
//            break;
//        }
//    }
//    return video;
//}
//
//- (TBMVideo *)nextPlayableVideoAfterVideoId:(NSString *)videoId
//{
//    for (TBMVideo *v in [self sortedIncomingVideos])
//    {
//        if ([TBMVideoIdUtils isvid1:v.videoId newerThanVid2:videoId] && [ZZVideoDataProvider videoFileExistsForVideo:v])
//            return v;
//    }
//    return nil;
//}

//- (TBMVideo *)firstUnviewedVideo
//{
//    TBMVideo *video = nil;
//    for (TBMVideo *v in [self sortedIncomingVideos])
//    {
//        if (v.statusValue == ZZVideoIncomingStatusDownloaded && [ZZVideoDataProvider videoFileExistsForVideo:v])
//        {
//            video = v;
//            break;
//        }
//    }
//    return video;
//}

- (TBMVideo *)nextUnviewedVideoAfterVideoId:(NSString *)videoId
{
    for (TBMVideo *v in [self sortedIncomingVideos])
    {
        if ([TBMVideoIdUtils isvid1:v.videoId newerThanVid2:videoId] && [ZZVideoDataProvider videoFileExistsForVideo:v] && v.statusValue == ZZVideoIncomingStatusDownloaded)
            return v;
    }
    return nil;
}

- (NSInteger)unviewedCount
{
    NSInteger i = 0;
    for (TBMVideo *v in [self videos])
    {
        if (v.statusValue == ZZVideoIncomingStatusDownloaded ||
            v.statusValue == ZZVideoIncomingStatusDownloading)
        {
             i++;
        }
    }
    return i;
}

- (void)setViewedWithIncomingVideo:(TBMVideo *)video
{
    [self setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusViewed video:video];
    [ZZApplicationRootService sendNotificationForVideoStatusUpdate:self
                                                           videoId:video.videoId
                                                            status:NOTIFICATION_STATUS_VIEWED];
}

//-------------------------------------
// VideoStatus Delegates and UI Strings
//-------------------------------------
// I just could not get KVO to work reliably on attributes of a managedModel.
// So I rolled my own notification registry.
// In hindsight I should have probably used the NSNotificationCenter for this rather than rolling my own.

+ (void)addVideoStatusNotificationDelegate:(id)delegate
{
    if (delegate)
    {
        if (!videoStatusNotificationDelegates)
        {
            videoStatusNotificationDelegates = [NSMutableSet new];
        }
        [videoStatusNotificationDelegates addObject:delegate];
    }
}

- (void)notifyVideoStatusChangeOnMainThread
{
    if (!self.everSent.boolValue)
    {
        self.everSent = @(YES);
        [self.managedObjectContext MR_saveToPersistentStoreAndWait];
        [ZZContentDataAcessor refreshContext:self.managedObjectContext];
    }
    [self notifyVideoStatusChange];
}


+ (void)fillAfterMigration
{
    for (TBMFriend *friend in [self all])
    {
        friend.everSent = @([friend.outgoingVideoStatus integerValue] > OUTGOING_VIDEO_STATUS_NONE);
    }
    [[self _context] MR_saveToPersistentStoreAndWait];
}

- (void)notifyVideoStatusChange
{
    ZZLogInfo(@"notifyVideoStatusChange for %@ on %lu delegates", self.firstName, (unsigned long) [videoStatusNotificationDelegates count]);
    for (id <TBMVideoStatusNotificationProtocol> delegate in videoStatusNotificationDelegates)
    {
        [delegate videoStatusDidChange:self];
    }
}

- (NSString*)videoStatusString
{
    if (self.lastVideoStatusEventTypeValue == OUTGOING_VIDEO_STATUS_EVENT_TYPE)
    {
        return [self outgoingVideoStatusString];
    }
    else
    {
        return [self incomingVideoStatusString];
    }
}

- (NSString*)incomingVideoStatusString
{
    TBMVideo *v = [self newestIncomingVideo];
    if (v == NULL)
        return [self displayName];

    if (v.statusValue == ZZVideoIncomingStatusDownloading)
    {
        if (v.downloadRetryCountValue == 0)
        {
            return @"Downloading...";
        }
        else
        {
            return [NSString stringWithFormat:@"Dwnld r%@", v.downloadRetryCount];
        }
    }
    else if (v.statusValue == ZZVideoIncomingStatusFailedPermanently)
    {
        return @"Downloading e!";
    }
    else
    {
        return [self displayName];
    }
}

- (NSString*)outgoingVideoStatusString
{
    NSString *statusString;
    switch (self.outgoingVideoStatusValue)
    {
        case OUTGOING_VIDEO_STATUS_NEW:
            statusString = @"q...";
            break;
        case OUTGOING_VIDEO_STATUS_UPLOADING:
            if (self.uploadRetryCountValue == 0)
            {
                statusString = @"p...";
            }
            else
            {
                statusString = [NSString stringWithFormat:@"r%ld...", (long) [self.uploadRetryCount integerValue]];
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
        case OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY:
            statusString = @"e!";
            break;
        default:
            statusString = nil;
    }

    NSString *fn = (statusString == nil || self.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED) ? [self displayName] : [self shortFirstName];
    return [NSString stringWithFormat:@"%@ %@", fn, statusString];
}

- (NSString *)shortFirstName
{
    return [[self displayName] substringWithRange:NSMakeRange(0, MIN(6, [[self displayName] length]))];
}

//---------------
// Setting status
//---------------
- (void)setAndNotifyOutgoingVideoStatus:(TBMOutgoingVideoStatus)status videoId:(NSString *)videoId
{
    [ZZContentDataAcessor refreshContext:self.managedObjectContext];
    if (![videoId isEqualToString:self.outgoingVideoId])
    {
        ZZLogWarning(@"setAndNotifyOutgoingVideoStatus: Unrecognized vidoeId:%@. != ougtoingVid:%@. friendId:%@ Ignoring.", videoId, self.outgoingVideoId, self.idTbm);
        return;
    }

    if (status == self.outgoingVideoStatusValue)
    {
        ZZLogWarning(@"setAndNotifyOutgoingVideoStatusWithVideo: Identical status. Ignoring.");
        return;
    }

    self.lastVideoStatusEventTypeValue = OUTGOING_VIDEO_STATUS_EVENT_TYPE;
    self.outgoingVideoStatusValue = status;

    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    [self notifyVideoStatusChangeOnMainThread];
}

- (void)setAndNotifyIncomingVideoStatus:(ZZVideoIncomingStatus)status video:(TBMVideo *)video
{
    [ZZContentDataAcessor refreshContext:self.managedObjectContext];
    if (video.statusValue == status)
    {
        ZZLogWarning(@"setAndNotifyIncomingVideoStatusWithVideo: Identical status. Ignoring.");
        return;
    }

   
    video.statusValue = status;

    
    [video.managedObjectContext MR_saveToPersistentStoreAndWait];
    self.lastIncomingVideoStatusValue = status;

    // Serhii says: We want to preserve previous status if last event type is incoming and status is VIEWED
    // Sani complicates it by saying: This is a bit subtle. We don't want an action by this user of
    // viewing his incoming video to count
    // as cause a change in lastVideoStatusEventType. That way if the last action by the user was sending a
    // video (recording on a person with unviewed indicator showing) then later viewed the incoming videos
    // he gets to see the status of the last outgoing video he sent after play is complete and the unviewed count
    // indicator goes away.
    if (status != ZZVideoIncomingStatusViewed)
    {
        self.lastVideoStatusEventType = INCOMING_VIDEO_STATUS_EVENT_TYPE;
    }
    
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    [self notifyVideoStatusChangeOnMainThread];
    
}

// --------------------
// Setting Retry Counts
// --------------------
- (void)setAndNotifyUploadRetryCount:(NSInteger)retryCount videoId:(NSString *)videoId
{
    [ZZContentDataAcessor refreshContext:self.managedObjectContext];
    if (![videoId isEqualToString:self.outgoingVideoId])
    {
        ZZLogWarning(@"setAndNotifyUploadRetryCount: Unrecognized vidoeId. Ignoring.");
        return;
    }

    if (retryCount != self.uploadRetryCountValue)
    {
        self.uploadRetryCount = @(retryCount);
        self.lastVideoStatusEventTypeValue = OUTGOING_VIDEO_STATUS_EVENT_TYPE;
        [self.managedObjectContext MR_saveToPersistentStoreAndWait];
        [self notifyVideoStatusChangeOnMainThread];
    }
    else
    {
        ZZLogWarning(@"retryCount:%ld equals self.retryCount:%@. Ignoring.", (long)retryCount, self.uploadRetryCount);
    }
}

- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount video:(TBMVideo *)video
{
    [ZZContentDataAcessor refreshContext:self.managedObjectContext];
    [ZZContentDataAcessor refreshContext:video.managedObjectContext];
    
    if (video.downloadRetryCountValue == retryCount)
        return;

    video.downloadRetryCount = @(retryCount);
    [video.managedObjectContext MR_saveToPersistentStoreAndWait];
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];

    if ([self isNewestIncomingVideo:video])
    {
        self.lastVideoStatusEventType = INCOMING_VIDEO_STATUS_EVENT_TYPE;
        [self.managedObjectContext MR_saveToPersistentStoreAndWait];
        [self notifyVideoStatusChangeOnMainThread];
    }
}

//--------------------
// Init outgoing video
//--------------------
#pragma mark - Ougtoing Video Status Handling

- (void)handleOutgoingVideoCreatedWithVideoId:(NSString *)videoId
{
    self.uploadRetryCount = 0;
    self.outgoingVideoId = videoId;
   [self setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_NEW videoId:self.outgoingVideoId];
}

- (void)handleOutgoingVideoUploadingWithVideoId:(NSString *)videoId
{
    [self setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_UPLOADING videoId:videoId];
}

- (void)handleOutgoingVideoUploadedWithVideoId:(NSString *)videoId
{
    [self setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_UPLOADED videoId:videoId];
}

- (void)handleOutgoingVideoViewedWithVideoId:(NSString *)videoId
{
    [self setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_VIEWED videoId:videoId];
}

- (void)handleOutgoingVideoFailedPermanentlyWithVideoId:(NSString *)videoId
{
    [self setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY videoId:videoId];
}

- (void)handleUploadRetryCount:(NSInteger)retryCount videoId:(NSString *)videoId
{
    [self setAndNotifyUploadRetryCount:retryCount videoId:videoId];
}

- (NSString *)fullName
{
    return [ZZUserPresentationHelper fullNameWithFirstName:self.firstName lastName:self.lastName];
}

- (BOOL)hasOutgoingVideo
{
    return !ANIsEmpty(self.outgoingVideoId);
}

+ (NSArray*)everSentMkeys
{
    NSMutableArray *result = [NSMutableArray array];
    for (TBMFriend *friend in [self _allEverSentFriends])
    {
        [result addObject:friend.mkey];
    }
    return result;
}

+ (void)setEverSentForMkeys:(NSArray*)mkeys
{
    [mkeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TBMFriend *aFriend = [self findWithMkey:obj];
        aFriend.everSent = @(YES);
        aFriend.isFriendshipCreator = @([aFriend.friendshipCreatorMKey isEqualToString:aFriend.mkey]);
    }];
    
    [TBMFriend updateUnlockFeatureWithMkeys:mkeys];
    
    [[self _context] MR_saveToPersistentStoreAndWait];
}


#pragma mark - Update Friends Mkeys For Unlock Features

+ (void)updateUnlockFeatureWithMkeys:(NSArray*)mkeys
{
    for (id <TBMVideoStatusNotificationProtocol> delegate in videoStatusNotificationDelegates)
    {
        [delegate unlockFeaturesUpdateWithMkeysArray:mkeys];
    }
}


#pragma mark Private

+ (NSArray *)_allEverSentFriends
{
    NSPredicate *everSent = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.everSent, @(YES)];
    NSPredicate *creator = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.isFriendshipCreator, @(NO)];
    NSPredicate *filter = [NSCompoundPredicate andPredicateWithSubpredicates:@[everSent, creator]];
    return [self MR_findAllWithPredicate:filter inContext:[self _context]];
}

@end

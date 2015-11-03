
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

//static NSMutableSet *videoStatusNotificationDelegates;

//+ (NSManagedObjectContext*)_context
//{
//    return [ZZContentDataAcessor contextForCurrentThread];
//}
//
//+ (NSArray *)all
//{
//    return [self MR_findAllInContext:[self _context]];
//}
////
////+ (NSUInteger)allUnviewedCount
////{
////    NSUInteger result = 0;
////    for (TBMFriend *friend in [self all])
////    {
////        result += friend.unviewedCount;
////    }
////    return result;
////}
//
//
//+ (instancetype)findWithId:(NSString *)idTbm
//{
//    return [self findWithAttributeKey:@"idTbm" value:idTbm];
//}
//
//+ (instancetype)findWithMkey:(NSString *)mkey
//{
//    return [self findWithAttributeKey:@"mkey" value:mkey];
//}
//
//+ (instancetype)findWithAttributeKey:(NSString *)key value:(id)value
//{
//    return [[self findAllWithAttributeKey:key value:value] lastObject];
//}
//
//+ (NSArray *)findAllWithAttributeKey:(NSString *)key value:(id)value
//{
//    return [self MR_findByAttribute:key withValue:value inContext:[self _context]];
//}


//+ (NSUInteger)count
//{
//    return [self MR_countOfEntitiesWithContext:[self _context]];
//}


//-----------
// UI helpers
//-----------
//- (NSString *)displayName
//{
//    int maxLength = 100;
//    NSString *d;
//
//    if ([self firstNameIsUnique])
//        d = self.firstName;
//    else
//        d = [NSString stringWithFormat:@"%@. %@", [self firstInitial], self.lastName];
//
//    // Limit to 12 characgters
//    if (d.length > maxLength)
//        d = [d substringWithRange:NSMakeRange(0, maxLength - 1)];
//
//    return d;
//}
//
//- (BOOL)firstNameIsUnique
//{
//    for (TBMFriend *f in [TBMFriend all])
//    {
//        if (![self isEqual:f] && [self.firstName isEqualToString:f.firstName])
//            return NO;
//    }
//    return YES;
//}

//- (NSString *)firstInitial
//{
//    return [self.firstName substringToIndex:1];
//}

//----------------
// Incoming Videos
//----------------
#pragma mark Incoming Videos

//- (NSArray *)sortedIncomingVideos
//{
//    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:@"videoId" ascending:YES];
//    return [self.videos sortedArrayUsingDescriptors:@[d]];
//}
//
//- (TBMVideo *)newestIncomingVideo
//{
//    return [[self sortedIncomingVideos] lastObject];
//}
//
//- (BOOL)hasIncomingVideoId:(NSString*)videoId
//{
//    NSArray* videos = [self.videos.allObjects copy];
//    for (TBMVideo *v in videos)
//    {
//        if ([v.videoId isEqualToString:videoId])
//            return true;
//    }
//    return false;
//}
//
//- (BOOL)isNewestIncomingVideo:(TBMVideo *)video
//{
//    return [video isEqual:[self newestIncomingVideo]];
//}
//
//- (TBMVideo *)createIncomingVideoWithVideoId:(NSString *)videoId   
//{
//    TBMVideo *video = [ZZVideoDataProvider newWithVideoId:videoId onContext:self.managedObjectContext];;
//    [self addVideosObject:video];
//    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
//    return video;
//}
//
//- (void)deleteAllViewedOrFailedVideos
//{
//    ZZLogInfo(@"deleteAllViewedVideos");
//    NSArray *all = [self sortedIncomingVideos];
//    for (TBMVideo *v in all)
//    {
//        if (v.statusValue == ZZVideoIncomingStatusViewed ||
//            v.statusValue == ZZVideoIncomingStatusFailedPermanently)
//        {
//            [self deleteVideo:v];
//        }
//    }
//}
//
//- (void)deleteVideo:(TBMVideo*)video
//{
//    [ZZVideoDataUpdater deleteFilesForVideo:video];
//    [self removeVideosObject:video];
//    [ZZVideoDataUpdater destroy:video];
//    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
//}

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

//- (TBMVideo *)nextUnviewedVideoAfterVideoId:(NSString *)videoId
//{
//    for (TBMVideo *v in [self sortedIncomingVideos])
//    {
//        if ([TBMVideoIdUtils isvid1:v.videoId newerThanVid2:videoId] && [ZZVideoDataProvider videoFileExistsForVideo:v] && v.statusValue == ZZVideoIncomingStatusDownloaded)
//            return v;
//    }
//    return nil;
//}

//- (NSInteger)unviewedCount
//{
//    NSInteger i = 0;
//    for (TBMVideo *v in [self videos])
//    {
//        if (v.statusValue == ZZVideoIncomingStatusDownloaded) //||
//           // v.statusValue == ZZVideoIncomingStatusDownloading)
//        {
//             i++;
//        }
//    }
//    return i;
//}


//-------------------------------------
// VideoStatus Delegates and UI Strings
//-------------------------------------
// I just could not get KVO to work reliably on attributes of a managedModel.
// So I rolled my own notification registry.
// In hindsight I should have probably used the NSNotificationCenter for this rather than rolling my own.

//+ (void)addVideoStatusNotificationDelegate:(id)delegate
//{
//    if (delegate)
//    {
//        if (!videoStatusNotificationDelegates)
//        {
//            videoStatusNotificationDelegates = [NSMutableSet new];
//        }
//        [videoStatusNotificationDelegates addObject:delegate];
//    }
//}

//- (void)notifyVideoStatusChangeOnMainThread
//{
//    if (!self.everSent.boolValue)
//    {
//        self.everSent = @(YES);
//        [self.managedObjectContext MR_saveToPersistentStoreAndWait];
//        [ZZContentDataAcessor refreshContext:self.managedObjectContext];
//    }
//    [self notifyVideoStatusChange];
//}


//+ (void)fillAfterMigration
//{
//    for (TBMFriend *friend in [self all])
//    {
//        friend.everSent = @([friend.outgoingVideoStatus integerValue] > ZZVideoOutgoingStatusNone);
//    }
//    [[self _context] MR_saveToPersistentStoreAndWait];
//}

//- (void)notifyVideoStatusChange
//{
//    ZZLogInfo(@"notifyVideoStatusChange for %@ on %lu delegates", self.firstName, (unsigned long) [videoStatusNotificationDelegates count]);
//    for (id <TBMVideoStatusNotificationProtocol> delegate in videoStatusNotificationDelegates)
//    {
//        [delegate videoStatusDidChange:self];
//    }
//}
//
//- (NSString*)videoStatusString
//{
//    if (self.lastVideoStatusEventTypeValue == OUTGOING_VIDEO_STATUS_EVENT_TYPE)
//    {
//        return [self outgoingVideoStatusString];
//    }
//    else
//    {
//        return [self incomingVideoStatusString];
//    }
//}
//
//- (NSString*)incomingVideoStatusString
//{
//    TBMVideo *v = [self newestIncomingVideo];
//    if (v == NULL)
//        return [self displayName];
//
//    if (v.statusValue == ZZVideoIncomingStatusDownloading)
//    {
//        if (v.downloadRetryCountValue == 0)
//        {
//            return @"Downloading...";
//        }
//        else
//        {
//            return [NSString stringWithFormat:@"Dwnld r%@", v.downloadRetryCount];
//        }
//    }
//    else if (v.statusValue == ZZVideoIncomingStatusFailedPermanently)
//    {
//        return @"Downloading e!";
//    }
//    else
//    {
//        return [self displayName];
//    }
//}
//
//- (NSString*)outgoingVideoStatusString
//{
//    NSString *statusString;
//    switch (self.outgoingVideoStatusValue)
//    {
//        case OUTGOING_VIDEO_STATUS_NEW:
//            statusString = @"q...";
//            break;
//        case OUTGOING_VIDEO_STATUS_UPLOADING:
//            if (self.uploadRetryCountValue == 0)
//            {
//                statusString = @"p...";
//            }
//            else
//            {
//                statusString = [NSString stringWithFormat:@"r%ld...", (long) [self.uploadRetryCount integerValue]];
//            }
//            break;
//        case OUTGOING_VIDEO_STATUS_UPLOADED:
//            statusString = @".s..";
//            break;
//        case OUTGOING_VIDEO_STATUS_DOWNLOADED:
//            statusString = @"..p.";
//            break;
//        case OUTGOING_VIDEO_STATUS_VIEWED:
//            statusString = @"v!";
//            break;
//        case OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY:
//            statusString = @"e!";
//            break;
//        default:
//            statusString = nil;
//    }
//
//    NSString *fn = (statusString == nil || self.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED) ? [self displayName] : [self shortFirstName];
//    return [NSString stringWithFormat:@"%@ %@", fn, statusString];
//}

//- (NSString *)shortFirstName
//{
//    return [[self displayName] substringWithRange:NSMakeRange(0, MIN(6, [[self displayName] length]))];
//}

// --------------------
// Setting Retry Counts
// --------------------
//- (void)setAndNotifyUploadRetryCount:(NSInteger)retryCount videoId:(NSString *)videoId
//{
//    [ZZContentDataAcessor refreshContext:self.managedObjectContext];
//    if (![videoId isEqualToString:self.outgoingVideoId])
//    {
//        ZZLogWarning(@"setAndNotifyUploadRetryCount: Unrecognized vidoeId. Ignoring.");
//        return;
//    }
//
//    if (retryCount != self.uploadRetryCountValue)
//    {
//        self.uploadRetryCount = @(retryCount);
//        self.lastVideoStatusEventTypeValue = ZZVideoStatusEventTypeOutgoing;
//        [self.managedObjectContext MR_saveToPersistentStoreAndWait];
//        [self notifyVideoStatusChangeOnMainThread];
//    }
//    else
//    {
//        ZZLogWarning(@"retryCount:%ld equals self.retryCount:%@. Ignoring.", (long)retryCount, self.uploadRetryCount);
//    }
//}


#pragma mark - Ougtoing Video Status Handling

//- (NSString *)fullName
//{
//    return [ZZUserPresentationHelper fullNameWithFirstName:self.firstName lastName:self.lastName];
//}
//
//- (BOOL)hasOutgoingVideo
//{
//    return !ANIsEmpty(self.outgoingVideoId);
//}
//
//+ (NSArray*)everSentMkeys
//{
//    NSMutableArray *result = [NSMutableArray array];
//    for (TBMFriend *friend in [self _allEverSentFriends])
//    {
//        [result addObject:friend.mkey];
//    }
//    return result;
//}
//
//+ (void)setEverSentForMkeys:(NSArray*)mkeys
//{
//    [mkeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        TBMFriend *aFriend = [self findWithMkey:obj];
//        aFriend.everSent = @(YES);
//        aFriend.isFriendshipCreator = @([aFriend.friendshipCreatorMKey isEqualToString:aFriend.mkey]);
//    }];
//    
//    [TBMFriend updateUnlockFeatureWithMkeys:mkeys];
//    
//    [[self _context] MR_saveToPersistentStoreAndWait];
//}


#pragma mark - Update Friends Mkeys For Unlock Features

//+ (void)updateUnlockFeatureWithMkeys:(NSArray*)mkeys
//{
////    for (id <TBMVideoStatusNotificationProtocol> delegate in videoStatusNotificationDelegates)
////    {
////        [delegate unlockFeaturesUpdateWithMkeysArray:mkeys];
////    }
//}


#pragma mark Private

//+ (NSArray *)_allEverSentFriends
//{
//    NSPredicate *everSent = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.everSent, @(YES)];
//    NSPredicate *creator = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.isFriendshipCreator, @(NO)];
//    NSPredicate *filter = [NSCompoundPredicate andPredicateWithSubpredicates:@[everSent, creator]];
//    return [self MR_findAllWithPredicate:filter inContext:[self _context]];
//}

@end

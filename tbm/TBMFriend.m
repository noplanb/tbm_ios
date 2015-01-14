//
//  TBMFriend.m
//  tbm
//
//  Created by Sani Elfishawy on 8/18/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "AVFoundation/AVFoundation.h"

#import "TBMFriend.h"
#import "TBMAppDelegate.h"
#import "TBMAppDelegate+PushNotification.h"
#import "TBMConfig.h"
#import "TBMUser.h"
#import "TBMStringUtils.h"
#import "TBMVideoIdUtils.h"
#import "TBMHomeViewController.h"
#import "OBLogger.h"
#import "TBMHttpManager.h"
#import "TBMPhoneUtils.h"

@implementation TBMFriend

@dynamic firstName;
@dynamic lastName;
@dynamic outgoingVideoId;
@dynamic outgoingVideoStatus;
@dynamic lastVideoStatusEventType;
@dynamic lastIncomingVideoStatus;
@dynamic uploadRetryCount;
@dynamic idTbm;
@dynamic mkey;
@dynamic ckey;
@dynamic videos;
@dynamic hasApp;
@dynamic mobileNumber;
@dynamic timeOfLastAction;
@dynamic gridElement;

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
    __block NSError *error;
    __block NSArray *result;
    [[TBMFriend managedObjectContext] performBlockAndWait:^{
        result = [[TBMFriend managedObjectContext] executeFetchRequest:[TBMFriend fetchRequest] error:&error];
    }];
    return result;
}

+ (instancetype)findWithOutgoingVideoId:(NSString *)videoId{
    return [self findWithAttributeKey:@"outgoingVideoId" value:videoId];
}

+ (instancetype)findWithId:(NSString *)idTbm{
    return [self findWithAttributeKey:@"idTbm" value:idTbm];
}

+ (instancetype)findWithMkey:(NSString *)mkey{
    return [self findWithAttributeKey:@"mkey" value:mkey];
}

+ (instancetype)findWithAttributeKey:(NSString *)key value:(id)value{
    return [[self findAllWithAttributeKey:key value:value] lastObject];
}

+ (NSArray *)findAllWithAttributeKey:(NSString *)key value:(id)value{
    __block NSArray *result;
    __block NSError *error;
    [[TBMFriend managedObjectContext] performBlockAndWait:^{
        NSFetchRequest *request = [TBMFriend fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, value];
        [request setPredicate:predicate];
        result = [[TBMFriend managedObjectContext] executeFetchRequest:request error:&error];
    }];
    return result;
}

+ (instancetype)findWithMatchingPhoneNumber:(NSString *)phone{
    for (TBMFriend *f in [TBMFriend all]){
        if ([TBMPhoneUtils isNumberMatch:phone secondNumber:f.mobileNumber])
            return f;
    }
    return nil;
}

+ (NSUInteger)count{
    return [[TBMFriend all] count];
}


//-------------------
// Create and destroy
//-------------------
+ (instancetype)createWithId:(NSString *)idTbm{
    __block TBMFriend *friend;
    [[TBMFriend managedObjectContext] performBlockAndWait:^{
        friend = (TBMFriend *)[[NSManagedObject alloc] initWithEntity:[TBMFriend entityDescription] insertIntoManagedObjectContext:[TBMFriend managedObjectContext]];
        friend.idTbm = idTbm;
    }];
    return friend;
}

+ (instancetype)createWithServerParams:(NSDictionary *)params{
    TBMFriend *f = [TBMFriend findWithMkey:[params objectForKey:SERVER_PARAMS_FRIEND_MKEY_KEY]];
    if (f != nil){
        OB_WARN(@"createWithServerParams: friend already exists. Not creating.");
        return f;
    }
    
    __block TBMFriend *friend;
    [[TBMFriend managedObjectContext] performBlockAndWait:^{
        friend = (TBMFriend *)[[NSManagedObject alloc]
                               initWithEntity:[TBMFriend entityDescription]
                               insertIntoManagedObjectContext:[TBMFriend managedObjectContext]];
        
        friend.firstName = [params objectForKey:SERVER_PARAMS_FRIEND_FIRST_NAME_KEY];
        friend.lastName = [params objectForKey:SERVER_PARAMS_FRIEND_LAST_NAME_KEY];
        friend.mobileNumber = [params objectForKey:SERVER_PARAMS_FRIEND_MOBILE_NUMBER_KEY];
        friend.idTbm = [params objectForKey:SERVER_PARAMS_FRIEND_ID_KEY];
        friend.mkey = [params objectForKey:SERVER_PARAMS_FRIEND_MKEY_KEY];
        friend.ckey = [params objectForKey:SERVER_PARAMS_FRIEND_CKEY_KEY];
        friend.timeOfLastAction = [NSDate date];
        if ([[params objectForKey:SERVER_PARAMS_FRIEND_HAS_APP] isEqualToString:@"true"])
            friend.hasApp = YES;
        else
            friend.hasApp = NO;
    }];
    OB_INFO(@"Added friend: %@", friend);
    return friend;
}


+ (NSUInteger)destroyAll{
    NSUInteger count = [[TBMFriend all] count];
    [[TBMFriend managedObjectContext] performBlockAndWait:^{
        for (TBMFriend *friend in [TBMFriend all]) {
            [[TBMFriend managedObjectContext] deleteObject:friend];
        }
    }];
    return count;
}

+ (void)destroyWithId:(NSString *)idTbm{
    [[TBMFriend managedObjectContext] performBlockAndWait:^{
        TBMFriend *friend = [TBMFriend findWithId:idTbm];
        if ( friend != nil ){
            [[TBMFriend managedObjectContext] deleteObject:friend];
        }
    }];
}


//=================
// Instance methods
//=================

//----------------
// Incoming Videos
//----------------
- (NSSet *) incomingVideos{
    return self.videos;
}

- (NSArray *) sortedIncomingVideos{
    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:@"videoId" ascending:YES];
    return [self.videos sortedArrayUsingDescriptors:@[d]];
}

- (TBMVideo *) oldestIncomingVideo{
    return [[self sortedIncomingVideos] firstObject];
}

- (NSString *) oldestIncomingVideoId{
    return [self oldestIncomingVideo].videoId;
}

- (TBMVideo *) newestIncomingVideo{
    return [[self sortedIncomingVideos] lastObject];
}

- (BOOL) hasIncomingVideoId:(NSString *)videoId{
    for (TBMVideo *v in [self incomingVideos]) {
        if ([v.videoId isEqual: videoId])
            return true;
    }
    return false;
}

- (BOOL) isNewestIncomingVideo:(TBMVideo *)video{
    return [video isEqual:[self newestIncomingVideo]];
}

- (TBMVideo *)createIncomingVideoWithVideoId:(NSString *)videoId{
    TBMVideo *video = [TBMVideo newWithVideoId:videoId];
    [self addVideosObject:video];
    return video;
}

- (void) deleteAllVideos{
    for (TBMVideo *v in [self incomingVideos]){
        [self deleteVideo:v];
    }
}

- (void) deleteAllViewedOrFailedVideos{
    OB_INFO(@"deleteAllViewedVideos");
    NSArray *all = [self sortedIncomingVideos];
    for (TBMVideo * v in all){
        if (v.status == INCOMING_VIDEO_STATUS_VIEWED || v.status == INCOMING_VIDEO_STATUS_FAILED_PERMANENTLY)
            [self deleteVideo:v];
    }
}

- (void) deleteVideo:(TBMVideo *)video{
    [video deleteFiles];
    [self removeVideosObject:video];
    [TBMVideo destroy:video];
}

- (TBMVideo *) firstPlayableVideo{
    TBMVideo *video = nil;
    for (TBMVideo *v in [self sortedIncomingVideos]){
        if ([v videoFileExists]){
            video = v;
            break;
        }
    }
    return video;
}

- (TBMVideo *) nextPlayableVideoAfterVideoId:(NSString *)videoId{
    DebugLog(@"nextPlayableVideoAfterVideo");
    for (TBMVideo *v in [self sortedIncomingVideos]){
        if ([TBMVideoIdUtils isvid1:v.videoId newerThanVid2:videoId] && [v videoFileExists])
            return v;
    }
    return nil;
}

- (void)printVideos{
    for (TBMVideo *v in [self sortedIncomingVideos]) {
        DebugLog(@"Video id:%@ status:%ld file_exists:%d", v.videoId, v.status, [v videoFileExists]);
    }

}

- (BOOL)incomingVideoNotViewed{
    return [self unviewedCount] > 0;
}

- (NSInteger)unviewedCount{
    NSInteger i = 0;
    for (TBMVideo *v in [self sortedIncomingVideos]){
        if (v.status == INCOMING_VIDEO_STATUS_DOWNLOADED)
            i++;
    }
    return i;
}

- (void)setViewedWithIncomingVideo:(TBMVideo *)video{
    [self setAndNotifyIncomingVideoStatus:INCOMING_VIDEO_STATUS_VIEWED video:video];
    [[TBMFriend appDelegate] sendNotificationForVideoStatusUpdate:self videoId:video.videoId status:NOTIFICATION_STATUS_VIEWED];
}

//------
// Thumb
//------
- (NSURL *)thumbUrl{
    NSURL *thumb = nil;
    for (TBMVideo *v in [self sortedIncomingVideos]){
        if ([v hasThumb]){
            thumb = [v thumbUrl];
        }
    }
    return thumb;
}

- (BOOL)hasThumb{
    return [self thumbUrl] != nil;
}

//-------------------------------------
// VideoStatus Delegates and UI Strings
//-------------------------------------
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
    for (id<TBMVideoStatusNotificationProtocol> delegate in videoStatusNotificationDelegates){
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
    TBMVideo *v = [self newestIncomingVideo];
    if (v == NULL)
        return self.firstName;
    
    if (v.status == INCOMING_VIDEO_STATUS_DOWNLOADING){
        if ([v.downloadRetryCount intValue] == 0){
            return @"Downloading...";
        } else {
            return [NSString stringWithFormat:@"Downloading r%@", v.downloadRetryCount];
        }
    } else if (v.status == INCOMING_VIDEO_STATUS_FAILED_PERMANENTLY){
        return @"Downloading e!";
    } else {
        return self.firstName;
    }
}

- (NSString *)outgoingVideoStatusString{
    NSString *statusString;
    switch (self.outgoingVideoStatus) {
        case OUTGOING_VIDEO_STATUS_NEW:
            statusString = @"q...";
            break;
        case OUTGOING_VIDEO_STATUS_UPLOADING:
            if (self.uploadRetryCount == 0) {
                statusString = @"p...";
            } else {
                statusString = [NSString stringWithFormat:@"r%ld...", (long)[self.uploadRetryCount integerValue]];
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
    
    NSString *fn = (statusString == nil || self.outgoingVideoStatus == OUTGOING_VIDEO_STATUS_VIEWED) ? self.firstName : [self shortFirstName];
    return [NSString stringWithFormat:@"%@ %@", fn, statusString];
}

- (NSString *)shortFirstName{
    return [self.firstName substringWithRange:NSMakeRange(0, MIN(6, [self.firstName length]))];
}

//---------------
// Setting status
//---------------
- (void)setAndNotifyOutgoingVideoStatus:(TBMOutgoingVideoStatus)status videoId:(NSString *)videoId{
    if (![videoId isEqual: self.outgoingVideoId]){
        OB_WARN(@"setAndNotifyOutgoingVideoStatus: Unrecognized vidoeId:%@. != ougtoingVid:%@. friendId:%@ Ignoring.", videoId, self.outgoingVideoId, self.idTbm);
        return;
    }
    
    if (status == self.outgoingVideoStatus){
        OB_WARN(@"setAndNotifyOutgoingVideoStatusWithVideo: Identical status. Ignoring.");
        return;
    }
    
    self.lastVideoStatusEventType = OUTGOING_VIDEO_STATUS_EVENT_TYPE;
    self.outgoingVideoStatus = status;
    [self notifyVideoStatusChangeOnMainThread];
}

- (void)setAndNotifyIncomingVideoStatus:(TBMIncomingVideoStatus)status video:(TBMVideo *)video{
    if (video.status == status){
        OB_WARN(@"setAndNotifyIncomingVideoStatusWithVideo: Identical status. Ignoring.");
        return;
    }
    
    video.status = status;
    self.lastIncomingVideoStatus = status;
    self.lastVideoStatusEventType = INCOMING_VIDEO_STATUS_EVENT_TYPE;
    [self notifyVideoStatusChangeOnMainThread];
}

// --------------------
// Setting Retry Counts
// --------------------
- (void)setAndNotifyUploadRetryCount:(NSNumber *)retryCount videoId:(NSString *)videoId{
    if (![videoId isEqual:self.outgoingVideoId]){
        OB_WARN(@"setAndNotifyUploadRetryCount: Unrecognized vidoeId. Ignoring.");
        return;
    }
    
    if (retryCount != self.uploadRetryCount){
        self.uploadRetryCount = retryCount;
        self.lastVideoStatusEventType = OUTGOING_VIDEO_STATUS_EVENT_TYPE;
        [self notifyVideoStatusChangeOnMainThread];
    } else {
        OB_WARN(@"retryCount:%@ equals self.retryCount:%@. Ignoring.", retryCount, self.uploadRetryCount);
    }
}

- (void)setAndNotifyDownloadRetryCount:(NSNumber *)retryCount video:(TBMVideo *)video{
    if (video.downloadRetryCount == retryCount)
        return;
    
    video.downloadRetryCount = retryCount;

    
    if ([self isNewestIncomingVideo:video]) {
        self.lastVideoStatusEventType = INCOMING_VIDEO_STATUS_EVENT_TYPE;
        [self notifyVideoStatusChangeOnMainThread];
    }
}

//--------------------
// Init outgoing video
//--------------------
- (void)handleAfterOutgoingVideoCreated{
    self.uploadRetryCount = 0;
    self.outgoingVideoId = [TBMVideoIdUtils generateId];
    [self setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_NEW videoId:self.outgoingVideoId];
}

- (void)handleAfterOUtgoingVideoUploadStarted{
    [self setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_UPLOADING videoId:self.outgoingVideoId];
}


@end

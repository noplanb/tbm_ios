//
//  TBMUploadManager.m
//  tbm
//
//  Created by Sani Elfishawy on 5/6/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMUploadManager.h"
#import "TBMVideoRecorder.h"
#import "TBMConfig.h"
#import "TBMUser.h"
#import "TBMHttpClient.h"
#import "TBMFriend.h"
#import "TBMAppDelegate.h"

static NSString * const TBMUploadManagerSessionIdentifier = @"com.noplanbees.tbm.backgroundUploadSession";
static NSString * const TBMHttpFormBoundary = @"*****tbm*****";
@implementation TBMUploadManager

//--------------
// Class methods
//--------------
- (instancetype)init{
    self = [super init];
    if (self){
        _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
    return self;
}

+ (instancetype)sharedManager{
    static TBMUploadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TBMUploadManager alloc] init];
        if (!instance){
            DebugLog(@"init: ERROR: got nil for instance on init. This should never happen!");
        }
    });
    return instance;
}

+ (NSURL *)uploadingVideoUrlWithFriendId:(NSString *)friendId{
    NSString *filename = [NSString stringWithFormat:@"uploadingVidToFriend%@", friendId];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mov"]];
}

+ (NSURL *)tbmServerUploadUrlWithFriendId:(NSString *)friendId{
    TBMUser *user = [TBMUser getUser];
    NSString *path = [NSString stringWithFormat:@"/videos/create?receiver_id=%@&user_id=%@",friendId, user.idTbm];
    path = [[TBMConfig tbmBasePath] stringByAppendingString:path];
    return [NSURL URLWithString:path];
}

+ (NSString *)sessionIdentifier{
    return TBMUploadManagerSessionIdentifier;
}


//=========================
// Private Instance Methods
//=========================

// Singleton with unique identifier so our session is matched when our app is relaunched either in foreground or background.
- (NSURLSession *) session{
    static NSURLSession *session = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:TBMUploadManagerSessionIdentifier];
		session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	});
	return session;
}

// -----------------------------------
// Methods relating to task management
// -----------------------------------
- (void) showAllTasks{
    [[self session] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        [self logStats: [self tabulateStatsWithTasks:uploadTasks]];
    }];
}

- (NSMutableDictionary *) tabulateStatsWithTasks:(NSArray *)tasks{
    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
    DebugLog(@"task count=%lu", (unsigned long)[tasks count]);
    for (NSURLSessionUploadTask *task in tasks){
        
        NSString *friendId = [self friendIdWithTask:task];
        if (!friendId)
            friendId = @"noFriendId";
        
        if (!stats[friendId])
            stats[friendId] = [[NSMutableDictionary alloc] init];
        
        switch (task.state) {
            case NSURLSessionTaskStateRunning:
                stats[friendId] = [self incrementObjectAtKey:@"running" withDictionary:stats[friendId]];
                break;
            case NSURLSessionTaskStateSuspended:
                stats[friendId] = [self incrementObjectAtKey:@"suspended" withDictionary:stats[friendId]];
                break;
            case NSURLSessionTaskStateCanceling:
                stats[friendId] = [self incrementObjectAtKey:@"canceling" withDictionary:stats[friendId]];
                break;
            case NSURLSessionTaskStateCompleted:
                if (task.error){
                    stats[friendId] = [self incrementObjectAtKey:@"completeError" withDictionary:stats[friendId]];
                } else {
                    stats[friendId] = [self incrementObjectAtKey:@"completeSuccess" withDictionary:stats[friendId]];
                }
                break;
            default:
                break;
        }
    }
    return stats;
}

- (void) logStats:(NSMutableDictionary *)friendTaskStats{
    for (NSString *friendId in [friendTaskStats keyEnumerator]){
        NSMutableString *statString = [[NSMutableString alloc] init];
        [statString appendString:[NSString stringWithFormat:@"friendId=%@ : ", friendId]];
        NSMutableDictionary *stats = [friendTaskStats objectForKey:friendId];
        for (NSString *state in [stats keyEnumerator]){
            NSNumber *count = [stats objectForKey:state];
            [statString appendString:[NSString stringWithFormat:@"%@=%@ ", state, count]];
        }
        DebugLog(statString);
    }
}

- (NSMutableDictionary *)incrementObjectAtKey:(NSString *)key withDictionary:(NSMutableDictionary *)dictionary{
    int value = [dictionary[key] intValue];
    value ++;
    dictionary[key] = [NSNumber numberWithInt:value];
    return dictionary;
}

- (NSString *)friendIdWithTask:(NSURLSessionTask *)task{
    return task.taskDescription;
}

- (TBMFriend *)friendWithTask:(NSURLSessionTask *)task{
    return [TBMFriend findWithId:[self friendIdWithTask:task]];
}

- (NSArray *) findUploadTasksWithFriendId:(NSString *)friendId uploadTasks:(NSArray *)uploadTasks{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSURLSessionUploadTask *task in uploadTasks){
        if ([[self friendIdWithTask:task] isEqualToString:friendId])
            [result addObject:task];
    }
    return result;
}

- (void)resumeAllSuspendedTasks{
    [[self session] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        [self resumeAllSuspendedTasks:uploadTasks];
    }];
}

-(void)resumeAllSuspendedTasks:(NSArray *)tasks{
    DebugLog(@"resumeAllSuspendedTasks");
    for (NSURLSessionUploadTask *task in tasks){
        if (task.state == NSURLSessionTaskStateSuspended){
            DebugLog(@"resumeAllSuspendedTasks: resuming task %@", task.description);
            [task resume];
        }
    }
}

-(BOOL)isSuccessfulUploadTask:(NSURLSessionTask *)task{
    if (task.error){
        DebugLog(@"ERROR: upload task for friendId=%@ error=%@", [self friendIdWithTask:task], [task.error localizedDescription]);
        return NO;
    }
    
    NSInteger statusCode = [(NSHTTPURLResponse *)task.response  statusCode];
    if (statusCode != 200){
        DebugLog(@"ERROR: upload task for friendId=%@ statusCode=%ld", [self friendIdWithTask:task], (long)statusCode);
        return NO;
    }
    
    return YES;
}

// --------------------------
// Methods relating to upload
// --------------------------
- (void) uploadWithFriendId:(NSString *)friendId{
    DebugLog(@"uploadWithFriendId");
    [self setStatusToUploadingWithFriendId:friendId];
    [[self session] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        [self uploadWithFriendId:friendId uploadTasks:uploadTasks];
    }];
}

- (void) uploadWithFriendId:(NSString *)friendId uploadTasks:(NSArray *)uploadTasks{
    [self cancelUploadTasksWithFriendId:friendId uploadTasks:uploadTasks];
    [self createAndStartUploadTaskWithFriendId:friendId];
    [self showAllTasks];
}

- (void) cancelUploadTasksWithFriendId:(NSString *)friendId uploadTasks:(NSArray *)uploadTasks{
    for (NSURLSessionUploadTask *task in [self findUploadTasksWithFriendId:friendId uploadTasks:uploadTasks]){
        DebugLog(@"cancelling task: %@", [self friendIdWithTask:task]);
        [task cancel];
        [self showAllTasks];
    }
}

- (void) createAndStartUploadTaskWithFriendId:(NSString *)friendId{
    DebugLog(@"createAndStartUploadTaskWithFriendId:%@ retrycount=%ld", friendId, (long)[[TBMFriend findWithId:friendId] getRetryCount]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[TBMUploadManager tbmServerUploadUrlWithFriendId:friendId]];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@", TBMHttpFormBoundary ] forHTTPHeaderField:@"Content-Type"];
    

    NSMutableString *preString =  [[NSMutableString alloc] init];
    [preString appendString:@"--"];
    [preString appendString:TBMHttpFormBoundary];
    [preString appendString:@"\r\n"];
    [preString appendString:@"Content-Disposition: form-data; name=\"file\"; filename=\"vid.mov\"\r\n"];
    [preString appendString:@"Content-Type: video/mp4\r\n"];
    [preString appendString:@"Content-Transfer-Encoding: binary\r\n"];
    [preString appendString:@"\r\n"];
    
    NSString *postString =  [NSString stringWithFormat:@"\r\n--%@--\r\n", TBMHttpFormBoundary];

    NSMutableData *body = [[NSMutableData alloc] init];
    
    [body appendData:[preString dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithContentsOfURL:[TBMVideoRecorder outgoingVideoUrlWithFriendId:friendId]]];
    [body appendData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body writeToURL:[TBMUploadManager uploadingVideoUrlWithFriendId:friendId] atomically:YES];
    
    NSURLSessionUploadTask *task = [[self session] uploadTaskWithRequest:request fromFile:[TBMUploadManager uploadingVideoUrlWithFriendId:friendId]];
    task.taskDescription = friendId;
    [task resume];
}


// ---------------------
// Upload status logging
// ---------------------
- (void) setStatusForSuccessfulUploadWithTask:(NSURLSessionTask *)task{
    TBMFriend *friend = [self friendWithTask:task];
    [friend setRetryCountWithInteger:0];
    friend.outgoingVideoStatus = OUTGOING_VIDEO_STATUS_UPLOADED;
    [TBMFriend saveAll];
}

- (void) setStatusForFailedUploadWithTask:(NSURLSessionTask *)task{
    TBMFriend *friend = [self friendWithTask:task];
    [friend incrementRetryCount];
    friend.outgoingVideoStatus = OUTGOING_VIDEO_STATUS_UPLOADING;
    [TBMFriend saveAll];
}

- (void) setStatusToUploadingWithFriendId:(NSString *)friendId{
    TBMFriend *friend = [TBMFriend findWithId:friendId];
    friend.outgoingVideoStatus = OUTGOING_VIDEO_STATUS_UPLOADING;
    [TBMFriend saveAll];
}

- (void) setStatusToNewWithFriend:(TBMFriend *)friend{
    friend.outgoingVideoStatus = OUTGOING_VIDEO_STATUS_NEW;
    [friend setRetryCountWithInteger:0];
    [TBMFriend saveAll];
}


// --------------------------
// Methods relating to retry.
// --------------------------

// We ask for background time here so that we can holdoff the retry for some time even if the app enters background mode.
- (void)requestBackgroundTimeIfNeeded{
    
    if (_backgroundTaskIdentifier && _backgroundTaskIdentifier != UIBackgroundTaskInvalid){
        DebugLog(@"Not requesting background time. Already did.");
        return;
    }
    
    DebugLog(@"Requesting background time.");
    _backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        // The apple docs say you must terminate the background task you requested when they call the expiration handler
        // or before or they will terminate your app. I have found however that if I dont terminate and if
        // the usage of the phone is low by other apps they will let us run in the background indefinitely
        // even after the backgroundTimeRemaining has long gone to 0. This is good for our users as it allows us
        // to continue retries in the background for a long time in the case of poor coverage.
        
        // See above for why this line is commented out.
        // [self terminateBackgroundTask];
    }];
}

// Not used.
- (void)terminateBackgroundTaskWithFriendId:(NSString *)friendId{
    [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskIdentifier];
    _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

- (void)retryUploadAfterHoldoffWithFriendId:(NSString *)friendId{
    [self requestBackgroundTimeIfNeeded];
    DebugLog(@"Background time remaining = %f", [UIApplication sharedApplication].backgroundTimeRemaining);

    TBMFriend *friend = [TBMFriend findWithId:friendId];
    
    NSTimeInterval holdoff = [self retryHoldoffTimeIntervalWithFriend:friend];
    DebugLog(@"Will retry upload for %@ after %f seconds.", friend.firstName, holdoff);
    [self performSelector:@selector(uploadWithFriendId:) withObject:friendId afterDelay:holdoff];
    
    [friend incrementRetryCount];
    [TBMFriend saveAll];
}

- (NSTimeInterval)retryHoldoffTimeIntervalWithFriend:(TBMFriend *)friend{
    NSInteger retryCount = [friend getRetryCount];
    if (retryCount > 5)
        return (NSTimeInterval)10*(1<<5);
    
    return (NSTimeInterval)10*(1<<retryCount);
}

- (void) cancelOngoingRetries{
    [UIApplication cancelPreviousPerformRequestsWithTarget:self];
}

// This is used when the user makes the app active while there were uploads still pending retry with a long hold off.
// It is annoying to sit for a user to bring the app alive again and see messages pending upload and have to wait
// for the holdoff to end before he knows they will go out. This provides the ability to short circuit the holdoff
// and retry uploading immediately when the app becomes active. It us called in TBMAppDelegate applicationDidBecomeActive
- (void) restartUploadsPendingRetry{
    [self cancelOngoingRetries];
    for (TBMFriend *friend in [TBMFriend whereUploadPendingRetry]){
        [self setStatusToNewWithFriend:friend];
        [self uploadWithFriendId:friend.idTbm];
    }
}



// ---------------------------
// Session delegate callbacks.
// ---------------------------

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
//    DebugLog(@"Upload Progress: task:%@, sent:%llu, of:%llu", task, totalBytesSent, totalBytesExpectedToSend);
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if ([self isSuccessfulUploadTask:task]){
        DebugLog(@"upload for %@ successful", [self friendWithTask:task].firstName);
        [self setStatusForSuccessfulUploadWithTask:task];
    } else {
        NSString *friendId = [self friendIdWithTask:task];
        [self performSelectorOnMainThread:@selector(retryUploadAfterHoldoffWithFriendId:) withObject:friendId waitUntilDone:YES];
    }
}

/*
 If an application has received an -application:handleEventsForBackgroundURLSession:completionHandler: message, the session delegate will receive this message to indicate that all messages previously enqueued for this session have been delivered. We need to process all the completed tasks update the ui accordingly and invoke the completion handler so the os can take a picture of our app.
 */
- (void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    if ([session.configuration.identifier isEqualToString:TBMUploadManagerSessionIdentifier]){
        DebugLog(@"URLSessionDidFinishEventsForBackgroundURLSession");
        
        if ([[TBMFriend whereUploadPendingRetry] count] > 0)
            return;
        
        TBMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if (appDelegate.backgroundUploadSessionCompletionHandler){
            DebugLog(@"Calling backgroundUploadSessionCompletionHandler");
            appDelegate.backgroundUploadSessionCompletionHandler();
            appDelegate.backgroundUploadSessionCompletionHandler = nil;
        }
    }
}
@end

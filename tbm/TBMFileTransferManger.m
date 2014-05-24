//
//  TBMFileTransferManger.m
//  tbm
//
//  Created by Sani Elfishawy on 5/13/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMFileTransferManger.h"
#import "TBMVideoRecorder.h"
#import "TBMConfig.h"
#import "TBMUser.h"
#import "TBMHttpClient.h"
#import "TBMFriend.h"
#import "TBMAppDelegate.h"

static NSString * const TBMFileTransferSessionIdentifierBase = @"com.noplanbees.tbm.fileTransferSession";
static NSString * const TBMHttpFormBoundary = @"*****tbm*****";
@implementation TBMFileTransferManger

//--------------
// Instatiation
//--------------
- (instancetype)init{
    self = [super init];
    if (self){
        _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
    return self;
}


// -----------
// URL methods
// -----------

- (NSURL *)fileUrlWithFriendId:(NSString *)friendId{
    NSString *filename = [NSString stringWithFormat:@"%@VidToFriend%@",_transferTypeString, friendId];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mov"]];
}

- (NSURL *)tbmServerUrlWithFriendId:(NSString *)friendId{
    TBMUser *user = [TBMUser getUser];
    NSString *path;
    if (_transferType == TBM_FILE_TRANSFER_TYPE_DOWNLOAD){
        path = [NSString stringWithFormat:@"/videos/test_get?receiver_id=%@&user_id=%@", user.idTbm, friendId];
    } else {
        path = [NSString stringWithFormat:@"/videos/create?receiver_id=%@&user_id=%@",friendId, user.idTbm];
    }
    path = [[TBMConfig tbmBasePath] stringByAppendingString:path];
    return [NSURL URLWithString:path];
}

// ---------------
// Session methods
// ---------------

/*
 Singleton with unique identifier so our session is matched when our app is relaunched either in foreground or background. From: apple docuementation :: Note: You must create exactly one session per identifier (specified when you create the configuration object). The behavior of multiple sessions sharing the same identifier is undefined.
*/

- (NSURLSession *) session{
    if (_backgroundSession) {
        // DebugLog(@"Using existing session id=%@ for %@", _backgroundSession.configuration.identifier, _transferTypeString);
        return _backgroundSession;
    }
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:[self sessionIdentifier]];
    _backgroundSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    // DebugLog(@"Creating new session id=%@ for %@", _backgroundSession.configuration.identifier, _transferTypeString);
    
	return _backgroundSession;
}

- (NSString *)sessionIdentifier{
    return [TBMFileTransferSessionIdentifierBase stringByAppendingString:_transferTypeString];
}

// -----------------------------------
// Methods relating to task management
// -----------------------------------
- (void) showAllTasks{
    [[self session] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        NSArray *tasks;
        if (_transferType == TBM_FILE_TRANSFER_TYPE_DOWNLOAD) {
            tasks = downloadTasks;
        } else {
            tasks = uploadTasks;
        }
        
        [self logStats: [self tabulateStatsWithTasks:tasks]];
    }];
}

- (NSMutableDictionary *) tabulateStatsWithTasks:(NSArray *)tasks{
    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
    DebugLog(@"task count=%lu", (unsigned long)[tasks count]);
    for (NSURLSessionTask *task in tasks){
        
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

- (NSArray *) findTasksWithFriendId:(NSString *)friendId Tasks:(NSArray *)tasks{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSURLSessionTask *task in tasks){
        if ([[self friendIdWithTask:task] isEqualToString:friendId])
            [result addObject:task];
    }
    return result;
}

- (void)resumeAllSuspendedTasks{
    [[self session] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSArray *tasks;
        if (_transferType == TBM_FILE_TRANSFER_TYPE_DOWNLOAD){
            tasks = downloadTasks;
        } else {
            tasks = uploadTasks;
        }
        [self resumeAllSuspendedTasks:tasks];
    }];
}

-(void)resumeAllSuspendedTasks:(NSArray *)tasks{
    DebugLog(@"resumeAllSuspendedTasks");
    for (NSURLSessionTask *task in tasks){
        if (task.state == NSURLSessionTaskStateSuspended){
            DebugLog(@"resumeAllSuspendedTasks: resuming task %@", task.description);
            [task resume];
        }
    }
}

-(BOOL)isSuccessfulTask:(NSURLSessionTask *)task{
    if (task.error){
        DebugLog(@"ERROR: %@ task for friendId=%@ error=%@", _transferTypeString, [self friendIdWithTask:task], [task.error localizedDescription]);
        return NO;
    }
    
    NSInteger statusCode = [(NSHTTPURLResponse *)task.response  statusCode];
    if (statusCode != 200){
        DebugLog(@"ERROR: %@ task for friendId=%@ statusCode=%ld", _transferTypeString, [self friendIdWithTask:task], (long)statusCode);
        return NO;
    }
    
    return YES;
}

// ---------------------------------
// Methods relating to file transfer
// ---------------------------------
- (void) fileTransferWithFriendId:(NSString *)friendId{
    DebugLog(@"%@WithFriendId session=%@", _transferTypeString, [self session].configuration.identifier);
    
    [self setStatusForFileTransferStartWithFriendId:friendId];
    
    [[self session] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSArray *tasks;
        if (_transferType == TBM_FILE_TRANSFER_TYPE_UPLOAD) {
            tasks = uploadTasks;
        } else {
            tasks = downloadTasks;
        }
        
        [self fileTransferWithFriendId:friendId tasks:tasks];
    }];
}

- (void) fileTransferWithFriendId:(NSString *)friendId tasks:(NSArray *)tasks{
    DebugLog(@"%@WithFriendId: tasks=%@", _transferTypeString, tasks);
    [self cancelTasksWithFriendId:friendId tasks:tasks];
    [self createAndStartFileTransferTaskWithFriendId:friendId];
    [self showAllTasks];
}

- (void) cancelTasksWithFriendId:(NSString *)friendId tasks:(NSArray *)tasks{
    for (NSURLSessionTask *task in [self findTasksWithFriendId:friendId Tasks:tasks]){
        DebugLog(@"cancelling task: %@", [self friendIdWithTask:task]);
        [task cancel];
        [self showAllTasks];
    }
}

- (void) createAndStartFileTransferTaskWithFriendId:(NSString *)friendId{
    if (_transferType == TBM_FILE_TRANSFER_TYPE_UPLOAD) {
        [self createAndStartUploadTaskWithFriendId:friendId];
    } else {
        [self createAndStartDownloadTaskWithFriendId:friendId];
    }
}

- (void) createAndStartUploadTaskWithFriendId:(NSString *)friendId{
    DebugLog(@"createAndStartUploadTaskWithFriendId:%@ retrycount=%ld", friendId, (long)[self getRetryCountWithFriendId:friendId]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self tbmServerUrlWithFriendId:friendId]];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@", TBMHttpFormBoundary ] forHTTPHeaderField:@"Content-Type"];
    
    
    NSMutableString *preString =  [[NSMutableString alloc] init];
    [preString appendString:@"--"];
    [preString appendString:TBMHttpFormBoundary];
    [preString appendString:@"\r\n"];
    [preString appendString:@"Content-Disposition: form-data; name=\"file\"; filename=\"vid.mp4\"\r\n"];
    [preString appendString:@"Content-Type: video/mp4\r\n"];
    [preString appendString:@"Content-Transfer-Encoding: binary\r\n"];
    [preString appendString:@"\r\n"];
    
    NSString *postString =  [NSString stringWithFormat:@"\r\n--%@--\r\n", TBMHttpFormBoundary];
    
    NSMutableData *body = [[NSMutableData alloc] init];
    
    [body appendData:[preString dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithContentsOfURL:[TBMVideoRecorder outgoingVideoUrlWithFriendId:friendId]]];
    [body appendData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body writeToURL:[self fileUrlWithFriendId:friendId] atomically:YES];
    
    NSURLSessionTask *task = [[self session] uploadTaskWithRequest:request fromFile:[self fileUrlWithFriendId:friendId]];
    task.taskDescription = friendId;
    [task resume];
}

- (void) createAndStartDownloadTaskWithFriendId:(NSString *)friendId{
    DebugLog(@"createAndStartDownloadTaskWithFriendId:%@ retrycount=%ld", friendId, (long)[self getRetryCountWithFriendId:friendId]);
    NSURL *url = [self tbmServerUrlWithFriendId:friendId];
    NSURLSessionDownloadTask *task = [[self session] downloadTaskWithURL:url];
    task.taskDescription = friendId;
    [task resume];
}

// ---------------------
// Video status logging
// ---------------------
- (void) setStatusForSuccessfulFileTransferWithTask:(NSURLSessionTask *)task{
    DebugLog(@"setStatusForSuccessfulFileTransferWithTask");
    TBMFriend *friend = [self friendWithTask:task];
    if (_transferType == TBM_FILE_TRANSFER_TYPE_DOWNLOAD) {
        [friend setDownloadRetryCountWithInteger:0];
        [friend setAndNotifyIncomingVideoStatus:INCOMING_VIDEO_STATUS_DOWNLOADED];
    } else {
        [friend setUploadRetryCountWithInteger:0];
        [friend setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_UPLOADED];
    }
    [TBMFriend saveAll];
}

- (void) setStatusForFailedFIleTransferWithTask:(NSURLSessionTask *)task{
    TBMFriend *friend = [self friendWithTask:task];
    if (_transferType == TBM_FILE_TRANSFER_TYPE_DOWNLOAD) {
        [friend incrementDownloadRetryCount];
        [friend setAndNotifyIncomingVideoStatus:INCOMING_VIDEO_STATUS_DOWNLOADING];
    } else {
        [friend incrementUploadRetryCount];
        [friend setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_UPLOADING];
    }
    [TBMFriend saveAll];
}

- (void) setStatusForFileTransferStartWithFriendId:(NSString *)friendId{
    TBMFriend *friend = [TBMFriend findWithId:friendId];
    if (_transferType == TBM_FILE_TRANSFER_TYPE_DOWNLOAD) {
        [friend setAndNotifyIncomingVideoStatus:INCOMING_VIDEO_STATUS_DOWNLOADING];
    } else {
        [friend setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_UPLOADING];
    }
    [TBMFriend saveAll];
}

- (void) setStatusToUploadingNewWithFriend:(TBMFriend *)friend{
    [friend setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_NEW];
    [friend setUploadRetryCountWithInteger:0];
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

- (void)retryTaskAfterHoldoffWithFriendId:(NSString *)friendId{
    [self requestBackgroundTimeIfNeeded];
    DebugLog(@"Background time remaining = %f", [UIApplication sharedApplication].backgroundTimeRemaining);
    
    TBMFriend *friend = [TBMFriend findWithId:friendId];
    
    NSTimeInterval holdoff = [self retryHoldoffTimeIntervalWithFriend:friend];
    DebugLog(@"Will retry %@ for %@ after %f seconds.", _transferTypeString, friend.firstName, holdoff);
    [self performSelector:@selector(fileTransferWithFriendId:) withObject:friendId afterDelay:holdoff];
}

- (NSTimeInterval)retryHoldoffTimeIntervalWithFriend:(TBMFriend *)friend{
    NSInteger retryCount = [self getRetryCountWithFriend:friend];
    
    if (retryCount > 5)
        return (NSTimeInterval)10*(1<<5);
    
    return (NSTimeInterval)10*(1<<retryCount);
}

- (void) cancelOngoingRetries{
    [UIApplication cancelPreviousPerformRequestsWithTarget:self];
}

// This is used when the user makes the app active while there were tasks still pending retry with a long hold off.
// It is annoying to sit for a user to bring the app alive again and see messages pending upload and have to wait
// for the holdoff to end before he knows they will go out. This provides the ability to short circuit the holdoff
// and retry uploading immediately when the app becomes active. It us called in TBMAppDelegate applicationDidBecomeActive
- (void) restartTasksPendingRetry{
    [self cancelOngoingRetries];
    
    if (_transferType == TBM_FILE_TRANSFER_TYPE_DOWNLOAD) {
        for (TBMFriend *friend in [TBMFriend whereDownloadPendingRetry]){
            [self fileTransferWithFriendId:friend.idTbm];
        }
    } else {
        for (TBMFriend *friend in [TBMFriend whereUploadPendingRetry]){
            [self setStatusToUploadingNewWithFriend:friend];
            [self fileTransferWithFriendId:friend.idTbm];
        }
    }
}
                                                                                     

- (NSInteger)getRetryCountWithFriendId:(NSString *)friendId{
    return [self getRetryCountWithFriend:[TBMFriend findWithId:friendId]];
}
                                                                                     
- (NSInteger)getRetryCountWithFriend:(TBMFriend *)friend{
    return (_transferType == TBM_FILE_TRANSFER_TYPE_DOWNLOAD) ? [friend getDownloadRetryCount] : [friend getUploadRetryCount];
}

- (NSArray *)getFriendsPendingRetry{
    if (_transferType == TBM_FILE_TRANSFER_TYPE_DOWNLOAD) {
        return [TBMFriend whereDownloadPendingRetry];
    } else {
        return [TBMFriend whereUploadPendingRetry];
    }
}


// ===========================
// Session delegate callbacks.
// ===========================

// ------
// Upload
// ------

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    //    DebugLog(@"%@ Progress: task:%@, sent:%llu, of:%llu", _transferTypeString, task, totalBytesSent, totalBytesExpectedToSend);
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if ([self isSuccessfulTask:task]){
        // Dont use this callback for downloads use downloadTaskdidFinishDownloadingToURL below.
        // This callback is used in for both upload and download. Only use it for upload.
        if (_transferType == TBM_FILE_TRANSFER_TYPE_DOWNLOAD){
            return;
        }
        
        DebugLog(@"%@ for %@ successful", _transferTypeString, [self friendWithTask:task].firstName);
        [self setStatusForSuccessfulFileTransferWithTask:task];
    } else {
        NSString *friendId = [self friendIdWithTask:task];
        [self setStatusForFailedFIleTransferWithTask:task];
        
        // GARF this was done on main thread when I was experimenting with status changes not showing up.
        // Need to test not putting this on the main thread.
        [self performSelectorOnMainThread:@selector(retryTaskAfterHoldoffWithFriendId:) withObject:friendId waitUntilDone:YES];
    }
}

// --------
// Download
// --------
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    DebugLog(@"ERROR: downloadTask didResumeAtOffset. We should not be getting this callback.");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    TBMFriend *friend = [self friendWithTask:downloadTask];
    DebugLog(@"didFinishDownloadingToURL for %@", friend.firstName);
    [friend loadIncomingVideoWithUrl:location];
    [self setStatusForSuccessfulFileTransferWithTask:downloadTask];
}


// -------
// Session
// -------
/*
 If an application has received an -application:handleEventsForBackgroundURLSession:completionHandler: message, the session delegate will receive this message to indicate that all messages previously enqueued for this session have been delivered. We need to process all the completed tasks update the ui accordingly and invoke the completion handler so the os can take a picture of our app.
 */
- (void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    if ([session.configuration.identifier isEqualToString:[self sessionIdentifier]]){
        DebugLog(@"URLSessionDidFinishEventsForBackgroundURLSession - %@", _transferTypeString);
        
        if ([[self getFriendsPendingRetry] count] > 0)
            return;
        
        TBMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if (_transferType == TBM_FILE_TRANSFER_TYPE_DOWNLOAD) {
            if (appDelegate.backgroundDownloadSessionCompletionHandler){
                DebugLog(@"Calling backgroundUploadSessionCompletionHandler");
                appDelegate.backgroundDownloadSessionCompletionHandler();
                appDelegate.backgroundDownloadSessionCompletionHandler = nil;
            }
        } else {
            if (appDelegate.backgroundUploadSessionCompletionHandler){
                DebugLog(@"Calling backgroundUploadSessionCompletionHandler");
                appDelegate.backgroundUploadSessionCompletionHandler();
                appDelegate.backgroundUploadSessionCompletionHandler = nil;
            }
        }
        
        DebugLog(@"Flusing session %@.", [self session].configuration.identifier);
        [[self session] flushWithCompletionHandler:^{
            DebugLog(@"Flushed session shoul be using new socket.");
        }];
    }
}
@end

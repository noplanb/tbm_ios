//
//  TBMUploadManager.m
//  tbm
//
//  Created by Sani Elfishawy on 5/6/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate.h"
#import "TBMUploadManager.h"
#import "TBMVideoRecorder.h"
#import "TBMConfig.h"
#import "TBMUser.h"
#import "TBMHttpClient.h"
#import "TBMFriend.h"

static NSString * const TBMUploadManagerSessionIdentifier = @"com.noplanbees.tbm.backgroundUploadSession";
static NSString * const TBMHttpFormBoundary = @"*****tbm*****";
@implementation TBMUploadManager

//--------------
// Class methods
//--------------
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

// --------------------------
// Methods relating to upload
// --------------------------
- (void) uploadWithFriendId:(NSString *)friendId{
    DebugLog(@"uploadWithFriendId");
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
    DebugLog(@"createAndStartUploadTaskWithFriendId:%@", friendId);
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

// ---------------------------
// Session delegate callbacks.
// ---------------------------

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
//    DebugLog(@"Upload Progress: task:%@, sent:%llu, of:%llu", task, totalBytesSent, totalBytesExpectedToSend);
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error){
        DebugLog(@"taskDidComplete: %@ error: %@", task, [error localizedDescription]);
    } else {
        DebugLog(@"taskDidComplete: %@ success.", task);
        [self performSelectorOnMainThread:@selector(printTest) withObject:nil waitUntilDone:NO];
//        NSString *friendId = [self friendIdWithTask:task];
//        [self uploadWithFriendId:friendId];
    }
}

- (void) printTest{
    DebugLog(@"Timer1 fired");
    [self performSelector:@selector(delayedPrint) withObject:nil afterDelay:(NSTimeInterval)10];
}

- (void)delayedPrint{
    DebugLog(@"Timer2 fired");
    [self uploadWithFriendId:@"2"];
}

/*
 If an application has received an -application:handleEventsForBackgroundURLSession:completionHandler: message, the session delegate will receive this message to indicate that all messages previously enqueued for this session have been delivered. We need to process all the completed tasks update the ui accordingly and invoke the completion handler so the os can take a picture of our app.
 */
- (void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    if ([session.configuration.identifier isEqualToString:TBMUploadManagerSessionIdentifier]){
        DebugLog(@"URLSessionDidFinishEventsForBackgroundURLSession");
        TBMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        if (appDelegate.backgroundUploadSessionCompletionHandler){
//            appDelegate.backgroundUploadSessionCompletionHandler();
//            appDelegate.backgroundUploadSessionCompletionHandler = nil;
//        }
    }
}
@end

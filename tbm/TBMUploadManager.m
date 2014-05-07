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

static NSString * const TBMUploadManagerSessionIdentifier = @"com.noplanbees.tbm.backgroundUploadSession";

@implementation TBMUploadManager

//--------------
// Class methods
//--------------
+ (instancetype)sharedInstance{
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
    NSString *path = [NSString stringWithFormat:@"videos/create?receiverID=%@&userId=%@",friendId, user.idTbm];
    return [[TBMConfig tbmBaseUrl] URLByAppendingPathComponent:path];
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

// --------------------------
// Methods relating to upload
// --------------------------
- (void) uploadWithFriendId:(NSString *)friendId{
    [[self session] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        [self uploadWithFriendId:friendId uploadTasks:uploadTasks];
    }];
}

- (void) uploadWithFriendId:(NSString *)friendId uploadTasks:(NSArray *)uploadTasks{
    [self cancelUploadTaskWithFriendId:friendId uploadTasks:uploadTasks];
    [self stageOutgoingVideoFileWithFriendId:friendId];
    [self createAndStartUploadTaskWithFriendId:friendId];
}

- (void) cancelUploadTaskWithFriendId:(NSString *)friendId uploadTasks:(NSArray *)uploadTasks{
    NSURLSessionUploadTask * task = [self uploadTaskWithFriendId:friendId uploadTasks:uploadTasks];
    if (task){
        task.taskDescription = nil;
        [task cancel];
    }
}

- (NSURLSessionUploadTask *) uploadTaskWithFriendId:(NSString *)friendId uploadTasks:(NSArray *)uploadTasks{
    for (NSURLSessionUploadTask *task in uploadTasks){
        if (task.description == friendId) {
            return task;
        }
    }
    return nil;
}

- (void) stageOutgoingVideoFileWithFriendId:(NSString *)friendId{
    NSURL *outgoingVideoUrl = [TBMVideoRecorder outgoingVideoUrlWithFriendId:friendId];
    NSURL *uploadingVideoUrl = [TBMUploadManager uploadingVideoUrlWithFriendId:friendId];
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtURL:uploadingVideoUrl error:&error];
    [fm moveItemAtURL:outgoingVideoUrl toURL:uploadingVideoUrl error:&error];
    if (error){
        DebugLog(@"stageOutgoingVideoFileWithFriendId: Error this should never happen: %@", error);
    }
}

- (void) createAndStartUploadTaskWithFriendId:(NSString *)friendId{
    NSURLRequest *request = [NSURLRequest requestWithURL:[TBMUploadManager tbmServerUploadUrl]];
    NSURLSessionUploadTask *task = [[self session] uploadTaskWithRequest:request fromFile:[TBMUploadManager uploadingVideoUrlWithFriendId:friendId]];
    task.taskDescription = friendId;
    [task resume];
}

// ---------------------------
// Session delegate callbacks.
// ---------------------------

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    DebugLog(@"Upload Progress: task:%@, sent:%llu, of:%llu", task, totalBytesSent, totalBytesExpectedToSend);
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error){
        DebugLog(@"task didCompleteWithError: %@ completed with error: %@", task, [error localizedDescription]);
    } else {
        DebugLog(@"task didCompleteWithError: %@ completed with successfully.", task);
    }
}

/*
 If an application has received an -application:handleEventsForBackgroundURLSession:completionHandler: message, the session delegate will receive this message to indicate that all messages previously enqueued for this session have been delivered. We need to process all the completed tasks update the ui accordingly and invoke the completion handler so the os can take a picture of our app.
 */
- (void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    [[self session] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        DebugLog(@"URLSessionDidFinishEventsForBackgroundURLSession: tasks: %@", uploadTasks);
    }];
    
}
@end

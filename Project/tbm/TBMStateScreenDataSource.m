//
// Created by Maksim Bazarov on 28.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMStateScreenDataSource.h"
#import "TBMVideo.h"
#import "TBMFriend.h"
#import "TBMFriendVideosInformation.h"
#import "TBMConfig.h"
#import "TBMVideoObject.h"

NSString *status(TBMOutgoingVideoStatus status);

@interface TBMStateScreenDataSource ()
@property(nonatomic, strong) NSMutableArray *notDanglingFiles;
@end

@implementation TBMStateScreenDataSource {

}
#pragma mark - Helpers

NSString *outgoing_status(TBMOutgoingVideoStatus status) {
    NSArray *statuses = @[
            @"OUTGOING_VIDEO_STATUS_NONE",
            @"OUTGOING_VIDEO_STATUS_NEW",
            @"OUTGOING_VIDEO_STATUS_QUEUED",
            @"OUTGOING_VIDEO_STATUS_UPLOADING",
            @"OUTGOING_VIDEO_STATUS_UPLOADED",
            @"OUTGOING_VIDEO_STATUS_DOWNLOADED",
            @"OUTGOING_VIDEO_STATUS_VIEWED",
            @"OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY]"
    ];

    return statuses[status];
}

NSString *incoming_status(TBMIncomingVideoStatus status) {
    NSArray *statuses = @[
            @"INCOMING_VIDEO_STATUS_NEW",
            @"INCOMING_VIDEO_STATUS_DOWNLOADING",
            @"INCOMING_VIDEO_STATUS_DOWNLOADED",
            @"INCOMING_VIDEO_STATUS_VIEWED",
            @"INCOMING_VIDEO_STATUS_FAILED_PERMANENTLY"
    ];
    return statuses[status];
}

BOOL containID(NSString *fileName, NSString *fileId) {
    NSUInteger location = [fileName rangeOfString:fileId].location;
    BOOL result = location != NSNotFound;
    return result;
}

- (void)loadFriendsVideoObjects {
    self.notDanglingFiles = [@[] mutableCopy];
    NSMutableArray *friendsFiles = [@[] mutableCopy];

    for (TBMFriend *friend in [TBMFriend all]) {
        TBMFriendVideosInformation *information = [[TBMFriendVideosInformation alloc] init];

        information.name = friend.fullName;
        TBMVideoObject *videoObject;
        // Make incoming array
        NSMutableArray *incomingObjects = [@[] mutableCopy];
        for (TBMVideo *video in friend.videos) {
            videoObject = [TBMVideoObject makeVideoObjectWithVideoID:video.videoId
                                                              status:incoming_status(video.statusValue)];
            if (videoObject) {
                [incomingObjects addObject:videoObject];
                [self.notDanglingFiles addObject:video.videoId];
            }
        }
        information.incomingObjects = incomingObjects;

        // Make outgoing object

        videoObject = [TBMVideoObject makeVideoObjectWithVideoID:friend.outgoingVideoId
                                                          status:outgoing_status(friend.outgoingVideoStatusValue)];
        if (videoObject) {
            information.outgoingObjects = @[videoObject];
            [self.notDanglingFiles addObject:friend.outgoingVideoId];
        }

        [friendsFiles addObject:information];
    }

    self.friendsVideoObjects = friendsFiles;

}


- (void)loadVideos {
    NSURL *videoDirURL = [TBMConfig videosDirectoryUrl];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:videoDirURL
                                   includingPropertiesForKeys:@[]
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:nil];


    NSPredicate *predicate;
    //enumerate all outgoing files
    NSMutableArray *outgoingVideos = [@[] mutableCopy];
    predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'mov' "];
    for (NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate]) {
        NSString *fileUrlString = [fileURL lastPathComponent];
        [outgoingVideos addObject:fileUrlString];
    }
    //enumerate all incoming files
    NSMutableArray *incomingVideos = [@[] mutableCopy];
    predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'mp4' "];
    for (NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate]) {
        NSString *fileUrlString = [fileURL lastPathComponent];
        [incomingVideos addObject:fileUrlString];
    }

    self.incomingFiles = incomingVideos;
    self.outgoingFiles = outgoingVideos;
}

- (void)excludeNonDanglingFiles {
    NSLog(@"DELETE %@", self.notDanglingFiles);
    NSMutableArray *incomingVideos = [self.incomingFiles mutableCopy];
    NSMutableArray *outgoingVideos = [self.outgoingFiles mutableCopy];

    NSInteger indexForDelete;

    for (NSString *file in self.notDanglingFiles)
    {
        indexForDelete = -1;
        
        for (NSInteger i = 0; i < incomingVideos.count; i++)
        {
            if (containID(incomingVideos[i], file))
            {
                indexForDelete = i;
            }
        }
        
        if (indexForDelete > -1) [incomingVideos removeObjectAtIndex:indexForDelete];
    }

    for (NSString *file in self.notDanglingFiles) {
        indexForDelete = -1;
        for (NSInteger i = 0; i < outgoingVideos.count; i++) {
            if (containID(outgoingVideos[i], file)) {
                indexForDelete = i;
                NSLog(@"File %@ must be deleted", outgoingVideos[i]);
            }
        }
        if (indexForDelete > -1) [outgoingVideos removeObjectAtIndex:indexForDelete];
    }

    self.incomingFiles = incomingVideos;
    self.outgoingFiles = outgoingVideos;

}


@end


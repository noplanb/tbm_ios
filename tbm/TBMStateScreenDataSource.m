//
// Created by Maksim Bazarov on 28.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMStateScreenDataSource.h"
#import "TBMVideo.h"
#import "TBMFriend.h"
#import "TBMFriendVideos.h"
#import "TBMConfig.h"

NSString *status(TBMOutgoingVideoStatus status);

@interface TBMStateScreenDataSource ()
@property(nonatomic, strong) NSMutableArray *notDanglingFiles;
@end

@implementation TBMStateScreenDataSource {

}

BOOL containID(NSString *fileName, NSString *fileId) {
    NSUInteger location = [fileName rangeOfString:fileId].location;
    BOOL result = location != NSNotFound;
    return result;
}

- (void)loadFriendsVideos {
    self.notDanglingFiles = [@[] mutableCopy];
    NSMutableArray *friendsFiles = [@[] mutableCopy];

    for (TBMFriend *friend in [TBMFriend all]) {
        TBMFriendVideos *friendVideos = [[TBMFriendVideos alloc] init];
        NSString *firstName = friend.firstName ? friend.firstName : @"";
        NSString *lastName = friend.lastName ? friend.firstName : @"";
        NSMutableString *name = [[firstName stringByAppendingString:@" "] mutableCopy];
        [name appendString:lastName];

        friendVideos.name = name;
        NSMutableArray *incomingVideos = [@[] mutableCopy];

        for (TBMVideo *video in friend.videos) {
            [incomingVideos addObject:video];
            [self.notDanglingFiles addObject:video.videoId];

        }
        friendVideos.incomingVideos = incomingVideos;

        friendVideos.outgoingVideoId = friend.outgoingVideoId;
        if (friendVideos.outgoingVideoId) {
            [self.notDanglingFiles addObject:friend.outgoingVideoId];
        }
        friendVideos.outgoingVideoStatus = friend.outgoingVideoStatus;

        [friendsFiles addObject:friendVideos];
    }

    self.friendsFiles = friendsFiles;

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

    NSInteger indexForDelete = -1;

    for (NSString *file in self.notDanglingFiles) {
        for (NSInteger i = 0; i < incomingVideos.count; i++) {
            if (containID(incomingVideos[i], file)) {
                indexForDelete = i;
            }
        }
    }
    if (indexForDelete > -1) [incomingVideos removeObjectAtIndex:indexForDelete];

    indexForDelete = -1;

    for (NSString *file in self.notDanglingFiles) {
        for (NSInteger i = 0; i < outgoingVideos.count; i++) {

            if (containID(outgoingVideos[i], file)) {
                indexForDelete = i;
                NSLog(@"File %@ must be deleted", outgoingVideos[i]);
            }
        }
    }
    if (indexForDelete > -1) [outgoingVideos removeObjectAtIndex:indexForDelete];

    self.incomingFiles = incomingVideos;
    self.outgoingFiles = outgoingVideos;

}


@end


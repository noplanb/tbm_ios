//
//  ZZDebugStateInteractor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZDebugStateInteractor.h"
#import "TBMFriend.h"
#import "TBMFriendVideosInformation.h"
#import "TBMVideoObject.h"
#import "ZZDebugStateEnumHelper.h"

@implementation ZZDebugStateInteractor

//- (void)presentStateScreen {
//
//    TBMStateScreenViewController* stateScreen = [[TBMStateScreenViewController alloc] init];
//
//    TBMStateScreenDataSource *data = [[TBMStateScreenDataSource alloc] init];
//    [data loadFriendsVideoObjects];
//    [data loadVideos];
//    [data excludeNonDanglingFiles];
//    [self.stateScreen updateUserInterfaceWithData:data];
//    [self.navigationController pushViewController:stateScreen animated:YES];
//}
//
//
//BOOL containID(NSString *fileName, NSString *fileId) {
//    NSUInteger location = [fileName rangeOfString:fileId].location;
//    BOOL result = location != NSNotFound;
//    return result;
//}
//
//- (void)loadFriendsVideoObjects
//{
//    NSMutableArray* notDanglingFiles = [NSMutableArray array];
//    NSMutableArray *friendsFiles = [NSMutableArray array];
//    
//    for (TBMFriend *friend in [TBMFriend all])
//    {
//        TBMFriendVideosInformation *information = [[TBMFriendVideosInformation alloc] init];
//        
//        information.name = friend.fullName;
//        TBMVideoObject *videoObject;
//        // Make incoming array
//        NSMutableArray *incomingObjects = [@[] mutableCopy];
//        for (TBMVideo *video in friend.videos) {
//            videoObject = [TBMVideoObject makeVideoObjectWithVideoID:video.videoId
//                                                              status:ZZVideoIncomingStatusStringFromEnumValue(video.statusValue)];
//            if (videoObject)
//            {
//                [incomingObjects addObject:videoObject];
//                [notDanglingFiles addObject:video.videoId];
//            }
//        }
//        information.incomingObjects = incomingObjects;
//        
//        // Make outgoing object
//        
//        videoObject = [TBMVideoObject makeVideoObjectWithVideoID:friend.outgoingVideoId
//                                                          status:ZZVideoOutgoingStatusStringFromEnumValue(friend.outgoingVideoStatusValue)];
//        if (videoObject) {
//            information.outgoingObjects = @[videoObject];
//            [notDanglingFiles addObject:friend.outgoingVideoId];
//        }
//        
//        [friendsFiles addObject:information];
//    }
//    
////    self.friendsVideoObjects = friendsFiles;
//    
//}
//
//
//- (void)loadVideos
//{
//
//    
//    
//    
//}
//
//- (NSArray*)_loadVideoFilesWithPredicate:(NSPredicate*)predicate
//{
//    NSURL *videoDirURL = [self _videosDirectoryUrl];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *contents = [fileManager contentsOfDirectoryAtURL:videoDirURL
//                                   includingPropertiesForKeys:@[]
//                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
//                                                        error:nil];
//
//    contents = [contents filteredArrayUsingPredicate:predicate];
//   
//    return [[contents.rac_sequence map:^id(NSURL* value) {
//        return [value lastPathComponent];
//    }] array];
//}
//
//- (void)excludeNonDanglingFiles:(NSArray*)notDanglingFiles
//{
//    NSPredicate* outgoingPredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'mov'"];
//    NSPredicate* incomingPredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'mp4'"];
//    
//    NSMutableArray *incomingVideos = [[self _loadVideoFilesWithPredicate:incomingPredicate] mutableCopy];
//    NSMutableArray *outgoingVideos = [[self _loadVideoFilesWithPredicate:outgoingPredicate] mutableCopy];
//    
//    NSInteger indexForDelete;
//    
//    for (NSString *file in notDanglingFiles)
//    {
//        indexForDelete = -1;
//        for (NSInteger i = 0; i < incomingVideos.count; i++)
//        {
//            if (containID(incomingVideos[i], file))
//            {
//                indexForDelete = i;
//            }
//        }
//        if (indexForDelete > -1) [incomingVideos removeObjectAtIndex:indexForDelete];
//    }
//    
//    for (NSString *file in self.notDanglingFiles)
//    {
//        indexForDelete = -1;
//        for (NSInteger i = 0; i < outgoingVideos.count; i++)
//        {
//            if (containID(outgoingVideos[i], file))
//            {
//                indexForDelete = i;
//                NSLog(@"File %@ must be deleted", outgoingVideos[i]);
//            }
//        }
//        if (indexForDelete > -1) [outgoingVideos removeObjectAtIndex:indexForDelete];
//    }
//    
//    self.incomingFiles = incomingVideos;
//    self.outgoingFiles = outgoingVideos;
//    
//}
//

#pragma mark - Private

- (NSURL*)_videosDirectoryUrl
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}


@end

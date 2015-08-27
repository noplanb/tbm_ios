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
#import "ZZDebugStateDomainModel.h"
#import "ZZDebugStateItemDomainModel.h"
#import "NSObject+ANSafeValues.h"

@implementation ZZDebugStateInteractor

- (void)loadData
{
    ZZDebugStateDomainModel* model = [ZZDebugStateDomainModel new];
    [self.output dataLoaded:model];
}


#pragma mark - Private

- (void)_loadVideoData
{
    NSArray* friends = [TBMFriend all];
    
    friends = [[friends.rac_sequence map:^id(TBMFriend* value) {
        
        ZZDebugStateDomainModel* model = [ZZDebugStateDomainModel new];
        
        model.username = value.fullName;
        model.incomingVideoItems = [[value.videos.rac_sequence map:^id(TBMVideo* videoEntity) {
            
            ZZDebugStateItemDomainModel* itemModel = [ZZDebugStateItemDomainModel new];
            itemModel.itemID = videoEntity.videoId;
            itemModel.status = ZZVideoIncomingStatusStringFromEnumValue(videoEntity.statusValue);
            return itemModel;
            
        }] array];
        
        ZZDebugStateItemDomainModel* outgoing = [ZZDebugStateItemDomainModel new];
        outgoing.itemID = value.outgoingVideoId;
        outgoing.status = ZZVideoOutgoingStatusStringFromEnumValue(value.outgoingVideoStatusValue);
        
        model.outgoingVideoItems = @[outgoing];
        
        
        
        
        return model;
        
    }] array];
}


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



- (void)loadFriendsVideoObjects
{
    NSMutableArray* notDanglingFiles = [NSMutableArray array];
    NSMutableArray *friendsFiles = [NSMutableArray array];
    
    for (TBMFriend *friend in [TBMFriend all])
    {
        TBMFriendVideosInformation *information = [[TBMFriendVideosInformation alloc] init];
        information.name = friend.fullName;
        
        
        
        TBMVideoObject *videoObject;
       
        // Make incoming array
        NSMutableArray *incomingObjects = [NSMutableArray array];
        for (TBMVideo *video in friend.videos)
        {
            videoObject = [TBMVideoObject makeVideoObjectWithVideoID:video.videoId
                                                              status:ZZVideoIncomingStatusStringFromEnumValue(video.statusValue)];
            if (videoObject)
            {
                [incomingObjects addObject:videoObject];
                [notDanglingFiles addObject:video.videoId];
            }
        }
        information.incomingObjects = incomingObjects;
        
        // Make outgoing object
        
        videoObject = [TBMVideoObject makeVideoObjectWithVideoID:friend.outgoingVideoId
                                                          status:ZZVideoOutgoingStatusStringFromEnumValue(friend.outgoingVideoStatusValue)];
        if (videoObject) {
            information.outgoingObjects = @[videoObject];
            [notDanglingFiles addObject:friend.outgoingVideoId];
        }
        
        [friendsFiles addObject:information];
    }
    
//    self.friendsVideoObjects = friendsFiles;
    
}


- (void)_excludeNonDanglingFiles:(NSArray*)notDanglingFiles
{
    NSPredicate* outgoingPredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'mov'"];
    NSPredicate* incomingPredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'mp4'"];
    
    __block NSArray *incomingVideos = [self _loadVideoFilesWithPredicate:incomingPredicate];
    __block NSArray *outgoingVideos = [self _loadVideoFilesWithPredicate:outgoingPredicate];
    
    [notDanglingFiles enumerateObjectsUsingBlock:^(NSString* file, NSUInteger idx, BOOL *stop) {
        
        incomingVideos = [[incomingVideos.rac_sequence map:^id(NSString* value) {
            
            BOOL isContains = ([value rangeOfString:file].location != NSNotFound);
            return isContains ? nil : value;
        }] array];
        
        outgoingVideos = [[outgoingVideos.rac_sequence map:^id(NSString* value) {
            
            BOOL isContains = ([value rangeOfString:file].location != NSNotFound);
            return isContains ? nil : value;
        }] array];
    }];
}

- (NSArray*)_loadVideoFilesWithPredicate:(NSPredicate*)predicate
{
    NSURL *videoDirURL = [self _videosDirectoryUrl];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:videoDirURL
                                   includingPropertiesForKeys:@[]
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:nil];
    
    contents = [contents filteredArrayUsingPredicate:predicate];
    
    return [[contents.rac_sequence map:^id(NSURL* value) {
        return [value lastPathComponent];
    }] array];
}


#pragma mark - Private

- (NSURL*)_videosDirectoryUrl
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

@end

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
    NSArray* stateModels = [self _loadVideoData];
 
    NSArray* incomeDandling = [self _loadIncomeDandlingItemsFromDataBaseData:stateModels];
    NSArray* outcomeDandling = [self _loadOutgoingDandlingItemsFromDataBaseData:stateModels];
    
//    [self.output dataLoaded:model];
}


#pragma mark - Private

- (NSArray*)_loadVideoData
{
    NSArray* friends = [TBMFriend all];
    
    NSArray* videoStateModels = [[friends.rac_sequence map:^id(TBMFriend* value) {
        return [self _debugModelFromUserEntity:value];
    }] array];
    
    return videoStateModels;
}

- (NSArray*)_loadIncomeDandlingItemsFromDataBaseData:(NSArray*)stateModels
{
    NSPredicate* incomingPredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'mp4'"]; // TODO: constant
    NSArray* diskFileNamesIncoming = [self _loadVideoFilesWithPredicate:incomingPredicate];
    NSMutableSet* diskFileNamesIncomingSet = [NSMutableSet setWithArray:diskFileNamesIncoming];
    
    NSArray* dataBaseFileNamesIncoming = [stateModels valueForKeyPath:@"incomingVideoItems"]; // TODO: enum
    NSSet* databaseFileNamesIncomingSet = [NSSet setWithArray:dataBaseFileNamesIncoming];
    
    [diskFileNamesIncomingSet minusSet:databaseFileNamesIncomingSet];
    
    return [diskFileNamesIncomingSet allObjects];
}

- (NSArray*)_loadOutgoingDandlingItemsFromDataBaseData:(NSArray*)stateModels
{
    NSPredicate* incomingPredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'mov'"];
    NSArray* diskFileNamesIncoming = [self _loadVideoFilesWithPredicate:incomingPredicate];
    NSMutableSet* diskFileNamesIncomingSet = [NSMutableSet setWithArray:diskFileNamesIncoming];
    
    NSArray* dataBaseFileNamesIncoming = [stateModels valueForKeyPath:@"outgoingVideoItems"];
    NSSet* databaseFileNamesIncomingSet = [NSSet setWithArray:dataBaseFileNamesIncoming];
    
    [diskFileNamesIncomingSet minusSet:databaseFileNamesIncomingSet];
    
    return [diskFileNamesIncomingSet allObjects];
}


- (ZZDebugStateDomainModel*)_debugModelFromUserEntity:(TBMFriend*)value
{
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

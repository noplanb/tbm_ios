//
//  ZZApplicationStateInfoGenerator.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/19/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZApplicationStateInfoGenerator.h"
#import "ZZDebugSettingsStateDomainModel.h"
#import "ZZStoredSettingsManager.h"
#import "ZZAPIRoutes.h"
#import "ZZUserDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZFriendDomainModel.h"
#import "ZZApplicationStateInfoConstants.h"
#import "ZZThumbnailGenerator.h"
#import "ZZVideoDomainModel.h"
#import "ZZDebugFriendStateDomainModel.h"
#import "ZZDebugVideoStateDomainModel.h"

static NSInteger const kStateStringColumnWidth = 14;

@implementation ZZApplicationStateInfoGenerator

+ (ZZDebugSettingsStateDomainModel*)generateSettingsModel
{
    ZZStoredSettingsManager* manager = [ZZStoredSettingsManager shared];
    ZZDebugSettingsStateDomainModel* model = [ZZDebugSettingsStateDomainModel new];
    model.isDebugEnabled = manager.debugModeEnabled;
    model.serverURLString = apiBaseURL();
    model.serverIndex = manager.serverEndpointState;
    model.useRollbarSDK = manager.shouldUseRollBarSDK;
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    model.version = [NSString stringWithFormat:@"%@(%@) - %@",
                     [NSObject an_safeString:version],
                     [NSObject an_safeString:buildNumber],
                     kGlobalApplicationVersion];
    
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
    model.firstName = user.firstName;
    model.lastName = user.lastName;
    model.phoneNumber = user.mobileNumber;
    
    return model;
}

+ (NSString*)generateSettingsStateMessage
{
    ZZDebugSettingsStateDomainModel* model = [ZZApplicationStateInfoGenerator generateSettingsModel];;
    
    NSMutableString *message = [NSMutableString stringWithString:@"\n * DEBUG SCREEN DATA * * * * * * \n * "];
    
    [message appendFormat:@"Version:        %@\n", [NSObject an_safeString:model.version]];
    [message appendFormat:@"First Name:     %@\n", [NSObject an_safeString:model.firstName]];
    [message appendFormat:@"Last Name:      %@\n", [NSObject an_safeString:model.lastName]];
    [message appendFormat:@"Phone:          %@\n", [NSObject an_safeString:model.phoneNumber]];
    [message appendFormat:@"Debug mode:     %@\n", model.isDebugEnabled ? @"ON" : @"OFF"];
    [message appendFormat:@"Server State:   %@\n", ZZServerFormattedStringFromEnumValue(model.serverIndex)];
    [message appendFormat:@"Server address: %@\n", [NSObject an_safeString:model.serverURLString]];
    [message appendFormat:@"Dispatch Type:  %@\n", ([ZZStoredSettingsManager shared].shouldUseRollBarSDK) ? @"RollBar SDK" : @"Server"];
    
    [message appendString:@"\n * * * * * * * * * * * * * * * * * * * * * * * * \n"];
    
    return message;
}


#pragma mark - State 

+ (NSString*)globalStateString
{
    NSArray *friends = [ZZFriendDataProvider loadAllFriends];
    
    NSMutableString *stateString = [NSMutableString new];
    [stateString appendString:[self _friendsStateStringWithModels:friends]];
    [stateString appendFormat:@"\n%@", [self _videosStateStringWithFriendModels:friends]];
    
    return stateString;
}

#pragma mark - Dangling Videos

+ (NSArray*)loadVideoDataWithFriendsModels:(NSArray*)friends
{
    NSArray* videoStateModels = [[friends.rac_sequence map:^id(ZZFriendDomainModel* value) {
        return [self _debugModelFromUserEntity:value];
    }] array];
    
    return videoStateModels;
}

+ (NSArray*)loadIncomingDandlingItemsFromData:(NSArray*)stateModels
{
    NSPredicate* incomingPredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'mp4'"];
    NSArray* diskFileNamesIncoming = [self _loadVideoFilesWithPredicate:incomingPredicate];
    
    diskFileNamesIncoming = [[diskFileNamesIncoming.rac_sequence map:^id(NSString* value) {
        NSString* lastComponent = [[value componentsSeparatedByString:@"_"] lastObject];
        return [[lastComponent componentsSeparatedByString:@"."] firstObject];
    }] array];
    
    NSMutableSet* diskFileNamesIncomingSet = [NSMutableSet setWithArray:diskFileNamesIncoming];
    
    NSArray* dataBaseFileNamesIncoming = [stateModels valueForKeyPath:ZZDebugFriendStateDomainModelAttributes.incomingVideoItems];
    
    __block NSMutableArray* videoIDs = [NSMutableArray array];
    
    [dataBaseFileNamesIncoming enumerateObjectsUsingBlock:^(NSArray*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!ANIsEmpty(obj) && ![obj isKindOfClass:[NSNull class]])
        {
            [obj enumerateObjectsUsingBlock:^(ZZDebugVideoStateDomainModel*  _Nonnull modelVideo, NSUInteger idx, BOOL * _Nonnull stop) {
                [videoIDs addObject:modelVideo.itemID];
            }];
        }
    }];
    
    
    NSSet* databaseFileNamesIncomingSet = [NSSet setWithArray:videoIDs];
    [diskFileNamesIncomingSet minusSet:databaseFileNamesIncomingSet];
    
    return [diskFileNamesIncomingSet allObjects];
}

+ (NSArray*)loadOutgoingDandlingItemsFromData:(NSArray*)stateModels
{
    NSPredicate* incomingPredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'mov'"];
    NSArray* diskFileNamesOutgoing = [self _loadVideoFilesWithPredicate:incomingPredicate];
    
    diskFileNamesOutgoing = [[diskFileNamesOutgoing.rac_sequence map:^id(NSString* value) {
        NSString* lastComponent = [[value componentsSeparatedByString:@"_"] lastObject];
        return [[lastComponent componentsSeparatedByString:@"."] firstObject];
    }] array];
    
    NSMutableSet* diskFileNamesOutgoingSet = [NSMutableSet setWithArray:diskFileNamesOutgoing];
    
    NSArray* dataBaseFileNamesIncoming = [stateModels valueForKeyPath:ZZDebugFriendStateDomainModelAttributes.outgoingVideoItems];
    
    __block NSMutableArray* videoIDs = [NSMutableArray array];
    
    [dataBaseFileNamesIncoming enumerateObjectsUsingBlock:^(NSArray*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!ANIsEmpty(obj) && ![obj isKindOfClass:[NSNull class]])
        {
            [obj enumerateObjectsUsingBlock:^(ZZDebugVideoStateDomainModel*  _Nonnull modelVideo, NSUInteger idx, BOOL * _Nonnull stop) {
                [videoIDs addObject:modelVideo.itemID];
            }];
        }
    }];
    
    NSSet* databaseFileNamesOutgoingSet = [NSSet setWithArray:dataBaseFileNamesIncoming];
    
    [diskFileNamesOutgoingSet minusSet:databaseFileNamesOutgoingSet];
    
    return [diskFileNamesOutgoingSet allObjects];
}

#pragma mark - Friends

+ (NSString*)_friendsStateStringWithModels:(NSArray*)friends
{
    NSArray* items = @[@"Name", @"ID", @"Has app", @"IV status", @"OV ID", @"OV status", @"Last event", @"Has thumb", @"Download"];
    NSString* titleString = [self _stateTitleForTableName:@"Friends" columnsCount:items.count];
    NSString* stateHeaderString = [self _stateRowForItems:items];
    
    NSMutableString *result = [NSMutableString new];
    [result appendFormat:@"%@\n", titleString];
    [result appendFormat:@"%@\n", stateHeaderString];
    
    for (ZZFriendDomainModel* friendModel in friends)
    {
        [result appendFormat:@"%@\n", [self _friendStateStringWithModel:friendModel]];
    }
    return result;
}

+ (NSString*)_friendStateStringWithModel:(ZZFriendDomainModel*)friendModel
{
    NSMutableArray *items = [NSMutableArray new];

    [items addObject:[friendModel fullName]];
    [items addObject:[NSObject an_safeString:friendModel.idTbm]];
    [items addObject:(friendModel.hasApp) ? @"true" : @"false"];
    [items addObject:ZZIncomingVideoInfoStringFromEnumValue(friendModel.lastIncomingVideoStatus)];
    [items addObject:[NSObject an_safeString:friendModel.outgoingVideoItemID]];
    [items addObject:ZZOutgoingVideoInfoStringFromEnumValue(friendModel.lastOutgoingVideoStatus)];
    
    BOOL isOutgoing = (friendModel.lastVideoStatusEventType == ZZVideoStatusEventTypeOutgoing);
    [items addObject:isOutgoing ? @"OUT" : @"IN"];
    
    [items addObject:(![ZZThumbnailGenerator isThumbNoPicForUser:friendModel]) ? @"true" : @"false"];
//    [items addObject:(![friendModel hasDownloadingVideo]) ? @"true" : @"false"]; //TODO:
    
    return [self _stateRowForItems:items];
}


#pragma mark - Videos

+ (NSString*)_videosStateStringWithFriendModels:(NSArray*)friends
{
    friends = [self loadVideoDataWithFriendsModels:friends];
    
    NSArray* items = @[@"Name", @"ID", @"status"];
    NSString* titleString = [self _stateTitleForTableName:@"VideoObjects" columnsCount:items.count];
    NSString* stateHeaderString = [self _stateRowForItems:items];
    
    NSMutableString *result = [NSMutableString new];
    [result appendFormat:@"%@\n", titleString];
    [result appendFormat:@"%@\n", stateHeaderString];
    
    for (ZZDebugFriendStateDomainModel* friendModel in friends)
    {
        if ((friendModel.outgoingVideoItems.count + friendModel.incomingVideoItems.count) > 0)
        {
            NSArray* rowFriendItems = @[[NSObject an_safeString:friendModel.username]];
            NSString* stateString = [self _stateRowForItems:rowFriendItems];
            [result appendFormat:@"%@\n", stateString];
            
            for (ZZDebugVideoStateDomainModel* videoModel in friendModel.incomingVideoItems)
            {
                [result appendFormat:@"%@", [self _stateForVideo:videoModel]];
            }
            for (ZZDebugVideoStateDomainModel* videoModel in friendModel.outgoingVideoItems)
            {
                [result appendFormat:@"%@", [self _stateForVideo:videoModel]];
            }
        }
    }
    
    //dangling files
    [result appendString:@"\n\nDangling files\n"];
    
    NSArray* incomingDangling = [self loadIncomingDandlingItemsFromData:friends];
    [result appendFormat:@"Incoming (%ld)\n", (long)incomingDangling.count];
    for (NSString *videoID in incomingDangling)
    {
        [result appendFormat:@"%@\n", videoID];
    }
    
    NSArray* outgoingDangling = [self loadOutgoingDandlingItemsFromData:friends];
    [result appendFormat:@"Outgoing (%ld)\n", (long)outgoingDangling.count];
    for (NSString *videoID in outgoingDangling)
    {
        [result appendFormat:@"%@\n", videoID];
    }

    return result;
}

+ (NSString*)_stateForVideo:(ZZDebugVideoStateDomainModel*)model
{
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:@""];
    [items addObject:[NSObject an_safeString:model.itemID]];
    [items addObject:[NSObject an_safeString:model.status]];
    
    return [self _stateRowForItems:items];
}


#pragma mark - Dangling Videos

+ (ZZDebugFriendStateDomainModel*)_debugModelFromUserEntity:(ZZFriendDomainModel*)value
{
    ZZDebugFriendStateDomainModel* model = [ZZDebugFriendStateDomainModel new];
    
    model.username = value.fullName;
    model.incomingVideoItems = [[value.videos.rac_sequence map:^id(ZZVideoDomainModel* videoEntity) {
        
        NSString* status = ZZVideoIncomingStatusStringFromEnumValue(videoEntity.incomingStatusValue);
        ZZDebugVideoStateDomainModel* itemModel = [ZZDebugVideoStateDomainModel itemWithItemID:videoEntity.videoID
                                                                                      status:status];
        return itemModel;
        
    }] array];
    
    if (!ANIsEmpty(value.outgoingVideoItemID))
    {
        NSString* status = ZZVideoOutgoingStatusStringFromEnumValue(value.lastOutgoingVideoStatus);
        ZZDebugVideoStateDomainModel* outgoing = [ZZDebugVideoStateDomainModel itemWithItemID:value.outgoingVideoItemID
                                                                                       status:status];
        model.outgoingVideoItems = @[outgoing];
    }
    
    return model;
}

+ (NSArray*)_loadVideoFilesWithPredicate:(NSPredicate*)predicate
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

+ (NSURL*)_videosDirectoryUrl
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}


#pragma mark - Common

+ (NSString*)_stateTitleForTableName:(NSString*)string columnsCount:(NSInteger)columnsCount
{
    NSInteger titleWidth = (kStateStringColumnWidth + 2) * columnsCount + (columnsCount - 3);
    NSString *format = [NSString stringWithFormat:@"| %%-%ld.%lds |", (long)titleWidth, (long)titleWidth];
    return [NSString stringWithFormat:format, string.UTF8String];
}

+ (NSString*)_stateRowForItems:(NSArray*)items
{
    NSMutableString *row = [NSMutableString new];
    NSString *format = [NSString stringWithFormat:@"%%-%ld.%lds", (long)kStateStringColumnWidth, (long)kStateStringColumnWidth];
    
    for (NSString *item in items)
    {
        NSString *shortItem = item;
        
        if (shortItem.length > kStateStringColumnWidth)
        {
            shortItem = [shortItem substringToIndex:kStateStringColumnWidth];
        }
        [row appendFormat:@"| %@ ", [NSString stringWithFormat:format, shortItem.UTF8String]];
    }
    [row appendString:@"|"];
    return row;
}

@end

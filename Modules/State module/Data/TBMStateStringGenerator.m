//
//  TBMStateScreenGenerator.m
//  Zazo
//
//  Created by Sema Belokovsky on 17/08/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMStateStringGenerator.h"
#import "TBMFriend+StateProtocol.h"
#import "TBMStateDataSource.h"
#import "TBMVideoObject.h"
#import "TBMFriendVideosInformation.h"

@implementation TBMStateStringGenerator

+ (NSString *)stateString {
    TBMStateDataSource *ds = [TBMStateDataSource new];
    return [self stateStringWithStateDataSource:ds];
}

+ (NSString *)stateStringWithStateDataSource:(TBMStateDataSource *)dataSource {
    NSMutableString *stateString = [NSMutableString new];
    // Friends
    [stateString appendString:[self friendsString]];
    
    // VideoObjects
    [dataSource loadFriendsVideoObjects];
    [dataSource loadVideos];
    [stateString appendFormat:@"\n%@", [self videoObjectsStringWithStateDataSource:dataSource]?:@""];
    
    // Dangling Files
    [dataSource excludeNonDanglingFiles];
    
    [stateString appendFormat:@"\n%@", [self danglingFilesStringWithStateDataSource:dataSource]?:@""];
    
    return stateString;
}

+ (NSString *)friendsString {
    NSMutableString *result = [NSMutableString new];
    [result appendFormat:@"%@\n", [TBMFriend tbm_stateTitlerStr]?:@""];
    [result appendFormat:@"%@\n", [TBMFriend tbm_stateHeaderStr]?:@""];
    
    NSArray *friends = [TBMFriend all];
    for (TBMFriend *friend in friends) {
        [result appendFormat:@"%@\n", [friend tbm_stateRowStr]];
    }
    return result;
}

+ (NSString *)videoObjectsStringWithStateDataSource:(TBMStateDataSource *)dataSource {
    NSMutableString *result = [NSMutableString new];
    [result appendFormat:@"%@\n", [TBMVideoObject tbm_stateTitlerStr]?:@""];
    [result appendFormat:@"%@\n", [TBMVideoObject tbm_stateHeaderStr]?:@""];
    
    for (TBMFriendVideosInformation *object in dataSource.friendsVideoObjects) {
        // Outgoing
        [result appendFormat:@"%@\n", [object tbm_stateRowStr]?:@""];
        for (TBMVideoObject *ovo in object.outgoingObjects) {
            [result appendFormat:@"%@\n", [ovo tbm_stateRowStr]?:@""];
        }
        // Incoming
        for (TBMVideoObject *ivo in object.incomingObjects) {
            [result appendFormat:@"%@\n", [ivo tbm_stateRowStr]?:@""];
        }
    }
    return result;
}

+ (NSString *)danglingFilesStringWithStateDataSource:(TBMStateDataSource *)dataSource {
    NSMutableString *result = [NSMutableString new];
    [result appendString:@"Dangling files\n"];
    [result appendFormat:@"Incoming (%ld)\n", (long)dataSource.incomingFiles.count];
    for (NSString *ivf in dataSource.incomingFiles) {
        [result appendFormat:@"%@\n", ivf];
    }
    [result appendFormat:@"Outgoing (%ld)\n", (long)dataSource.outgoingFiles.count];
    for (NSString *ovf in dataSource.outgoingFiles) {
        [result appendFormat:@"%@\n", ovf];
    }
    return result;
}

@end

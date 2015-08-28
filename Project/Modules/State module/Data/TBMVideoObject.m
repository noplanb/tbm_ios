//
// Created by Maksim Bazarov on 30.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMVideoObject.h"

@implementation TBMVideoObject

+ (TBMVideoObject *)makeVideoObjectWithVideoID:(NSString *)videoID status:(NSString *)status {

    if (!videoID) {
        return nil;
    }

    TBMVideoObject *resultObject = [[TBMVideoObject alloc] init];

    resultObject.videoID = videoID;
    resultObject.videoStatus = status?:@"-";

    return resultObject;
}

#pragma mark - TBMStateProtocol

+ (NSArray *)tbm_stateHeaderItems {
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:@"Name"];
    [items addObject:@"ID"];
    [items addObject:@"status"];
    return items;
}

+ (NSInteger)tbm_stateColumnsCount {
    return [self tbm_stateHeaderItems].count;
}

+ (NSString *)tbm_stateTitlerStr {
    return tbm_stateTitleForTableName(@"VideoObjects", [self tbm_stateColumnsCount]);
}

+ (NSString *)tbm_stateHeaderStr {
    
    return tbm_stateRowForItems([self tbm_stateHeaderItems]);
}

- (NSString *)tbm_stateRowStr {
    
    NSMutableArray *items = [NSMutableArray new];
    // format according to COLUMN_WIDTH
    [items addObject:@""];
    [items addObject:self.videoID];
    [items addObject:self.videoStatus];
    
    return tbm_stateRowForItems(items);
}
@end
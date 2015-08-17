//
// Created by Maksim Bazarov on 30.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMVideoObject.h"

@implementation TBMVideoObject {

}
+ (TBMVideoObject *)makeVideoObjectWithVideoID:(NSString *)videoID status:(NSString *)status {

    if (!videoID) {
        return nil;
    }

    TBMVideoObject *resultObject = [[TBMVideoObject alloc] init];

    resultObject.videoID = videoID;
    resultObject.videoStatus = status ? status : @"-";

    return resultObject;
}

#pragma mark - TBMDispatchProtocol

+ (NSArray *)tbm_stateHeaderItems {
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:@"Name"];
    [items addObject:@"ID"];
    [items addObject:@"status"];
    return items;
}

+ (int)tbm_stateColumnsCount {
    return (int)[self tbm_stateHeaderItems].count;
}

+ (NSString *)tbm_stateTitlerStr {
    return tbm_stateTitleForTableName(@"VideoObjects", (int)[self tbm_stateColumnsCount]);
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
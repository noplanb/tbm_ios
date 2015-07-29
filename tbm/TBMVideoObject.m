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

+ (NSArray *)tbm_dispatchHeaderItems {
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:@"Name"];
    [items addObject:@"ID"];
    [items addObject:@"status"];
    return items;
}

+ (int)tbm_dispatchColumnsCount {
    return (int)[self tbm_dispatchHeaderItems].count;
}

+ (NSString *)tbm_dispatchTitlerStr {
    return tbm_dispatchTitleForTableName(@"VideoObjects", (int)[self tbm_dispatchColumnsCount]);
}

+ (NSString *)tbm_dispatchHeaderStr {
    
    return tbm_dispatchRowForItems([self tbm_dispatchHeaderItems]);
}

- (NSString *)tbm_dispatchRowStr {
    
    NSMutableArray *items = [NSMutableArray new];
    // format according to COLUMN_WIDTH
    [items addObject:@""];
    [items addObject:self.videoID];
    [items addObject:self.videoStatus];
    
    return tbm_dispatchRowForItems(items);
}
@end
//
// Created by Maksim Bazarov on 28.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMFriendVideosInformation.h"
#import "TBMVideoObject.h"

@implementation TBMFriendVideosInformation

#pragma mark - TBMStateProtocol

+ (NSArray *)tbm_stateHeaderItems {
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:@"Name"];
    return items;
}

+ (int)tbm_stateColumnsCount {
    return (int)[self tbm_stateHeaderItems].count;
}

+ (NSString *)tbm_stateTitlerStr {
    return tbm_stateTitleForTableName(@"VideosInformation", (int)[self tbm_stateColumnsCount]);
}

+ (NSString *)tbm_stateHeaderStr {
    
    return tbm_stateRowForItems([self tbm_stateHeaderItems]);
}

- (NSString *)tbm_stateRowStr {
    
    NSMutableArray *items = [NSMutableArray new];
    // format according to COLUMN_WIDTH
    [items addObject:tbm_stateRowItemForString(self.name)];
    
    return tbm_stateRowForItems(items);
}

@end
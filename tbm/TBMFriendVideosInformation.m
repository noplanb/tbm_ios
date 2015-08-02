//
// Created by Maksim Bazarov on 28.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMFriendVideosInformation.h"
#import "TBMVideoObject.h"

@implementation TBMFriendVideosInformation {

}

#pragma mark - TBMDispatchProtocol

+ (NSArray *)tbm_dispatchHeaderItems {
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:@"Name"];
    return items;
}

+ (int)tbm_dispatchColumnsCount {
    return (int)[self tbm_dispatchHeaderItems].count;
}

+ (NSString *)tbm_dispatchTitlerStr {
    return tbm_dispatchTitleForTableName(@"VideosInformation", (int)[self tbm_dispatchColumnsCount]);
}

+ (NSString *)tbm_dispatchHeaderStr {
    
    return tbm_dispatchRowForItems([self tbm_dispatchHeaderItems]);
}

- (NSString *)tbm_dispatchRowStr {
    
    NSMutableArray *items = [NSMutableArray new];
    // format according to COLUMN_WIDTH
    [items addObject:tbm_dispatchRowItemForString(self.name)];
    
    return tbm_dispatchRowForItems(items);
}


@end
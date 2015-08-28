//
//  TBMStateProtocolHelpers.m
//  Zazo
//
//  Created by Sema Belokovsky on 29/07/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMStateProtocol.h"

// Width for column in state string (in characters)
static NSInteger TBSStateStringColumnWidth = 14;

#pragma mark - State string formatters

NSString* tbm_stateRowForItems(NSArray* items) {
    NSMutableString *row = [NSMutableString new];
    NSString *format = [NSString stringWithFormat:@"%%-%ld.%lds", (long)TBSStateStringColumnWidth, (long)TBSStateStringColumnWidth];
    
    for (NSString *item in items) {
        NSString *shortItem = item;
        if (shortItem.length > TBSStateStringColumnWidth) {
            shortItem = [shortItem substringToIndex:TBSStateStringColumnWidth];
        }
        [row appendFormat:@"| %@ ", [NSString stringWithFormat:format, shortItem.UTF8String]];
    }
    [row appendString:@"|"];
    return row;
}

NSString* tbm_stateRowItemForString(NSString* string) {
    return string?:@"";
}

NSString* tbm_stateTitleForTableName(NSString* string, NSInteger columnsCount) {
    NSInteger titleWidth = (TBSStateStringColumnWidth+2)*columnsCount+(columnsCount-3);
    NSString *format = [NSString stringWithFormat:@"| %%-%ld.%lds |", (long)titleWidth, (long)titleWidth];
    return [NSString stringWithFormat:format, string.UTF8String];
}
//
//  TBMStateProtocolHelpers.m
//  Zazo
//
//  Created by Sema Belokovsky on 29/07/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMStateProtocol.h"

// Width for column in state string
#define COLUMN_WIDTH 14

#pragma mark - State string formatters

NSString* tbm_stateRowForItems(NSArray* items) {
    NSMutableString *row = [NSMutableString new];
    NSString *format = [NSString stringWithFormat:@"%%-%d.%ds", COLUMN_WIDTH, COLUMN_WIDTH];
    
    for (NSString *item in items) {
        NSString *shortItem = item;
        if (shortItem.length > COLUMN_WIDTH) {
            shortItem = [shortItem substringToIndex:COLUMN_WIDTH];
        }
        [row appendFormat:@"| %@ ", [NSString stringWithFormat:format, shortItem.UTF8String]];
    }
    [row appendString:@"|"];
    return row;
}

NSString* tbm_stateRowItemForString(NSString* string) {
    return string?string:@"";
}

NSString* tbm_stateTitleForTableName(NSString* string, int columnsCount) {
    int titleWidth = (COLUMN_WIDTH+2)*columnsCount+(columnsCount-3);
    NSString *format = [NSString stringWithFormat:@"| %%-%d.%ds |", titleWidth, titleWidth];
    return [NSString stringWithFormat:format, string.UTF8String];
}
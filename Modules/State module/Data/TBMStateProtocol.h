//
//  TBMStateProtocol.h
//  Zazo
//
//  Created by Sema Belokovsky on 29/07/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+NSStringExtensions.h"

// Protocol describing state models
@protocol TBMStateProtocol <NSObject>

+ (NSArray *)tbm_stateHeaderItems;
+ (int)tbm_stateColumnsCount;
+ (NSString *)tbm_stateTitlerStr;
+ (NSString *)tbm_stateHeaderStr;
- (NSString *)tbm_stateRowStr;

@end

// Helpers for preparing data
NSString* tbm_stateRowForItems(NSArray* items);
NSString* tbm_stateRowItemForString(NSString* string);
NSString* tbm_stateTitleForTableName(NSString* string, int columnsCount);
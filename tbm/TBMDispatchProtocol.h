//
//  TBMDispatchProtocol.h
//  Zazo
//
//  Created by Sema Belokovsky on 29/07/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#ifndef Zazo_TBMDispatchProtocol_h
#define Zazo_TBMDispatchProtocol_h

#import <Foundation/Foundation.h>
#import "NSString+NSStringExtensions.h"

// Protocol describing dispatchable models
@protocol TBMDispatchProtocol <NSObject>

+ (NSArray *)tbm_dispatchHeaderItems;
+ (int)tbm_dispatchColumnsCount;
+ (NSString *)tbm_dispatchTitlerStr;
+ (NSString *)tbm_dispatchHeaderStr;
- (NSString *)tbm_dispatchRowStr;

@end

// Helpers for preparing data
NSString* tbm_dispatchRowForItems(NSArray* items);
NSString* tbm_dispatchRowItemForString(NSString* string);
NSString* tbm_dispatchTitleForTableName(NSString* string, int columnsCount);

#endif

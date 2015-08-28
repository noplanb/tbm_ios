//
//  TBMStateScreenGenerator.h
//  Zazo
//
//  Created by Sema Belokovsky on 17/08/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBMStateDataSource;

@interface TBMStateStringGenerator : NSObject

+ (NSString *)stateStringWithStateDataSource:(TBMStateDataSource *)dataSource;
+ (NSString *)stateString;

@end

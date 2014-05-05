//
//  NSArray+NSArrayExtensions.h
//  tbm
//
//  Created by Sani Elfishawy on 5/5/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NSArrayExtensions)
- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;
@end

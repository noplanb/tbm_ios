//
//  NSObject+ANUserDefaults.h
//  Zazo
//
//  Created by ANODA on 5/17/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface NSObject (ANUserDefaults)


#pragma mark - Update Objects

+ (void)an_updateObject:(id)object forKey:(NSString*)key;
+ (void)an_updateBool:(BOOL)object forKey:(NSString*)key;
+ (void)an_updateInteger:(NSInteger)object forKey:(NSString*)key;


#pragma mark - Retrive Objects

+ (id)an_objectForKey:(NSString*)key;
+ (NSString*)an_stringForKey:(NSString*)key;
+ (BOOL)an_boolForKey:(NSString*)key;
+ (NSInteger)an_integerForKey:(NSString*)key;

@end

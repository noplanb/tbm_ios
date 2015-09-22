//
//  NSObject+ANUserDefaults.m
//  Zazo
//
//  Created by ANODA on 5/17/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "NSObject+ANUserDefaults.h"

@implementation NSObject (ANUserDefaults)


#pragma mark - Update Objects

+ (void)an_updateObject:(id)object forKey:(NSString*)key
{
    if (!ANIsEmpty(key))
    {
        if (object)
        {
            [[self an_dataSource] setObject:object forKey:key];
        }
        else
        {
            [[self an_dataSource] removeObjectForKey:key];
        }
        [[self an_dataSource] synchronize];
    }
}

+ (void)an_updateBool:(BOOL)object forKey:(NSString*)key
{
    if (!ANIsEmpty(key))
    {
        [[self an_dataSource] setBool:object forKey:key];
        [[self an_dataSource] synchronize];
    }
}

+ (void)an_updateInteger:(NSInteger)object forKey:(NSString*)key
{
    if (!ANIsEmpty(key))
    {
        [[self an_dataSource] setInteger:object forKey:key];
        [[self an_dataSource] synchronize];
    }
}


#pragma mark - Retrive Objects

+ (id)an_objectForKey:(NSString*)key
{
    id object;
    if (!ANIsEmpty(key))
    {
        object = [[self an_dataSource] objectForKey:key];
    }
    return object;
}

+ (NSString*)an_stringForKey:(NSString*)key
{
    NSString* string = [self an_objectForKey:key];
    return [NSString stringWithFormat:@"%@", string ? : @""];
}

+ (BOOL)an_boolForKey:(NSString*)key
{
    BOOL value;
    if (!ANIsEmpty(key))
    {
       value = [[self an_dataSource] boolForKey:key];
    }
    return value;
}

+ (NSInteger)an_integerForKey:(NSString*)key
{
    NSInteger value;
    if (!ANIsEmpty(key))
    {
        value = [[self an_dataSource] integerForKey:key];
    }
    return value;
}


#pragma mark - Private

+ (NSUserDefaults *)an_dataSource
{
    return [NSUserDefaults standardUserDefaults];
}

@end

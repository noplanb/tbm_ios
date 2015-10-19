//
//  ZZStringUtils.m
//  Zazo
//
//  Created by ANODA on 17/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStringUtils.h"

@implementation ZZStringUtils

+ (NSString *)jsonWithDictionary:(NSDictionary *)dict
{
    NSString *jsonString;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    if (!jsonData)
    {
        jsonString = @"";
    }
    else
    {
        jsonString =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

+ (NSDictionary *)dictionaryWithJson:(NSString *)jsonString
{
    NSDictionary *try = [[NSDictionary alloc] init];
    NSDictionary *result = [[NSDictionary alloc] init];
    NSError *error;
    try = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if (error)
    {
        result = @{@"error": [error localizedDescription]};
    }
    else
    {
        result = try;
    }
    
    return result;
}

@end

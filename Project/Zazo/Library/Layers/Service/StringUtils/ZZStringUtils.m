//
//  ZZStringUtils.m
//  Zazo
//
//  Created by ANODA on 17/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStringUtils.h"

@implementation ZZStringUtils


+ (NSString *)randomStringofLength:(NSInteger)length
{
    NSMutableString *r = [[NSMutableString alloc] init];
    for (int i=0; i<length; i++)
    {
        char c = [ZZStringUtils azAZFromInt:arc4random_uniform(52)];
        [r appendString:[NSString stringWithFormat:@"%c", c]];
    }
    
    return r;
}

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

+ (char)azAZFromInt:(int)num
{
    int lowerStart = (int)'a';
    int upperStart = (int)'A';
    int numLetters = (int)'z' - (int)'a' + 1;
    
    int offset = num % numLetters;
    int start;
    
    if (num / numLetters > 0){
        start = upperStart;
    } else {
        start = lowerStart;
    }
    
    return (char)(start + offset);
}

@end

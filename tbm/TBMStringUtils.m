//
//  TBMStringUtils.m
//  tbm
//
//  Created by Sani Elfishawy on 5/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMStringUtils.h"

@implementation TBMStringUtils

+ (char)azAZFromInt:(int) num{
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

+ (NSString *)randomStringofLength:(int)length{
    NSMutableString *r = [[NSMutableString alloc] init];
    for (int i=0; i<length; i++){
        char c = [TBMStringUtils azAZFromInt:arc4random_uniform(52)];
        [r appendString:[NSString stringWithFormat:@"%c", c]];
    }
    return r;
}


+ (NSString *)jsonWithDictionary:(NSDictionary *)dict{
    NSString *jsonString;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    if (!jsonData){
        DebugLog(@"ERROR: setRemoteKVWithKey: %@", error);
        jsonString = @"";
    } else {
        jsonString =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+ (NSDictionary *)dictionaryWithJson:(NSString *)jsonString{
    NSDictionary *try = [[NSDictionary alloc] init];
    NSDictionary *result = [[NSDictionary alloc] init];
    NSError *error;
    try = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if (error){
        DebugLog(@"ERROR: jsonToDictionary: %@", [error localizedDescription]);
        result = @{@"error": [error localizedDescription]};
    } else {
        result = try;
    }
    return result;
}

@end

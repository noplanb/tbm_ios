//
//  OBLogger+ZZAdditions.m
//  Zazo
//
//  Created by Rinat on 25.01.16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "OBLogger+ZZAdditions.h"

@implementation OBLogger (ZZAdditions)


- (void)dropOldLines:(NSUInteger)numberOfLines
{
    NSError *error = nil;
    
    NSString *log = [NSString stringWithContentsOfFile:self.logFilePath
                                              encoding:NSUTF8StringEncoding
                                                 error:&error];
    
    if (!log && error)
    {
        [self error:[NSString stringWithFormat:@"dropOldLines error: %@", error]];
        [self reset];
        return;
    }
    
    NSArray *array = [log componentsSeparatedByString:@"\n"];
    
    if (array.count <= numberOfLines)
    {
        return;
    }
    
    NSRange range = NSMakeRange(array.count - numberOfLines - 1, numberOfLines);
    
    array = [array subarrayWithRange:range];
    
    NSString *result = [array componentsJoinedByString:@"\n"];
    
    BOOL success = [[result dataUsingEncoding:NSUTF8StringEncoding] writeToFile:self.logFilePath atomically:YES];
    
    if (!success)
    {
        [self error:@"dropOldLines failed"];
        [self reset];
    }
    
    else
    {
        [self info:@"Old lines were dropped"];
    }
}

@end

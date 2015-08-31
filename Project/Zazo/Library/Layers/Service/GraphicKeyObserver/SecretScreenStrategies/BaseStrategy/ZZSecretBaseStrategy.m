//
//  ZZSecretBaseStrategy.m
//  Zazo
//
//  Created by ANODA on 22/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretBaseStrategy.h"

@interface ZZSecretBaseStrategy ()

@property (nonatomic, strong) NSMutableArray* checkData;

@end

@implementation ZZSecretBaseStrategy

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.checkData = [NSMutableArray array];
        [self fillArray];
        
    }
    return self;
}


- (NSArray *)intersectionFrames
{
    return self.frameArray;
}

- (void)fillArray
{
 
}

- (BOOL)isLockedSuccess
{
    __block BOOL isLocked = YES;
    
    if (self.checkData.count == self.frameArray.count)
    {
        [self.checkData enumerateObjectsUsingBlock:^(NSNumber* obj, NSUInteger idx, BOOL *stop) {
            if ([obj integerValue] != idx)
            {
                isLocked = NO;
            }
        }];
    }
    else
    {
        isLocked = NO;
    }
    
    return isLocked;
}

- (void)intersectRectWithIndex:(NSInteger)index
{
    if (![self.checkData containsObject:@(index)])
    {
        [self.checkData addObject:@(index)];
    }
}

- (void)resetValidatoinArray
{
    [self.checkData removeAllObjects];
}

@end

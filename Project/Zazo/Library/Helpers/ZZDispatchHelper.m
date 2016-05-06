//
//  ZZDispatchHelper.m
//  Zazo
//
//  Created by Rinat on 09.12.15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZDispatchHelper.h"

id ZZDispatchOnMainThreadAndReturn(id(^block)())
{
    __block id result;

    dispatch_block_t dispatch_block = ^{
        result = block();
    };

    if ([NSThread isMainThread])
    {
        dispatch_block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), dispatch_block);
    }

    return result;
}
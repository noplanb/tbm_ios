//
//  ZZHelperFunctions.m
//  Zazo
//
//  Created by Vitaly Cherevaty on 12/11/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHelperFunctions.h"

id ZZDispatchBlockToMainQueueAndReturnValue(ZZCodeBlockWithReturnValue block)
{
    __block id ret = nil;
    if ([NSThread isMainThread])
    {
        if (block)
        {
            ret = block();
        }
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (block)
            {
                ret = block();
            }
        });
    }
    
    return ret;
}


void ZZDispatchBlockToMainQueueAndWait(ANCodeBlock block)
{
    if ([NSThread isMainThread])
    {
        if (block)
        {
            block();
        }
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (block)
            {
                block();
            }
        });
    }
}

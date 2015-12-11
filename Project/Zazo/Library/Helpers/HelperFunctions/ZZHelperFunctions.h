//
//  ZZHelperFunctions.h
//  Zazo
//
//  Created by Vitaly Cherevaty on 12/11/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^ZZCodeBlockWithReturnValue)();

id ZZDispatchBlockToMainQueueAndReturnValue(ZZCodeBlockWithReturnValue block);
void ZZDispatchBlockToMainQueueAndWait(ANCodeBlock block);


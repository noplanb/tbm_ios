//
//  ZZMessageDataProvider+Entities.h
//  Zazo
//
//  Created by Server on 29/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZMessageDataProvider.h"
#import "TBMMessage.h"

@interface ZZMessageDataProvider (Entities)
    
+ (TBMMessage *)entityWithID:(NSString *)messageID;

@end
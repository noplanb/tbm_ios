//
//  ZZMessageDataUpdater+Entities.h
//  Zazo
//
//  Created by Server on 28/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "TBMMessage.h"
#import "ZZMessageDataUpdater.h"

@interface ZZMessageDataUpdater (Entities)

+ (TBMMessage *)entityWithID:(NSString *)messageID createIfNeeded:(BOOL)flag;


@end
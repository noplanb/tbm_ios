//
//  ZZSentBadge.h
//  Zazo
//
//  Created by Rinat on 04/03/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZBadge.h"

typedef enum : NSUInteger {
    ZZSentBadgeStateSent,
    ZZSentBadgeStateViewed
} ZZSentBadgeState;

@interface ZZSentBadge : ZZBadge

@property (nonatomic, assign) ZZSentBadgeState state;

@end

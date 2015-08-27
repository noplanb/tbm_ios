//
//  ZZSecretBaseStrategy.h
//  Zazo
//
//  Created by ANODA on 22/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenStrategy.h"

static CGFloat const kFrameWidth = 60;
static CGFloat const kFrameHeight = 60;

@interface ZZSecretBaseStrategy : NSObject <ZZSecretScreenStrategy>

@property (nonatomic, strong) NSArray* frameArray;

@end

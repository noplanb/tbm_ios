//
//  ZZHintsDomainModel.m
//  Zazo
//
//  Created by ANODA on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsDomainModel.h"
#import "ZZGridActionDataProvider.h"

@implementation ZZHintsDomainModel

- (void)toggleStateTo:(BOOL)state
{
    [ZZGridActionDataProvider saveHintState:state forHintType:self.type];
}

@end

//
//  ZZDebugStateCell.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/27/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZDebugStateCell.h"

@implementation ZZDebugStateCell

- (void)updateWithModel:(ZZDebugStateCellViewModel*)model
{
    self.textLabel.text = [model title];
    self.detailTextLabel.text = [model status];
}

@end

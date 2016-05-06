//
//  ZZDebugStateCell.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/27/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZDebugStateCell.h"

@implementation ZZDebugStateCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.minimumScaleFactor = 0.2;
    }
    return self;
}

- (void)updateWithModel:(ZZDebugStateCellViewModel *)model
{
    if ([model isKindOfClass:[NSString class]])
    {
        self.textLabel.text = (NSString *)model;
    }
    else
    {
        self.textLabel.text = [model title];
        self.detailTextLabel.text = [model status];
    }
}

@end

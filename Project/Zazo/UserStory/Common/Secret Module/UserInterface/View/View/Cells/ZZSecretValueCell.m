//
//  ZZBaseSecretCell.m
//  Zazo
//
//  Created by ANODA on 8/28/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretValueCell.h"

@implementation ZZSecretValueCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionColor = [ZZColorTheme shared].baseColor;
    }
    return self;
}

- (void)updateWithModel:(ZZSecretValueCellViewModel*)model
{
    self.textLabel.text = [model title];
    self.detailTextLabel.text = [model details];
    
    BOOL hasDetails = (self.detailTextLabel.text.length);
    self.accessoryType = hasDetails ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
}

@end

//
//  ZZMenuTableHeaderView.m
//  Zazo
//
//  Created by Rinat on 22/03/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZMenuTableHeaderView.h"

@implementation ZZMenuTableHeaderView

- (void)setup
{
    [super setup];
    self.bottomLabelInset = -35;
    self.titleLabel.font = [UIFont zz_regularFontWithSize:21];

}

@end

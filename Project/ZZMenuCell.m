//
// Created by Rinat on 29/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZMenuCell.h"
#import "ZZMenuCellModel.h"

@implementation ZZMenuCell

- (void)updateWithModel:(ZZMenuCellModel *)model
{
    self.textLabel.text = model.title;
    self.imageView.image = model.icon;
}

@end
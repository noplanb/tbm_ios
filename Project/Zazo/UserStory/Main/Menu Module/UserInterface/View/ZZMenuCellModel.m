//
// Created by Rinat on 25/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZMenuCellModel.h"


@implementation ZZMenuCellModel

- (instancetype)initWithTitle:(NSString *)title iconWithImageNamed:(NSString *)imageName
{
    self = [super init];
    if (self)
    {
        _title = title;
        _icon = [UIImage imageNamed:imageName];
    }
    return self;
}

+ (instancetype)modelWithTitle:(NSString *)title iconWithImageNamed:(NSString *)imageName
{
    return [[self alloc] initWithTitle:title iconWithImageNamed:imageName];
}


@end
//
// Created by Rinat on 25/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZMenuModuleInterface.h"

@interface ZZMenuCellModel : NSObject

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) ZZMenuItemType type;

+ (instancetype)modelWithTitle:(NSString *)title iconWithImageNamed:(NSString *)imageName;
- (instancetype)initWithTitle:(NSString *)title iconWithImageNamed:(NSString *)imageName;

@end
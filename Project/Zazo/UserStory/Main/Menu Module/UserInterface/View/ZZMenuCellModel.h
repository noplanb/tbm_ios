//
// Created by Rinat on 25/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZMenuModuleInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZZMenuCellModel : NSObject

@property (nonatomic, strong, nullable) UIImage *icon;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) ZZMenuItemType type;

+ (instancetype)modelWithTitle:(NSString *)title iconWithImageNamed:(nullable NSString *)imageName;

- (instancetype)initWithTitle:(NSString *)title iconWithImageNamed:(nullable NSString *)imageName;

@end

NS_ASSUME_NONNULL_END

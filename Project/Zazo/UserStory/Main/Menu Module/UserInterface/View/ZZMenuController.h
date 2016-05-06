//
// Created by Rinat on 25/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANTableController.h"

@class ZZMenuController;
@class ZZMenuCellModel;

@protocol ZZMenuControllerDelegate

- (void)controller:(ZZMenuController *)controller didSelectModel:(ZZMenuCellModel *)model;

@end

@interface ZZMenuController : ANTableController

@property (nonatomic, weak) id <ZZMenuControllerDelegate> delegate;

@end
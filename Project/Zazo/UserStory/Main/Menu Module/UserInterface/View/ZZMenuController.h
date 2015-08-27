//
//  ZZMenuController.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANTableController.h"

@class ZZMenuCellViewModel;
@class ZZMenuDataSource;

@protocol ZZMenuControllerDelegate <NSObject>

- (void)itemSelected:(ZZMenuCellViewModel*)model;

@end

@interface ZZMenuController : ANTableController

@property (nonatomic, weak) id<ZZMenuControllerDelegate> delegate;

- (void)updateDataSource:(ZZMenuDataSource *)dataSource;

@end

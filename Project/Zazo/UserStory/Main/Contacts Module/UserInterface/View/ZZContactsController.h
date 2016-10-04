//
//  ZZContactsController.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANTableController.h"

@class ZZContactCellViewModel;
@class ZZContactsDataSource;

@protocol ZZContactsControllerDelegate <NSObject>

- (void)itemSelected:(ZZContactCellViewModel *)model;
- (void)needToUpdateDataSource;

@end

@interface ZZContactsController : ANTableController

@property (nonatomic, weak) id <ZZContactsControllerDelegate> delegate;

- (void)updateDataSource:(ZZContactsDataSource *)dataSource;
- (void)reset;
- (void)reloadContactData;

@end

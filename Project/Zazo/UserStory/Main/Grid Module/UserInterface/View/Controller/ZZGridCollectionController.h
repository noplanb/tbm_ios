//
//  ZZGridCollectionController.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridDataSource;

@protocol ZZGridCollectionControllerDelegate <NSObject>

- (NSArray*)items;

@end

@interface ZZGridCollectionController : NSObject

@property (nonatomic, weak) id<ZZGridCollectionControllerDelegate> delegate;

- (void)updateDataSource:(ZZGridDataSource*)dataSource;

@end

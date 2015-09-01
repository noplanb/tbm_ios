//
//  ZZGridModuleInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridCellViewModel;

@protocol ZZGridModuleInterface <NSObject>

- (void)presentMenu;
- (void)selectedCollectionViewWithModel:(ZZGridCellViewModel*)model;
- (void)presentEditFriends;
- (void)presentSendEmail;

@end

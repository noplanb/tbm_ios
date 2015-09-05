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
- (void)itemSelectedWithModel:(ZZGridCellViewModel*)model;
- (void)presentEditFriendsController;
- (void)presentSendEmailController;

@end

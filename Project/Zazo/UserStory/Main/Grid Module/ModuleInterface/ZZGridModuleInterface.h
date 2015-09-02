//
//  ZZGridModuleInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridCollectionCellViewModel;

@protocol ZZGridModuleInterface <NSObject>

- (void)presentMenu;
- (void)selectedCollectionViewWithModel:(ZZGridCollectionCellViewModel*)model;
- (void)presentEditFriends;
- (void)presentSendEmail;


@end

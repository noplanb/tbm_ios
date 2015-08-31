//
//  ZZGridModuleInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridDomainModel;

@protocol ZZGridModuleInterface <NSObject>

- (void)presentMenu;
- (void)presentEditFriends;
- (void)selectedCollectionViewWithModel:(ZZGridDomainModel*)model;

@end

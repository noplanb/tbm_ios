//
//  ZZGridViewInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridDataSource, ZZFriendDomainModel;

@protocol ZZGridViewInterface <NSObject>

- (void)udpateWithDataSource:(ZZGridDataSource *)dataSource;
- (id)cellAtIndexPath:(NSIndexPath*)indexPath;
- (void)menuIsOpened;
- (void)showFriendAnimationWithModel:(ZZFriendDomainModel*)friendModel;

@end

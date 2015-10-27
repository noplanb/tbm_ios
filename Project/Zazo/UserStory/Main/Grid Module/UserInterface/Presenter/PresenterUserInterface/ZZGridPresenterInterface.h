//
//  ZZGridPresenterInterface.h
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZGridDataSource;
@class ZZGridActionHandler;
@class ZZFriendDomainModel;

@protocol ZZGridPresenterInterface <NSObject>

- (ZZGridDataSource*)dataSource;
- (ZZGridActionHandler*)actionHandler;
- (void)showFriendAnimationWithIndex:(NSInteger)index;
- (id <ZZGridViewInterface>)userInterface;
- (NSInteger)indexOnGridViewForFriendModel:(ZZFriendDomainModel*)model;
@end

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
@class ZZGridAlertBuilder;

@protocol ZZGridPresenterInterface <NSObject>

- (ZZGridDataSource*)dataSource;
- (ZZGridActionHandler*)actionHandler;
- (void)showFriendAnimationWithFriend:(ZZFriendDomainModel*)friendModel;
- (id <ZZGridViewInterface>)userInterface;
- (NSInteger)indexOnGridViewForFriendModel:(ZZFriendDomainModel*)model;
- (ZZGridAlertBuilder*)alertBuilder;
@end

//
//  ZZEditFriendListVC.h
//  Zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEditFriendListViewInterface.h"
#import "ZZEditFriendListModuleInterface.h"
#import "ZZBaseVC.h"

@interface ZZEditFriendListVC : ZZBaseVC <ZZEditFriendListViewInterface>

@property (nonatomic, weak) id<ZZEditFriendListModuleInterface> eventHandler;

@end

//
//  ZZContactsDataSource.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactCell.h"

@class ANMemoryStorage;

typedef NS_ENUM(NSInteger, ZZMenuSections)
{
    ZZMenuSectionsFriendsHasApp,
    ZZMenuSectionsFriends,
    ZZMenuSectionsAddressbook
};


@interface ZZContactsDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage *storage;

- (void)setupAddressbookItems:(NSArray *)items;
- (void)setupAllFriendItems:(NSArray *)items;
- (void)setupFriendsThatHaveAppItems:(NSArray *)items;

@end

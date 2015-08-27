//
//  ZZMenuDataSource.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuCell.h"

@class ANMemoryStorage;

typedef NS_ENUM(NSInteger, ZZMenuSections)
{
    ZZMenuSectionsFriends,
    ZZMenuSectionsAddressbook
};

@interface ZZMenuDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;

- (void)setupAddressbookItems:(NSArray*)items;
- (void)setupFriendsItems:(NSArray*)items;

@end

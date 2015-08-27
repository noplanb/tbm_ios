//
//  ZZEditFriendView.m
//  Zazo
//
//  Created by ANODA on 8/25/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEditFriendView.h"
#import "ANTableView.h"

@implementation ZZEditFriendView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - Lazy Load

- (UITableView *)editFriendsTableView
{
    if (!_editFriendsTableView)
    {
        _editFriendsTableView = [[ANTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [self addSubview:_editFriendsTableView];
        [_editFriendsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.equalTo(self);
        }];
    }
    return _editFriendsTableView;
}


@end

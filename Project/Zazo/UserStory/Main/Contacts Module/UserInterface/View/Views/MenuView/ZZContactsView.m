//
//  ZZContactsView.m
//  Zazo
//
//  Created by ANODA.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactsView.h"

#pragma mark - Searchbar
static CGFloat const kSearchBarHeight = 44;

@implementation ZZContactsView

- (instancetype)init
{
    if (self = [super init])
    {
        [self tableView];
        [self searchBar];
    }
    return self;
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake(kSearchBarHeight, 0, 0, 0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kSearchBarHeight, 0, 0, 0);
        _tableView.scrollsToTop = YES;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

        [self addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.equalTo(self);
        }];
    }
    return _tableView;
}

- (UISearchBar *)searchBar
{
    if (!_searchBar)
    {
        _searchBar = [UISearchBar new];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;

        [self addSubview:_searchBar];
        [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.equalTo(@(kSearchBarHeight));
        }];

        _searchBar.backgroundColor = [UIColor whiteColor];
        _searchBar.barTintColor = [UIColor whiteColor];
        _searchBar.translucent = NO;

        _searchBar.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        _searchBar.layer.shadowRadius = 2.0f;
        _searchBar.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
        _searchBar.layer.shadowOpacity = 1.0f;

        UITextField *searchTextField = [_searchBar valueForKey:@"_searchField"];

        searchTextField.backgroundColor = [UIColor clearColor];
        searchTextField.leftViewMode = UITextFieldViewModeAlways;
        searchTextField.rightViewMode = UITextFieldViewModeNever;
        searchTextField.borderStyle = UITextBorderStyleNone;
        searchTextField.font = [UIFont zz_regularFontWithSize:18];
        searchTextField.layer.borderColor = [UIColor clearColor].CGColor;
        searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

        searchTextField.leftView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1.5, 1.5), -18, 0);

        [_searchBar setImage:[UIImage imageNamed:@"clear-button"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];

    }
    return _searchBar;
}

@end

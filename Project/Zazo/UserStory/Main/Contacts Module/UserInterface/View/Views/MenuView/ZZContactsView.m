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
        _tableView.showsVerticalScrollIndicator = NO;
        [self addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom).with.offset(0);
            make.left.bottom.right.equalTo(self);
        }];
    }
    return _tableView;
}

- (UISearchBar *)searchBar
{
    if (!_searchBar)
    {
        _searchBar = [UISearchBar new];
        [self seapratorViewsWithSearchBar:_searchBar];
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
        
        searchTextField.backgroundColor = [UIColor whiteColor];
        searchTextField.leftViewMode = UITextFieldViewModeNever;
        searchTextField.rightViewMode = UITextFieldViewModeNever;
        searchTextField.borderStyle = UITextBorderStyleNone;
        
        searchTextField.layer.borderColor = [UIColor clearColor].CGColor;
        searchTextField.clearButtonMode=UITextFieldViewModeWhileEditing;

        
    }
    return _searchBar;
}

- (void)seapratorViewsWithSearchBar:(UISearchBar* )searchBar
{
//    NSInteger leftOffset = 20;
//    NSInteger separatorHeight = 1;
//    
//    UIView* bottomBorder = [UIView new];
//    bottomBorder.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.33 alpha:1.0f];
//    [searchBar addSubview:bottomBorder];
//    
//    [bottomBorder mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(searchBar).with.offset(leftOffset);
//        make.bottom.right.equalTo(searchBar);
//        make.height.equalTo(@(separatorHeight));
//    }];
//    UIView* topBorderView = [UIView new];
//    topBorderView.backgroundColor = [UIColor colorWithRed:0.01 green:0.01 blue:0.01 alpha:1.0f];
//    [searchBar addSubview:topBorderView];
//    
//    [topBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(bottomBorder.mas_left);
//        make.bottom.equalTo(bottomBorder.mas_top).with.offset(0);
//        make.right.equalTo(searchBar);
//        make.height.equalTo(@(separatorHeight));
//    }];
}

@end

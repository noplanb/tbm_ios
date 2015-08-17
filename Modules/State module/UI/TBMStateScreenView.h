//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBMStateDataSource;


@interface TBMStateScreenView : UIView <UITableViewDelegate, UITableViewDataSource>

/**
* Update table with data
*/
- (void)updateTableWithData:(NSMutableDictionary *)data orederKeys:(NSMutableArray *)orderKeys;

@end
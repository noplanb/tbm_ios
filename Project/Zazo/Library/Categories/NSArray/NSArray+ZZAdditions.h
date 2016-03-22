//
// Created by Maksim Bazarov on 26/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

@interface NSArray (ZZAdditions)

- (id)zz_randomObject;
- (NSDictionary *)zz_groupByKeyPath:(NSString *)keyPath;

@end
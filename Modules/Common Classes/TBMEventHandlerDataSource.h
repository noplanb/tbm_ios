//
// Created by Maksim Bazarov on 22/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

@interface TBMEventHandlerDataSource : NSObject

@property(nonatomic, strong) NSString *persistentStateKey;

@property(nonatomic, assign) BOOL sessionState;

- (void)setPersistentState:(BOOL)state;
- (BOOL)persistentState;

@end
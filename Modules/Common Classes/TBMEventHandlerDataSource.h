//
// Created by Maksim Bazarov on 22/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TBMEventHandlerDataSource : NSObject

@property(nonatomic, strong) NSString *persistentStateKey;

- (void)setSessionState:(BOOL)state;

- (BOOL)sessionState;

- (void)setPersistentState:(BOOL)state;

- (BOOL)persistentState;

@end
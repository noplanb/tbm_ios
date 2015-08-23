//
// Created by Maksim Bazarov on 22/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventHandlerDataSource.h"

#define NSUD [NSUserDefaults standardUserDefaults]

@implementation TBMEventHandlerDataSource {
    BOOL _sessionState;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _sessionState = NO;
    }
    return self;
}

- (void)setSessionState:(BOOL)state {
    _sessionState = state;
}

- (BOOL)sessionState {
    return _sessionState;
}

- (void)setPersistentState:(BOOL)state {
    NSString *key = self.persistentStateKey;
    if (key && key.length > 0) {
        [NSUD setBool:state forKey:key];
        [NSUD synchronize];
    }

}

- (BOOL)persistentState {
    NSString *key = self.persistentStateKey;
    if (key && key.length > 0) {
        [NSUD boolForKey:key];
    }
    return NO;
}

@end
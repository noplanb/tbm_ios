//
// Created by Maksim Bazarov on 22/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEventHandlerDataSource.h"
#import "NSNumber+TBMUserDefaults.h"

@implementation TBMEventHandlerDataSource


- (void)setPersistentState:(BOOL)state
{
    [@(state) saveUserDefaultsObjectForKey:self.persistentStateKey];
}

- (BOOL)persistentState
{
    return [[NSNumber loadUserDefaultsObjectForKey:self.persistentStateKey] boolValue];
}

@end
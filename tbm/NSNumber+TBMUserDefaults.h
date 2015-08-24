//
// Created by Maksim Bazarov on 24/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//


@interface NSNumber (TBMUserDefaults)

- (void)saveUserDefaultsObjectForKey:(NSString *)key;
+ (id)loadUserDefaultsObjectForKey:(NSString *)key;

@end
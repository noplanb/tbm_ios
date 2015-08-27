//
// Created by Maksim Bazarov on 24/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

@implementation NSNumber (TBMUserDefaults)

- (void)saveUserDefaultsObjectForKey:(NSString *)key
{
    if (key && key.length > 0)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self forKey:key];
        [userDefaults synchronize];
    }
}

+ (id)loadUserDefaultsObjectForKey:(NSString *)key
{
    if (key && key.length > 0)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        return [userDefaults objectForKey:key];
    }
    else
    {
        return nil;
    }
}
@end
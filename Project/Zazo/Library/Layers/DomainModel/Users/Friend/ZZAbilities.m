//
//  ZZAbilities.m
//  Zazo
//
//  Created by Rinat on 24/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZAbilities.h"

NSArray <NSString *> *abilitiesStrings();
ZZFriendAbilities abilityFromString(NSString *string);

#define ZZFriendAbilitiesMessagingString @"text_messaging"

static NSString *ZZFriendAbilityStrings[] = {
    ZZFriendAbilitiesMessagingString
};

ZZFriendAbilities ZZAbilitiesFromArray(NSArray <NSString *> *array)
{
    __block ZZFriendAbilities abilities = 0;
    
    [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        abilities = abilities ^ abilityFromString(obj);
    }];
    
    return abilities;
}

NSArray <NSString *> *ZZArrayFromAbilities(ZZFriendAbilities abilities)
{
    NSMutableArray *array = [NSMutableArray new];
    
    if (abilities & ZZFriendAbilitiesMessaging) {
        [array addObject:ZZFriendAbilitiesMessagingString];
    }
    
    return array;
}

ZZFriendAbilities abilityFromString(NSString *string)
{
    NSArray *abilities = abilitiesStrings();
    NSInteger index = [abilities indexOfObject:string];
    
    if (index == NSNotFound) {
        ZZLogError(@"incorrect ability string");
        return 0;
    }
    
    return 1 << index;
}

NSArray <NSString *> *abilitiesStrings()
{
    static NSArray <NSString *> *array;
    
    if (!array) {
        
        int count = sizeof(ZZFriendAbilityStrings) / sizeof(ZZFriendAbilityStrings[0]);
        array = [NSArray arrayWithObjects:ZZFriendAbilityStrings count:count];
    }
    
    return array;
}
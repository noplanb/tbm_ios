//
//  Abilities.h
//  Zazo
//
//  Created by Rinat on 24/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#ifndef Abilities_h
#define Abilities_h

typedef NS_OPTIONS(NSUInteger, ZZFriendAbilities) {
    ZZFriendAbilitiesMessaging = 1 << 0,
};

ZZFriendAbilities ZZAbilitiesFromArray(NSArray <NSString *> *array);
NSArray <NSString *> *ZZArrayFromAbilities(ZZFriendAbilities abilities);

#endif /* Abilities_h */

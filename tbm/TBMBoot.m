//
//  TBMBoot.m
//  tbm
//
//  Created by Sani Elfishawy on 4/28/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMBoot.h"
#import "TBMFriend.h"

@implementation TBMBoot

+ (void)boot
{
    [TBMFriend destroyAll];
    for (int i = 0; i<8; i++){
        NSNumber *index = [[NSNumber alloc] initWithInt:i];
        TBMFriend *friend = [TBMFriend newWithId:index];
        friend.viewIndex = index;
        friend.firstName = [NSString stringWithFormat:@"First %@", index];
        friend.lastName = [NSString stringWithFormat:@"Last %@", index];
    }
    NSLog(@"TBMBoot: loaded %lu dummy friends.", (unsigned long)[[TBMFriend all] count]);
}
@end

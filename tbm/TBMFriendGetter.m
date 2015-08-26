//
//  TBMFriendGetter.m
//  tbm
//
//  Created by Sani Elfishawy on 11/4/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMFriendGetter.h"
#import "TBMFriend.h"
#import "TBMHttpManager.h"
#import "TBMUser.h"

@interface TBMFriendGetter ()
@property(nonatomic) BOOL destroyAll;
@property(nonatomic, retain) id <TBMFriendGetterCallback> delegate;
@end

@implementation TBMFriendGetter

- (instancetype)initWithDelegate:(id <TBMFriendGetterCallback>)delegate
{
    self = [super init];
    if (self != nil)
    {
        _delegate = delegate;
    }
    return self;
}


- (void)getFriends
{
    [[TBMHttpManager manager] GET:@"reg/get_friends"
                       parameters:nil
                          success:^(AFHTTPRequestOperation *operation, id responseObject)
                          {
                              [self gotFriends:responseObject];
                          }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
                          {
                              [_delegate friendGetterServerError];
                          }];
}

- (void)gotFriends:(NSArray *)friends
{
    [self detectInvitee:friends];
    for (NSDictionary *fParams in friends)
    {
        [TBMFriend createOrUpdateWithServerParams:fParams complete:nil];
    }
    [_delegate gotFriends];
}

- (void)detectInvitee:(NSArray *)friends
{
    NSArray *sorted = [self sortedFriendsByCreatedOn:friends];
    if (sorted)
    {
        NSDictionary *firstFriend = sorted.firstObject;
        NSString *firstFriendCreatorMkey = firstFriend[@"connection_creator_mkey"];
        TBMUser *me = [TBMUser getUser];
        NSString *myMkey = me.mkey;
        [me setupIsInviteeFlagTo:[firstFriendCreatorMkey isEqualToString:myMkey]];
    }
}

- (NSArray *)sortedFriendsByCreatedOn:(NSArray *)friends
{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];

    return [friends sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {

        NSComparisonResult result = NSOrderedSame;
        NSDictionary *dict1 = (NSDictionary *) obj1;
        NSDictionary *dict2 = (NSDictionary *) obj2;
        NSDate *date1;
        NSDate *date2;

        if ([dict1 isKindOfClass:[NSDictionary class]] && [dict2 isKindOfClass:[NSDictionary class]])
        {

            date1 = [dateFormatter dateFromString:dict1[@"connection_created_on"]];
            date2 = [dateFormatter dateFromString:dict2[@"connection_created_on"]];
        }

        if (date1 && date2)
        {
            result = [date1 timeIntervalSinceDate:date2] > 0 ? NSOrderedDescending : NSOrderedAscending;
        }
        return result;
    }];
}

@end

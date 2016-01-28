//
//  ZZRemoteStorageValueGenerator.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/19/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZRemoteStorageValueGenerator.h"
#import "NSString+ZZAdditions.h"
#import "ZZRemoteStorageConstants.h"

@implementation ZZRemoteStorageValueGenerator


#pragma mark - Filename

+ (NSString*)incomingVideoRemoteFilenameWithFriendMkey:(NSString *)friendMkey
                                            friendCKey:(NSString *)friendCkey
                                               videoID:(NSString*)videoID
{
    return [NSString stringWithFormat:@"%@-%@",
            [self _incomingPrefixWithFriendMKey:friendMkey],
            [[friendCkey stringByAppendingString:videoID] an_md5]];
}

+ (NSString*)outgoingVideoRemoteFilenameWithFriendMkey:(NSString *)friendMkey
                                            friendCKey:(NSString *)friendCkey
                                               videoID:(NSString*)videoID
{
    return [NSString stringWithFormat:@"%@-%@",
            [self _outgoingPrefixWithFriendMKey:friendMkey],
            [[friendCkey stringByAppendingString:videoID] an_md5]];
}


#pragma mark - Video ID

+ (NSString*)incomingVideoIDRemoteKVKeyWithFriendMKey:(NSString*)friendMKey friendCKey:(NSString*)friendCKey
{
    return [NSString stringWithFormat:@"%@-%@",
            [self _incomingPrefixWithFriendMKey:friendMKey],
            [self _incomingSuffixWithFriendMKey:friendMKey
                                     friendCKey:friendCKey
                                         suffix:kRemoteStorageVideoIDSuffix]];
}

+ (NSString*)outgoingVideoIDRemoteKVWithFriendMKey:(NSString*)friendMKey friendCKey:(NSString*)friendCKey
{
    return [NSString stringWithFormat:@"%@-%@",
            [self _outgoingPrefixWithFriendMKey:friendMKey],
            [self _outgoingSuffixWithFriendMKey:friendMKey
                                     friendCKey:friendCKey
                                         suffix:kRemoteStorageVideoIDSuffix]];
}


#pragma mark - Video Status

+ (NSString*)incomingVideoStatusRemoteKVKeyWithFriendMKey:(NSString*)friendMKey friendCKey:(NSString*)friendCKey
{
    return [NSString stringWithFormat:@"%@-%@",
            [self _incomingPrefixWithFriendMKey:friendMKey],
            [self _incomingSuffixWithFriendMKey:friendMKey
                                     friendCKey:friendCKey
                                         suffix:kRemoteStorageVideoStatusSuffix]];
}

+ (NSString*)outgoingVideoStatusRemoteKVKeyWithFriendMKey:(NSString*)friendMKey friendCKey:(NSString*)friendCKey
{
    return [NSString stringWithFormat:@"%@-%@",
            [self _outgoingPrefixWithFriendMKey:friendMKey],
            [self _outgoingSuffixWithFriendMKey:friendMKey
                                     friendCKey:friendCKey
                                         suffix:kRemoteStorageVideoStatusSuffix]];
}


#pragma mark - Private

+ (NSString*)_incomingPrefixWithFriendMKey:(NSString*)friendMkey
{
     return [NSString stringWithFormat:@"%@-%@", friendMkey, [self _myMkey]];
}

+ (NSString*)_outgoingPrefixWithFriendMKey:(NSString*)friendMKey
{
    return [NSString stringWithFormat:@"%@-%@", [self _myMkey], friendMKey];
}

+ (NSString*)_myMkey
{
    return [ZZStoredSettingsManager shared].userID;
}

+ (NSString*)_incomingSuffixWithFriendMKey:(NSString*)friendMKey friendCKey:(NSString*)friendCKey suffix:(NSString*)suffix
{
    NSString *md5 = [[[friendMKey stringByAppendingString:[self _myMkey]] stringByAppendingString:friendCKey] an_md5];
    return [md5 stringByAppendingString:suffix];
}

+ (NSString*)_outgoingSuffixWithFriendMKey:(NSString*)friendMKey friendCKey:(NSString*)friendCKey suffix:(NSString*)suffix
{
    NSString *md5 = [[[[self _myMkey] stringByAppendingString:friendMKey] stringByAppendingString:friendCKey] an_md5];
    return [md5 stringByAppendingString:suffix];
}


@end

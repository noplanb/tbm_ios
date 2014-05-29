//
//  TBMVideoIdUtils.m
//  tbm
//
//  Created by Sani Elfishawy on 5/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideoIdUtils.h"
#import "TBMUser.h"
#import "TBMStringUtils.h"

@implementation TBMVideoIdUtils

+ (NSString *)generateOutgoingVideoIdWithFriend:(TBMFriend *)friend{
    // Pattern senderId-receiverId-senderFristname-receiverFirstname-32randomcharacters.
    NSMutableString *r = [[NSMutableString alloc] init];
    [r appendString:[TBMUser getUser].idTbm];
    [r appendString:@"-"];
    [r appendString:friend.idTbm];
    [r appendString:@"-"];
    [r appendString:[TBMUser getUser].firstName];
    [r appendString:@"-"];
    [r appendString:friend.firstName];
    [r appendString:@"-"];
    [r appendString:[TBMStringUtils randomStringofLength:50]];
    return r;
}

+ (NSDictionary *)senderAndReceiverIdsWithVideoId:(NSString *)videoId{
    DebugLog(@"senderAndReceiverIdsWithVideoId: %@", videoId);
    NSError *error = NULL;
    NSRange range = NSMakeRange(0, [videoId length]);
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(\\d+)-(\\d+)-" options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:videoId options:0 range:range];
    if (numberOfMatches != 1) {
        DebugLog(@"ERROR: senderAndReceiverIdsWithIncomingVideoId: ERROR: got %lu matches rather than 1 match. This should never happen.", (unsigned long)numberOfMatches);
        return @{};
    }
    
    NSArray *matches = [regex matchesInString:videoId options:NSMatchingWithoutAnchoringBounds range:range];
    return @{@"senderId": [videoId substringWithRange:[[matches firstObject] rangeAtIndex:1]],
             @"receiverId": [videoId substringWithRange:[[matches firstObject] rangeAtIndex:2]]};
}

+ (NSString *)senderIdWithVideoId:videoId{
    return [TBMVideoIdUtils senderAndReceiverIdsWithVideoId:videoId][@"senderId"];
}

+ (NSString *)receiverIdWithVideoId:videoId{
    return [TBMVideoIdUtils senderAndReceiverIdsWithVideoId:videoId][@"receiverId"];
}

@end

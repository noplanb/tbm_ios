//
//  TBMFriendGetter.m
//  tbm
//
//  Created by Sani Elfishawy on 11/4/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMFriendGetter.h"
#import "TBMUser.h"
#import "TBMFriend.h"
#import "TBMHttpManager.h"
#import "OBLogger.h"

@interface TBMFriendGetter()
@property (nonatomic) BOOL destroyAll;
@property (nonatomic, retain) id<TBMFriendGetterCallback> delegate;
@end

@implementation TBMFriendGetter

- (instancetype)initWithDelegate:(id<TBMFriendGetterCallback>)delegate{
    self = [super init];
    if (self != nil){
        _delegate = delegate;
    }
    return self;
}


- (void)getFriends{
    [[TBMHttpManager manager] GET:@"reg/get_friends"
                        parameters:nil
                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                               [self gotFriends:responseObject];
                           }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                               [_delegate friendGetterServerError];
                           }];
}

- (void)gotFriends:(NSArray *)friends{
    for (NSDictionary *fParams in friends){
        [TBMFriend createOrUpdateWithServerParams:fParams complete:nil];
    }
    [_delegate gotFriends];
}

@end

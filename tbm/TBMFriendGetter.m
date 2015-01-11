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

- (instancetype)initWithDelegate:(id<TBMFriendGetterCallback>)delegate destroyAll:(BOOL)destroyAll{
    self = [super init];
    if (self != nil){
        _delegate = delegate;
        _destroyAll = destroyAll;
    }
    return self;
}


- (void)getFriends{
    [[[TBMHttpManager manager] GET:@"reg/get_friends"
                        parameters:nil
                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                               [self gotFriends:responseObject];
                           }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                               [_delegate friendGetterServerError];
                           }] resume];
}

- (void)gotFriends:(NSArray *)friends{
    OB_INFO(@"TBMFriendGetter: gotFriends: %@", friends);
    if (_destroyAll)
        [TBMFriend destroyAll];
    
    for (NSDictionary *fParams in friends){
        [TBMFriend createWithServerParams:fParams];
    }
    [_delegate gotFriends];
}

@end

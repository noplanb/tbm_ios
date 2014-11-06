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
#import "TBMHttpClient.h"
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
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[TBMUser getUser].auth forKey:SERVER_PARAMS_USER_AUTH_KEY];
    [params setObject:[TBMUser getUser].mkey forKey:SERVER_PARAMS_USER_MKEY_KEY];
    
    TBMHttpClient *hc = [TBMHttpClient sharedClient];
    NSURLSessionDataTask *task = [hc
                                  GET:@"reg/get_friends"
                                  parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      [self gotFriends:responseObject];
                                  }
                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      [_delegate friendGetterServerError];
                                  }];
    [task resume];
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

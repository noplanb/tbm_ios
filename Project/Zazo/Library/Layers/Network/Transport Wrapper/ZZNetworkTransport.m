//
//  ZZNetworkTransport.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTransport.h"
#import "ANErrorBuilder.h"
#import "TBMUser.h"
#import "AFHTTPRequestOperationManager.h"
#import "ZZStoredSettingsManager.h"

@implementation ZZNetworkTransport

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setBaseURL:apiBaseURL() andAPIVersion:@""];
        
        RACSignal* authSignal = RACObserve([ZZStoredSettingsManager shared], authToken);
        RACSignal* itemIDSignal = RACObserve([ZZStoredSettingsManager shared], userID);
        
        [[RACSignal combineLatest:@[authSignal, itemIDSignal] reduce:^id(NSString* authToken, NSString* userID){
            
             return @(!ANIsEmpty(authToken) && !ANIsEmpty(userID));
        }] subscribeNext:^(id x) {
            
            if ([x boolValue])
            {
                NSURLCredential* credentials = [[NSURLCredential alloc] initWithUser:[ZZStoredSettingsManager shared].userID
                                                                            password:[ZZStoredSettingsManager shared].authToken
                                                                         persistence:NSURLCredentialPersistenceForSession];
                self.session.credential = credentials;
            }
        }];
    }
    return self;
}

- (RACSignal *)requestWithPath:(NSString *)path parameters:(NSDictionary *)params httpMethod:(ANHttpMethodType)httpMethod
{
#ifdef HTTPLog
    if (params)
    {
        ANLogHTTP(@"Parameters : \n%@", params);
    }
#endif
    return [super requestWithPath:path parameters:params httpMethod:httpMethod];
}

- (void)logResponse:(NSHTTPURLResponse*)httpResponse description:(NSString*)description json:(NSDictionary*)json
{
#ifdef HTTPLog
    NSString* logString = [NSString stringWithFormat:@"%@\n%@\n%@\n", description, httpResponse, json];
    ANLogHTTP(@"%@", logString);
#endif

}

- (void)handleResponse:(NSDictionary*)json subscriber:(id<RACSubscriber>)subscriber
{
    if ([json isKindOfClass:[NSDictionary class]])
    {
        NSString* status = json[@"status"];
        if ([status isEqualToString:@"success"])
        {
            [subscriber sendNext:json];
            [subscriber sendCompleted];
        }
        else if ([status isEqualToString:@"failure"])
        {
            NSDictionary* errorObject = @{@"status" : status};
            NSError* error = [[NSError alloc] initWithDomain:@"" code:1 userInfo:errorObject];
            [self handleError:error subscriber:subscriber];
        }
        else
        {
            [subscriber sendNext:json];
            [subscriber sendCompleted];
        }
    }
    else
    {
        [subscriber sendNext:json];
        [subscriber sendCompleted];
    }

}

- (void)handleError:(NSError*)error subscriber:(id<RACSubscriber>)subscriber
{
    [subscriber sendError:error];
}

- (void)injectSideEffectToRequest:(ANNetworkRequest*)request
{
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
}

@end

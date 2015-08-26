//
//  ZZNetworkTransport.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTransport.h"
#import "ANErrorBuilder.h"

@implementation ZZNetworkTransport

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setBaseURL:apiBaseURL() andAPIVersion:@""];
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
        else
        {
            NSDictionary* errorObject = json[@"error"];
            NSError* error = [ANErrorBuilder errorWithType:ANErrorTypeServer
                                                      code:[errorObject[@"code"] integerValue]
                                       descriptionArgument:errorObject[@"message"]];
            [self handleError:error subscriber:subscriber];
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
//    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"mkey"];
//    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth"];
//    
//    if (!ANIsEmpty(user))
//    {
//        NSString *authStr = [NSString stringWithFormat:@"%@:%@", user, password];
//        
//        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
//        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
//        
//        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
//        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
//    }
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
}

@end

//
//  ANNetworkSessionManager.m
//
//  Created by ANODA on 5/18/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANNetworkSessionManager.h"
#import "ANNetworkActivityManager.h"
#import "ANErrorHandler.h"
#import "AFNetworking.h"

@interface ANNetworkSessionManager ()

@end

@implementation ANNetworkSessionManager

+ (instancetype)shared
{
    static id _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [self new];
    });
    return _sharedClient;
}

- (AFHTTPRequestOperationManager *)session
{
    if (!_session)
    {
        _session = [AFHTTPRequestOperationManager new];
        _session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json; charset=utf-8", @"application/json", nil];
    }
    return _session;
}

- (void)setBaseURL:(NSString*)baseURL andAPIVersion:(NSString*)apiVersion
{
    [ANNetworkRequest setBaseURL:baseURL andAPIVersion:apiVersion];
}

#pragma mark - Public

- (RACSignal *)requestWithPath:(NSString *)path httpMethod:(ANHttpMethodType)httpMethod
{
    return [self requestWithPath:path parameters:nil httpMethod:httpMethod];
}

- (RACSignal*)requestWithPath:(NSString*)path parameters:(NSDictionary *)params httpMethod:(ANHttpMethodType)httpMethod
{
    ANNetworkRequest* request = [ANNetworkRequest requestWithPath:path parameters:params httpMethod:httpMethod];
    return [self requestWithURLSession:self.session request:request];
}

#pragma mark - Private

- (RACSignal*)requestWithURLSession:(AFHTTPRequestOperationManager*)session request:(ANNetworkRequest*)request
{
    NSString* requestDescription = [NSString stringWithFormat:@"URI: %@\n HTTP METHOD: %@\n",
                                    request.URL.absoluteString,
                                    request.HTTPMethod];
    
    RACSignal* signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[ANNetworkActivityManager shared] incrementActivityCount];
        
        AFHTTPRequestOperation* task = [session HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [[ANNetworkActivityManager shared] decrementActivityCount];
            [self logResponse:operation.response description:requestDescription json:responseObject];
            [self handleResponse:responseObject subscriber:subscriber];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [[ANNetworkActivityManager shared] decrementActivityCount];
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
            userInfo[@"requestDescription"] = requestDescription;
            NSError* taskError = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
            [self logResponse:nil description:requestDescription json:userInfo];
            [self handleError:taskError subscriber:subscriber];
        }];
        
        [session.operationQueue addOperation:task];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
    signal.name = requestDescription;
    return signal;
}

#pragma mark - Logging & handling

- (void)handleResponse:(NSDictionary*)response subscriber:(id<RACSubscriber>)subscriber
{
    NSNumber* status = response[@"code"];
    if (status.integerValue == 200)
    {
        [subscriber sendNext:response[@"response"]];
        [subscriber sendCompleted];
    }
    else
    {
        id errorObject = response[@"errors"];
        NSError* error = [ANError apiErrorWithDictionary:errorObject];
        [self handleError:error subscriber:subscriber];
    }
}

- (void)logResponse:(NSHTTPURLResponse*)httpResponse description:(NSString*)description json:(NSDictionary*)json
{
//    NSString* logString = [NSString stringWithFormat:@"%@\n%@\n%@\n", description, httpResponse, json];
//    ANLogHTTP(@"%@", logString);
}

- (void)handleError:(NSError*)error subscriber:(id<RACSubscriber>)subscriber
{
    if ([error isKindOfClass:[NSError class]])
    {
        [ANErrorHandler handleNetworkApplicationError:error];
    }
    else
    {
        [ANErrorHandler handleNetworkServerError:(ANError*)error];
    }
    [subscriber sendError:error];
}

#pragma mark - Photo Uploading

- (RACSignal*)uploadPhoto:(NSString*)photoFileLink path:(NSString*)path parameters:(NSDictionary*)params
{
    UIImage* image = [UIImage imageWithContentsOfFile:photoFileLink];
    if (!image)
    {
        return [RACSignal empty];
    }
    ANNetworkRequest* request = [ANNetworkRequest requestMultipartWithPath:path photo:image];
    return [self requestWithURLSession:self.session request:request];
}

@end

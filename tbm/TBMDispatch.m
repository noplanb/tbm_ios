//
//  TBMDispatch.m
//  tbm
//
//  Created by Sani Elfishawy on 1/6/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//
//  Used to dispatch messages (mostly error messages)from the client to the server.
//

#import "TBMDispatch.h"
#import "OBLogger.h"
#import "TBMHttpManager.h"
#import "TBMUser.h"
#import "TBMConfig.h"

static BOOL TBMDispatchEnabled = NO;

@implementation TBMDispatch

+ (void)initialize{
    DebugLog(@"Dispatch initialize");
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(receivedError:)
                                                 name: OBLoggerErrorNotification object:nil];
}

+ (void)enable{
    TBMDispatchEnabled = YES;
}

+ (void)disable{
    TBMDispatchEnabled = NO;
}

+ (void) receivedError:(NSNotification *)notification{
    if (TBMDispatchEnabled && [TBMUser getUser].isRegistered)
        [TBMDispatch dispatch: [TBMDispatch message:notification.object]];
}

+ (void) dispatch: (NSString *)msg{
    [[TBMHttpManager manager] POST:@"dispatch/post_dispatch"
                         parameters:@{SERVER_PARAMS_DISPATCH_MSG_KEY: msg,
                                      SERVER_PARAMS_DISPATCH_DEVICE_MODEL_KEY: [[UIDevice currentDevice] model],
                                      SERVER_PARAMS_DISPATCH_OS_VERSION_KEY: [[UIDevice currentDevice] systemVersion],
                                      SERVER_PARAMS_DISPATCH_ZAZO_VERSION_KEY: CONFIG_VERSION_STRING,
                                      SERVER_PARAMS_DISPATCH_ZAZO_VERSION_NUMBER_KEY: CONFIG_VERSION_NUMBER}
                            success:nil
                            failure:nil];
}

+ (NSString *) message:(NSString *)error{
    return [NSString stringWithFormat:@"%@\n\n\n%@", error, [TBMDispatch logString]];
}

+ (NSString *)logString{
    NSArray *logLines = [[OBLogger instance] logLines];
    NSString *line;
    NSString *r = @"";

    for (line in logLines){
        r = [r stringByAppendingString:line];
        r = [r stringByAppendingString:@"\n"];
    }
    return r;
}

@end

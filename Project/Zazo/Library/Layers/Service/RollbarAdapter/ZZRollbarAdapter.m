//
//  ZZRollbarAdapter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/18/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZRollbarAdapter.h"
#import "OBLogger.h"
#import "Rollbar.h"
#import "ZZCommonNetworkTransportService.h"
#import "ZZRollbarConstants.h"
#import "ZZApplicationStateInfoGenerator.h"

@implementation ZZRollbarAdapter

+ (instancetype)shared
{
    static id _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [self new];
    });
    return _sharedClient;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_loggerReceivedError:)
                                                     name:OBLoggerErrorNotification object:nil];
        
        RollbarConfiguration *config = [RollbarConfiguration configuration];
        config.crashLevel = @"critical";
        [Rollbar initWithAccessToken:kRollBarToken configuration:config];
        
        [RACObserve([ZZStoredSettingsManager shared], serverEndpointState) subscribeNext:^(NSNumber* x) {
            
            ZZConfigServerState serverState = [x integerValue];
            config.environment = ZZDispatchServerStateStringFromEnumValue(serverState);
        }];
        
        [RACObserve([ZZStoredSettingsManager shared], shouldUseServerLogging) subscribeNext:^(NSNumber* x) {
            
            #ifdef NETTEST
            self.endpointType = ZZDispatchEndpointRollbar;
            #else
                BOOL shouldUseServerLogging = [x boolValue];
                self.endpointType = shouldUseServerLogging ? ZZDispatchEndpointServer : ZZDispatchEndpointRollbar;
            #endif
        }];

        [OBLogger instance].writeToConsole = YES;

        self.enabled = YES;
    }
    return self;
}

- (void)updateUserFullName:(NSString*)fullName phone:(NSString*)phone itemID:(NSString *)itemID
{
    RollbarConfiguration *config = [Rollbar currentConfiguration];
    [config setPersonId:[NSObject an_safeString:itemID]
               username:[NSObject an_safeString:fullName]
                  email:[NSObject an_safeString:phone]];
}

- (void)logMessage:(NSString*)message
{
    [self logMessage:message level:ZZDispatchLevelDebug];
}

- (void)logMessage:(NSString*)message level:(ZZDispatchLevel)level
{
    if (level == ZZDispatchLevelError)
    {
        message = [NSString stringWithFormat:@"%@\n\n\n%@", [NSObject an_safeString:message], [self _logString]];
    }
    message = [message stringByAppendingFormat:@"\n%@", [ZZApplicationStateInfoGenerator globalStateString]];

    if (self.endpointType == ZZDispatchEndpointServer)
    {
        [[ZZCommonNetworkTransportService logMessage:message] subscribeNext:^(id x) {}];
    }
    else
    {
        NSString *levelString = ZZDispatchLevelStringFromEnumValue(level);
        [Rollbar logWithLevel:levelString message:message];
    }
}


#pragma mark - Private

- (void)_loggerReceivedError:(NSNotification*)notification
{
    ANDispatchBlockToBackgroundQueue(^{
//        ZZUserDomainModel* me = [ZZUserDataProvider authenticatedUser]; //TODO: discuss with Sani
        if (self.isEnabled) //&& self && me.isRegistered)
        {
            [self logMessage:notification.object level:ZZDispatchLevelError];
        }
    });
}

- (NSString*)_logString
{
    NSArray* logLines = [[OBLogger instance] logLines];
    NSString* line;
    NSString* r = @"";
    
    for (line in logLines)
    {
        r = [r stringByAppendingString:line];
        r = [r stringByAppendingString:@"\n"];
    }
    return r;
}

@end

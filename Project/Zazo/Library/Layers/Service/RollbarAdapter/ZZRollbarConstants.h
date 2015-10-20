//
//  ZZRollbarConstants.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/19/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZStoredSettingsManager.h" //TODO: move enum to separate file

typedef NS_ENUM(NSInteger, ZZDispatchLevel) {
    ZZDispatchLevelDebug,
    ZZDispatchLevelInfo,
    ZZDispatchLevelWarning,
    ZZDispatchLevelError,
    ZZDispatchLevelCritical
};


NSString* ZZDispatchLevelStringFromEnumValue(ZZDispatchLevel);
ZZDispatchLevel ZZDispatchLevelEnumValueFromSrting(NSString*);


typedef NS_ENUM(NSInteger, ZZDispatchEndpoint) {
    ZZDispatchEndpointRollbar,
    ZZDispatchEndpointServer
};



#pragma mark - Server State

NSString* ZZDispatchServerStateStringFromEnumValue(ZZConfigServerState);
ZZConfigServerState ZZDispatchServerStateEnumValueFromSrting(NSString*);

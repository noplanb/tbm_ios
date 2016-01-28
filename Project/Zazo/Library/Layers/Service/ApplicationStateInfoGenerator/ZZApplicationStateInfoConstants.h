//
//  ZZApplicationStateInfoConstants.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/19/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoStatuses.h"
#import "ZZStoredSettingsManager.h"


#pragma mark - Outgoing

NSString* ZZOutgoingVideoInfoStringFromEnumValue(ZZVideoOutgoingStatus);
ZZVideoOutgoingStatus ZZOutgoingVideoInfoEnumValueFromString(NSString *);


#pragma mark - Incoming

NSString* ZZIncomingVideoInfoStringFromEnumValue(ZZVideoIncomingStatus);
ZZVideoIncomingStatus ZZIncomingVideoInfoEnumValueFromString(NSString *);


#pragma mark - Server

NSString* ZZServerFormattedStringFromEnumValue(ZZConfigServerState);


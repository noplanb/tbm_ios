/**
 * Events flow data source - proxy for user defaults
 *
 * Created by Maksim Bazarov on 10/06/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "TBMEventsFlowModuleDataSource.h"

NSString
        *const kInviteHintNSUDkey,
        *const kInviteSomeoneElseNSUDkey,
        *const kPlayHintNSUDkey,
        *const kRecordHintNSUDkey,
        *const kSentHintNSUDkey,
        *const kViewedHintNSUDkey,
        *const kMessageWelcomeHintNSUDkey,
// Events state
        *const kMesagePlayedNSUDkey,
        *const kMesageRecordedNSUDkey;

@interface TBMEventsFlowDataSource : NSObject <TBMEventsFlowModuleDataSource>

@end
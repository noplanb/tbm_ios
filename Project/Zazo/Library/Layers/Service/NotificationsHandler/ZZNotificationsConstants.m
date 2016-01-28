//
//  ZZNotificationsConstants.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZNotificationsConstants.h"

static NSString *notificationsTypeString[] = {
    @"none",
    @"video_received",
    @"video_status_update"
};

NSString* ZZNotificationTypeStringFromEnumValue(ZZNotificationType type)
{
    return notificationsTypeString[type];
}

ZZNotificationType ZZNotificationTypeEnumValueFromString(NSString *string)
{
    NSArray* array = [NSArray arrayWithObjects:notificationsTypeString count:3];
    NSInteger index = [array indexOfObject:string];
    if (index == NSNotFound)
    {
        return ZZNotificationTypeNone;
    }
    return index;
}
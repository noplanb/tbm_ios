//
//  ZZNotificationsConstants.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

static NSString *NOTIFICATION_TARGET_MKEY_KEY = @"target_mkey";
static NSString *NOTIFICATION_FROM_MKEY_KEY = @"from_mkey";
static NSString *NOTIFICATION_SENDER_NAME_KEY = @"sender_name";
static NSString *NOTIFICATION_VIDEO_ID_KEY = @"video_id";
static NSString *NOTIFICATION_TO_MKEY_KEY = @"to_mkey";
static NSString *NOTIFICATION_STATUS_KEY = @"status";
static NSString *NOTIFICATION_TYPE_KEY = @"type";

static NSString *NOTIFICATION_TYPE_VIDEO_RECEIVED = @"video_received";
static NSString *NOTIFICATION_TYPE_VIDEO_STATUS_UPDATE = @"video_status_update";
static NSString *NOTIFICATION_TYPE_MESSAGE_RECEIVED = @"message_received";

//local notifs

static NSString *NOTIFICATION_STATUS_DOWNLOADED = @"downloaded";
static NSString *NOTIFICATION_STATUS_VIEWED = @"viewed";


typedef NS_ENUM(NSInteger, ZZNotificationType)
{
    ZZNotificationTypeNone,
    ZZNotificationTypeVideoReceived,
    ZZNotificationTypeVideoStatusUpdate,
    ZZNotificationTypeMessageReceived    
};


NSString *ZZNotificationTypeStringFromEnumValue(ZZNotificationType);
ZZNotificationType ZZNotificationTypeEnumValueFromString(NSString *);
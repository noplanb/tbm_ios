//
//  ZZGridActionHandlerEnums.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

//typedef NS_ENUM(NSInteger, TBMEventFlowEvent)
//{
//    TBMEventFlowEventNone,
//
//    // Application
//
//    TBMEventFlowEventApplicationDidLaunch,
//    TBMEventFlowEventApplicationDidEnterBackground,
//
//    // Friends
//
//    TBMEventFlowEventFriendDidAdd,
//    TBMEventFlowEventFriendDidAddWithoutApp,
//
//    // Messages
//
//    TBMEventFlowEventMessageDidReceive,
//    TBMEventFlowEventMessageDidSend,
//    TBMEventFlowEventMessageDidStartPlaying,
//    TBMEventFlowEventMessageDidStopPlaying,
//    TBMEventFlowEventMessageDidStartRecording,
//    TBMEventFlowEventMessageDidRecorded,
//    TBMEventFlowEventMessageDidViewed,
//
//    // Hints
//
//    TBMEventFlowEventSentHintDidDismiss,
//    TBMEventFlowEventFeatureUsageHintDidDismiss,
//
//    // Unlocks dialogs
//
//    TBMEventFlowEventFrontCameraUnlockDialogDidDismiss,
//    TBMEventFlowEventAbortRecordingUnlockDialogDidDismiss,
//    TBMEventFlowEventDeleteFriendUnlockDialogDidDismiss,
//    TBMEventFlowEventEarpieceUnlockDialogDidDismiss,
//    TBMEventFlowEventSpinUnlockDialogDidDismiss,
//};


typedef NS_ENUM(NSInteger, ZZGridActionEventType)
{
    ZZGridActionEventTypeGridLoaded, // done
    ZZGridActionEventTypeMessageDidStopPlaying, // done
    ZZGridActionEventTypeFriendDidAdd, // done
    ZZGridActionEventTypeMessageDidReceive,
    ZZGridActionEventTypeMessageDidSend,
    ZZGridActionEventTypeMessageOurVideoWasViewed,
    ZZGridActionEventTypeUsageHintDidDismiss,  // done
    ZZGridActionEventTypeAbortRecordingUnlockDialogDidDismiss, // max
    ZZGridActionEventTypeDeleteFriendUnlockDialogDidDismiss, // max
    ZZGridActionEventTypeEarpieceUnlockDialogDidDismiss, // max
    ZZGridActionEventTypeSpinUnlockDialogDidDismiss // max
};

typedef NS_ENUM(NSInteger, ZZGridActionFeatureType)
{
    ZZGridActionFeatureTypeSwitchCamera,
    ZZGridActionFeatureTypeAbortRec,
    ZZGridActionFeatureTypeDeleteFriend,
    ZZGridActionFeatureTypeEarpiece,
    ZZGridActionFeatureTypeSpinWheel,

    //Add new above
    ZZGridActionFeatureTypeTotal,
};

NSString* ZZGridActionFeatureTypeStringFromEnumValue(ZZGridActionFeatureType);
ZZGridActionFeatureType ZZGridActionFeatureTypeEnumValueFromSrting(NSString*);



@interface ZZGridActionHandlerEnums : NSObject

@end

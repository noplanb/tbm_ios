//
// Created by Maksim Bazarov on 14/09/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

/**
 * Enum of possible events for throwEvent:
 */
typedef NS_ENUM(NSInteger, TBMEventFlowEvent)
{
    TBMEventFlowEventNone,

    // Application

    TBMEventFlowEventApplicationDidLaunch,
    TBMEventFlowEventApplicationDidEnterBackground,

    // Friends

    TBMEventFlowEventFriendDidAdd,
    TBMEventFlowEventFriendDidAddWithoutApp,

    // Messages

    TBMEventFlowEventMessageDidReceive,
    TBMEventFlowEventMessageDidSend,
    TBMEventFlowEventMessageDidStartPlaying,
    TBMEventFlowEventMessageDidStopPlaying,
    TBMEventFlowEventMessageDidStartRecording,
    TBMEventFlowEventMessageDidRecorded,
    TBMEventFlowEventMessageDidViewed,

    // Hints

    TBMEventFlowEventSentHintDidDismiss,
    TBMEventFlowEventFeatureUsageHintDidDismiss,

    // Unlocks dialogs

    TBMEventFlowEventFrontCameraUnlockDialogDidDismiss,
    TBMEventFlowEventAbortRecordingUnlockDialogDidDismiss,
    TBMEventFlowEventDeleteFriendUnlockDialogDidDismiss,
    TBMEventFlowEventEarpieceUnlockDialogDidDismiss,
    TBMEventFlowEventSpinUnlockDialogDidDismiss,
};

//
//  ZZGridActionHandlerEnums.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

typedef NS_ENUM(NSInteger, ZZGridActionEventType)
{
    ZZGridActionEventTypeGridNone,

    ZZGridActionEventTypeDontHaveFriends,
    ZZGridActionEventTypeGridLoaded,
    ZZGridActionEventTypeBecomeMessage,
    ZZGridActionEventTypeMessageDidPlayed,
    ZZGridActionEventTypeFriendAddedToGrid,
    ZZGridActionEventTypeMessageDidSent,
    ZZGridActionEventTypeMessageViewed,
    ZZGridActionEventTypeSentZazo,
    ZZGridActionEventTypeFriendDidInvited,

    ZZGridActionEventTypeFrontCameraFeatureUnlocked,
    ZZGridActionEventTypeAbortRecordingFeatureUnlocked,
    ZZGridActionEventTypeDeleteFriendsFeatureUnlocked,
    ZZGridActionEventTypeFullscreenFeatureUnlocked,
    ZZGridActionEventTypePlaybackControlsFeatureUnlocked,
    ZZGridActionEventTypeEarpieceFeatureUnlocked,
    ZZGridActionEventTypeSpinUsageFeatureUnlocked
};

typedef NS_ENUM(NSInteger, ZZGridActionFeatureType) // Do not forget update [ZZRemoteUnlockedFeaturesUpdater featureNames] after editing
{
    ZZGridActionEventTypeNone = -1,
    ZZGridActionFeatureTypeSwitchCamera,
    ZZGridActionFeatureTypeAbortRec,
    ZZGridActionFeatureTypeDeleteFriend,
    ZZGridActionFeatureTypeFullscreen,
    ZZGridActionFeatureTypePlaybackControls,
    ZZGridActionFeatureTypeEarpiece,
    ZZGridActionFeatureTypeSpinWheel,
    
    //Add new above
    ZZGridActionFeatureTypeTotal,
};


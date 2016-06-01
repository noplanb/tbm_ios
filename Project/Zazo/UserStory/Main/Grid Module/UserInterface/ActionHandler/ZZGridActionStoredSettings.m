//
//  ZZGridActionStoredSettings.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionStoredSettings.h"
#import "NSObject+ANUserDefaults.h"

NSString * const ZZFeatureUnlockedNotificationName = @"ZZFeatureUnlockedNotificationName";

static NSString *const kZZHintsDidStartPlayKey = @"kZZHintsDidStartPlayKey";
static NSString *const kZZHintsDidStartRecordKey = @"kZZHintsDidStartRecordKey";
static NSString *const kInviteHintDidShowKey = @"kInviteHintDidShowKey";
static NSString *const kInviteSomeoneElseKey = @"kInviteSomeoneElseKey";
static NSString *const kPlayHintDidShowKey = @"kPlayHintDidShowKey";
static NSString *const kRecordHintDidShowKey = @"kRecordHintDidShowKey";
static NSString *const kRecordWelcomeHintDidShowKey = @"kRecordWelcomeHintDidShowKey";
static NSString *const kSentHintDidShowKey = @"kSentHintDidShowKey";
static NSString *const kViewedHintDidShowKey = @"kViewedHintDidShowKey";
static NSString *const kWelcomeHintDidShowKey = @"kWelcomeHintDidShowKey";
static NSString *const kHoldToRecordAndTapToPlayKey = @"khHldToRecordAndTapToPlayKey";
static NSString *const kInviteSomeoneElseShowedDuringSession = @"inviteSomeoneElseShowedDuringSession";
static NSString *const kIncomingVideoWasPlayedKey = @"incomingVideoWasPlayed";

// Features:

static NSString *const kAbortRecordFeatureEnabledKey = @"kAbortRecordUsageHintDidShowKey";
static NSString *const kDeleteFriendFeatureEnabledKey = @"kDeleteFriendUsageUsageHintDidShowKey";
static NSString *const kEarpieceFeatureEnabledKey = @"kEarpieceUsageUsageHintDidShowKey";
static NSString *const kSpinFeatureEnabledKey = @"kSpinUsageUsageUsageHintDidShowKey";
static NSString *const kFrontCameraFeatureEnabledKey = @"kFrontCameraUsageUsageHintDidShowKey";
static NSString *const kFullscreenFeatureEnabledKey = @"kFullscreenFeatureEnabledKey";
static NSString *const kPlaybackControlsFeatureEnabledKey = @"kPlaybackControlsFeatureEnabledKey";

@implementation ZZGridActionStoredSettings

@dynamic hintsDidStartRecord;
@dynamic hintsDidStartPlay;
@dynamic deleteFriendFeatureEnabled;
@dynamic earpieceFeatureEnabled;
@dynamic switchCameraFeatureEnabled;
@dynamic inviteHintWasShown;
@dynamic inviteSomeoneHintWasShown;
@dynamic playHintWasShown;
@dynamic recordHintWasShown;
@dynamic recordWelcomeHintWasShown;
@dynamic sentHintWasShown;
@dynamic carouselFeatureEnabled;
@dynamic viewedHintWasShown;
@dynamic welcomeHintWasShown;
@dynamic holdToRecordAndTapToPlayWasShown;
@dynamic isInviteSomeoneElseShowedDuringSession;
@dynamic incomingVideoWasPlayed;
@dynamic fullscreenFeatureEnabled;
@dynamic playbackControlsFeatureEnabled;

+ (instancetype)shared
{
    static id _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [self new];
    });
    return _sharedClient;
}

- (void)reset
{
    [ZZGridActionStoredSettings shared].inviteHintWasShown = NO;
    [ZZGridActionStoredSettings shared].playHintWasShown = NO;
    [ZZGridActionStoredSettings shared].recordHintWasShown = NO;
    [ZZGridActionStoredSettings shared].sentHintWasShown = NO;
    [ZZGridActionStoredSettings shared].viewedHintWasShown = NO;
    [ZZGridActionStoredSettings shared].inviteSomeoneHintWasShown = NO;
    [ZZGridActionStoredSettings shared].welcomeHintWasShown = NO;
    [ZZGridActionStoredSettings shared].recordWelcomeHintWasShown = NO;
    [ZZGridActionStoredSettings shared].isInviteSomeoneElseShowedDuringSession = NO;
    [ZZGridActionStoredSettings shared].holdToRecordAndTapToPlayWasShown = NO;
    [ZZGridActionStoredSettings shared].hintsDidStartPlay = NO;
    [ZZGridActionStoredSettings shared].hintsDidStartRecord = NO;
    [ZZGridActionStoredSettings shared].incomingVideoWasPlayed = NO;

    [ZZGridActionStoredSettings shared].switchCameraFeatureEnabled = NO;
    [ZZGridActionStoredSettings shared].abortRecordingFeatureEnabled = NO;
    [ZZGridActionStoredSettings shared].deleteFriendFeatureEnabled = NO;
    [ZZGridActionStoredSettings shared].earpieceFeatureEnabled = NO;
    [ZZGridActionStoredSettings shared].carouselFeatureEnabled = NO;
    [ZZGridActionStoredSettings shared].fullscreenFeatureEnabled = NO;
    [ZZGridActionStoredSettings shared].playbackControlsFeatureEnabled = NO;

    [[EverSentHelper sharedInstance] clear];
}

- (void)enableAllFeatures
{
    BOOL isEnabled = YES;
    [ZZGridActionStoredSettings shared].switchCameraFeatureEnabled = isEnabled;
    [ZZGridActionStoredSettings shared].abortRecordingFeatureEnabled = isEnabled;
    [ZZGridActionStoredSettings shared].deleteFriendFeatureEnabled = isEnabled;
    [ZZGridActionStoredSettings shared].earpieceFeatureEnabled = isEnabled;
    [ZZGridActionStoredSettings shared].carouselFeatureEnabled = isEnabled;
    [ZZGridActionStoredSettings shared].fullscreenFeatureEnabled = isEnabled;
    [ZZGridActionStoredSettings shared].playbackControlsFeatureEnabled = isEnabled;
}


#pragma mark - Hints

- (void)setIncomingVideoWasPlayed:(BOOL)incomingVideoWasPlayed
{
    [NSObject an_updateObject:@(incomingVideoWasPlayed) forKey:kIncomingVideoWasPlayedKey];
}

- (BOOL)incomingVideoWasPlayed
{
    return [[NSObject an_objectForKey:kIncomingVideoWasPlayedKey] boolValue];
}

- (void)setIsInviteSomeoneElseShowedDuringSession:(BOOL)isInviteSomeoneElseShowedDuringSession
{
    [NSObject an_updateObject:@(isInviteSomeoneElseShowedDuringSession) forKey:kInviteSomeoneElseShowedDuringSession];
}

- (BOOL)isInviteSomeoneElseShowedDuringSession
{
    return [[NSObject an_objectForKey:kInviteSomeoneElseShowedDuringSession] boolValue];
}

//hints did start view
- (void)setHintsDidStartPlay:(BOOL)hintsDidStartPlay
{   //convension, legacy support
    [NSObject an_updateObject:@(hintsDidStartPlay) forKey:kZZHintsDidStartPlayKey];
}

- (BOOL)hintsDidStartPlay
{
    return [[NSObject an_objectForKey:kZZHintsDidStartPlayKey] boolValue];
}

//hints did start record
- (void)setHintsDidStartRecord:(BOOL)hintsDidStartRecord
{   //convension, legacy support
    [NSObject an_updateObject:@(hintsDidStartRecord) forKey:kZZHintsDidStartRecordKey];
}

- (BOOL)hintsDidStartRecord
{
    return [[NSObject an_objectForKey:kZZHintsDidStartRecordKey] boolValue];
}

- (BOOL)inviteHintWasShown
{
    return [[NSObject an_objectForKey:kInviteHintDidShowKey] boolValue];
}

- (void)setInviteHintWasShown:(BOOL)inviteHintWasShown
{
    [NSObject an_updateBool:inviteHintWasShown forKey:kInviteHintDidShowKey];
}

- (BOOL)inviteSomeoneHintWasShown
{
    return [[NSObject an_objectForKey:kInviteSomeoneElseKey] boolValue];
}

- (void)setInviteSomeoneHintWasShown:(BOOL)inviteSomeoneHintWasShown
{
    [NSObject an_updateBool:inviteSomeoneHintWasShown forKey:kInviteSomeoneElseKey];
}

- (BOOL)playHintWasShown
{
    return [[NSObject an_objectForKey:kPlayHintDidShowKey] boolValue];
}

- (void)setPlayHintWasShown:(BOOL)playHintWasShown
{
    [NSObject an_updateBool:playHintWasShown forKey:kPlayHintDidShowKey];
}

- (BOOL)recordHintWasShown
{
    return [[NSObject an_objectForKey:kRecordHintDidShowKey] boolValue];
}

- (void)setRecordHintWasShown:(BOOL)recordHintWasShown
{
    [NSObject an_updateBool:recordHintWasShown forKey:kRecordHintDidShowKey];
}

- (BOOL)recordWelcomeHintWasShown
{
    return [[NSObject an_objectForKey:kRecordWelcomeHintDidShowKey] boolValue];
}

- (void)setRecordWelcomeHintWasShown:(BOOL)recordWelcomeHintWasShown
{
    [NSObject an_updateBool:recordWelcomeHintWasShown forKey:kRecordWelcomeHintDidShowKey];
}

- (BOOL)sentHintWasShown
{
    return [[NSObject an_objectForKey:kSentHintDidShowKey] boolValue];
}

- (void)setSentHintWasShown:(BOOL)sentHintWasShown
{
    [NSObject an_updateBool:sentHintWasShown forKey:kSentHintDidShowKey];
}

- (BOOL)viewedHintWasShown
{
    return [[NSObject an_objectForKey:kViewedHintDidShowKey] boolValue];
}

- (void)setViewedHintWasShown:(BOOL)viewedHintDidShow
{
    [NSObject an_updateBool:viewedHintDidShow forKey:kViewedHintDidShowKey];
}

- (BOOL)welcomeHintWasShown
{
    return [[NSObject an_objectForKey:kWelcomeHintDidShowKey] boolValue];
}

- (void)setWelcomeHintWasShown:(BOOL)welcomeHintWasShown
{
    [NSObject an_updateBool:welcomeHintWasShown forKey:kWelcomeHintDidShowKey];
}

- (BOOL)holdToRecordAndTapToPlayWasShown
{
    return [[NSObject an_objectForKey:kHoldToRecordAndTapToPlayKey] boolValue];
}

- (void)setHoldToRecordAndTapToPlayWasShown:(BOOL)holdToRecordAndTapToPlayWasShown
{
    [NSObject an_updateBool:holdToRecordAndTapToPlayWasShown forKey:kHoldToRecordAndTapToPlayKey];
}


#pragma mark Features

- (BOOL)abortRecordingFeatureEnabled
{
    return [[NSObject an_objectForKey:kAbortRecordFeatureEnabledKey] boolValue];
}

- (void)setAbortRecordingFeatureEnabled:(BOOL)flag
{
    [NSObject an_updateBool:flag forKey:kAbortRecordFeatureEnabledKey];
    
    if (flag)
    {
        [self _postFeatureUnlockedNotification];
    }

}

- (BOOL)deleteFriendFeatureEnabled
{
    return [[NSObject an_objectForKey:kDeleteFriendFeatureEnabledKey] boolValue];
}

- (void)setDeleteFriendFeatureEnabled:(BOOL)flag
{
    [NSObject an_updateBool:flag forKey:kDeleteFriendFeatureEnabledKey];
    
    if (flag)
    {
        [self _postFeatureUnlockedNotification];
    }

    
}

- (BOOL)earpieceFeatureEnabled
{
    return [[NSObject an_objectForKey:kEarpieceFeatureEnabledKey] boolValue];
}

- (void)setEarpieceFeatureEnabled:(BOOL)flag
{
    [NSObject an_updateBool:flag forKey:kEarpieceFeatureEnabledKey];
    
    if (flag)
    {
        [self _postFeatureUnlockedNotification];
    }
    
}

- (BOOL)switchCameraFeatureEnabled
{
    return [[NSObject an_objectForKey:kFrontCameraFeatureEnabledKey] boolValue];
}

- (void)setSwitchCameraFeatureEnabled:(BOOL)flag
{
    [NSObject an_updateBool:flag forKey:kFrontCameraFeatureEnabledKey];
    
    if (flag)
    {
        [self _postFeatureUnlockedNotification];
    }

}

- (BOOL)carouselFeatureEnabled
{
    return [[NSObject an_objectForKey:kSpinFeatureEnabledKey] boolValue];
}

- (void)setCarouselFeatureEnabled:(BOOL)flag
{
    [NSObject an_updateBool:flag forKey:kSpinFeatureEnabledKey];
    
    if (flag)
    {
        [self _postFeatureUnlockedNotification];
    }

}

- (BOOL)playbackControlsFeatureEnabled
{
    return [[NSObject an_objectForKey:kPlaybackControlsFeatureEnabledKey] boolValue];
}

- (void)setPlaybackControlsFeatureEnabled:(BOOL)flag
{
    [NSObject an_updateBool:flag forKey:kPlaybackControlsFeatureEnabledKey];
    
    if (flag)
    {
        [self _postFeatureUnlockedNotification];
    }

}

- (BOOL)fullscreenFeatureEnabled
{
    return [[NSObject an_objectForKey:kFullscreenFeatureEnabledKey] boolValue];
}

- (void)setFullscreenFeatureEnabled:(BOOL)flag
{
    [NSObject an_updateBool:flag forKey:kFullscreenFeatureEnabledKey];
    
    if (flag)
    {
        [self _postFeatureUnlockedNotification];
    }
}

#pragma mark Notifications

- (void)_postFeatureUnlockedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ZZFeatureUnlockedNotificationName
                                                        object:nil];

}

@end

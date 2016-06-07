//
//  ZZGridActionStoredSettings.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionHandlerEnums.h"

//TODO: make extern constants or incapsulate it here later

extern NSString * const ZZFeatureUnlockedNotificationName;

@interface ZZGridActionStoredSettings : NSObject

@property (nonatomic, assign) ZZGridActionFeatureType lastUnlockedFeature;

#pragma mark - Hints

@property (nonatomic, assign) BOOL inviteHintWasShown; // case C2466
@property (nonatomic, assign) BOOL playHintWasShown; // C2468, C2469, C2470, C2520
@property (nonatomic, assign) BOOL recordHintWasShown; // C2472, C2473, C2474
@property (nonatomic, assign) BOOL sentHintWasShown;
@property (nonatomic, assign) BOOL viewedHintWasShown;
@property (nonatomic, assign) BOOL inviteSomeoneHintWasShown;
@property (nonatomic, assign) BOOL welcomeHintWasShown;
@property (nonatomic, assign) BOOL recordWelcomeHintWasShown;
@property (nonatomic, assign) BOOL isInviteSomeoneElseShowedDuringSession;
@property (nonatomic, assign) BOOL holdToRecordAndTapToPlayWasShown;
@property (nonatomic, assign) BOOL incomingVideoWasPlayed;

@property (nonatomic, assign) BOOL hintsDidStartPlay;
@property (nonatomic, assign) BOOL hintsDidStartRecord;

#pragma mark Features

@property (nonatomic, assign) BOOL switchCameraFeatureEnabled;
@property (nonatomic, assign) BOOL abortRecordingFeatureEnabled;
@property (nonatomic, assign) BOOL deleteFriendFeatureEnabled;
@property (nonatomic, assign) BOOL earpieceFeatureEnabled;
@property (nonatomic, assign) BOOL carouselFeatureEnabled;
@property (nonatomic, assign) BOOL fullscreenFeatureEnabled;
@property (nonatomic, assign) BOOL playbackControlsFeatureEnabled;

+ (instancetype)shared;

- (void)reset;

- (void)enableAllFeatures;

@end

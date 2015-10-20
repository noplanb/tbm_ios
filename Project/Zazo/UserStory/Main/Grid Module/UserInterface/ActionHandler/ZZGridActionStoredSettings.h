//
//  ZZGridActionStoredSettings.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionHandlerEnums.h"

//TODO: make extern constants or incapsulate it here later

static NSString* const kFriendIdDefaultKey = @"userIdDefaultKey";
static NSString* const kSendMessageCounterKey = @"sendMessageCounterKey";
static NSString* const kUsersIdsArrayKey = @"usersIdsArrayKey";

@interface ZZGridActionStoredSettings : NSObject

@property (nonatomic, assign) ZZGridActionFeatureType lastUnlockedFeature;

#pragma mark - Hints

@property (nonatomic, assign) BOOL inviteHintWasShown;
@property (nonatomic, assign) BOOL playHintWasShown;
@property (nonatomic, assign) BOOL recordHintWasShown;
@property (nonatomic, assign) BOOL sentHintWasShown;
@property (nonatomic, assign) BOOL viewedHintWasShown;
@property (nonatomic, assign) BOOL inviteSomeoneHintWasShown;
@property (nonatomic, assign) BOOL welcomeHintWasShown;

@property (nonatomic, assign) BOOL frontCameraHintWasShown;
@property (nonatomic, assign) BOOL abortRecordHintWasShown;
@property (nonatomic, assign) BOOL deleteFriendHintWasShown;
@property (nonatomic, assign) BOOL earpieceHintWasShown;
@property (nonatomic, assign) BOOL spinHintWasShown;
@property (nonatomic, assign) BOOL recordWelcomeHintWasShown;
@property (nonatomic, assign) BOOL isInviteSomeoneElseShowedDuringSession;

@property (nonatomic, assign) BOOL holdToRecordAndTapToPlayWasShown;
@property (nonatomic, assign) BOOL incomingVideoWasPlayed;

@property (nonatomic, assign) BOOL hintsDidStartPlay;
@property (nonatomic, assign) BOOL hintsDidStartRecord;

+ (instancetype)shared;

- (void)reset;

@end

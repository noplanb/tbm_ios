//
//  ANSystemSettingsManager.h
//  Zazo
//
//  Created by ANODA on 3/18/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

@interface ZZStoredSettingsManager : NSObject

typedef NS_ENUM(NSUInteger, ZZConfigServerState) {
    ZZConfigServerStateProduction = 0,
    ZZConfigServerStateDeveloper = 1,
    ZZConfigServerStateCustom = 2,
};


#pragma mark - Configutation

@property (nonatomic, assign) BOOL debugModeEnabled;
@property (nonatomic, assign) BOOL shouldUseRollBarSDK;
@property (nonatomic, assign) BOOL forceSMS;
@property (nonatomic, assign) BOOL forceCall;

@property (nonatomic, strong) NSString* serverURLString;
@property (nonatomic, assign) ZZConfigServerState serverEndpointState;

#pragma mark - Messages

@property (nonatomic, assign) BOOL messageEverRecorded;
@property (nonatomic, assign) BOOL messageEverPlayed;


#pragma mark - Hints

@property (nonatomic, assign) BOOL hintsDidStartPlay;
@property (nonatomic, assign) BOOL hintsDidStartRecord;

#pragma mark - User

@property (nonatomic, copy) NSString* userID;
@property (nonatomic, copy) NSString* authToken;

@property (nonatomic, assign) BOOL abortRecordUsageHintDidShow;


@property (nonatomic, assign) BOOL deleteFriendUsageUsageHintDidShow;
@property (nonatomic, assign) BOOL earpieceUsageUsageHintDidShow;
@property (nonatomic, assign) BOOL frontCameraUsageUsageHintDidShow;
@property (nonatomic, assign) BOOL inviteHintDidShow;
@property (nonatomic, assign) BOOL inviteSomeoneElseKey;
@property (nonatomic, assign) BOOL playHintDidShow;
@property (nonatomic, assign) BOOL recordHintDidShow;
@property (nonatomic, assign) BOOL recordWelcomeHintDidShow;
@property (nonatomic, assign) BOOL sentHintDidShow;
@property (nonatomic, assign) BOOL spinUsageUsageUsageHintDidShow;
@property (nonatomic, assign) BOOL viewedHintDidShow;
@property (nonatomic, assign) BOOL welcomeHintDidShow;

@property (nonatomic, assign) NSUInteger lastUnlockedFeature;



+ (instancetype)shared;

@end

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


#pragma mark - User

@property (nonatomic, copy) NSString* userID;
@property (nonatomic, copy) NSString* authToken;


#pragma mark - Hints

@property (nonatomic, assign) BOOL hintsDidStartPlay;
@property (nonatomic, assign) BOOL hintsDidStartRecord;
@property (nonatomic, assign) BOOL abortRecordHintWasShown;
@property (nonatomic, assign) BOOL deleteFriendHintWasShown;
@property (nonatomic, assign) BOOL earpieceHintWasShown;
@property (nonatomic, assign) BOOL frontCameraHintWasShown;
@property (nonatomic, assign) BOOL inviteHintWasShown;
@property (nonatomic, assign) BOOL inviteSomeoneHintWasShown;
@property (nonatomic, assign) BOOL playHintWasShown;
@property (nonatomic, assign) BOOL recordHintWasShown;
@property (nonatomic, assign) BOOL recordWelcomeHintWasShown;
@property (nonatomic, assign) BOOL sentHintWasShown;
@property (nonatomic, assign) BOOL spinHintWasShown;
@property (nonatomic, assign) BOOL viewedHintWasShown;
@property (nonatomic, assign) BOOL welcomeHintWasShown;

@property (nonatomic, assign) NSUInteger lastUnlockedFeature;



+ (instancetype)shared;

@end

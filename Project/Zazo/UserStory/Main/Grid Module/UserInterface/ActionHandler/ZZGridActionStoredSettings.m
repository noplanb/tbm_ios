//
//  ZZGridActionStoredSettings.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridActionStoredSettings.h"
#import "NSObject+ANUserDefaults.h"

static NSString* const kZZHintsDidStartPlayKey = @"kZZHintsDidStartPlayKey";
static NSString* const kZZHintsDidStartRecordKey = @"kZZHintsDidStartRecordKey";
static NSString* const kAbortRecordUsageHintDidShowKey = @"kAbortRecordUsageHintDidShowKey";
static NSString* const kDeleteFriendUsageUsageHintDidShowKey = @"kDeleteFriendUsageUsageHintDidShowKey";
static NSString* const kEarpieceUsageUsageHintDidShowKey = @"kEarpieceUsageUsageHintDidShowKey";
static NSString* const kFrontCameraUsageUsageHintDidShowKey = @"kFrontCameraUsageUsageHintDidShowKey";
static NSString* const kInviteHintDidShowKey = @"kInviteHintDidShowKey";
static NSString* const kInviteSomeoneElseKey = @"kInviteSomeoneElseKey";
static NSString* const kPlayHintDidShowKey = @"kPlayHintDidShowKey";
static NSString* const kRecordHintDidShowKey = @"kRecordHintDidShowKey";
static NSString* const kRecordWelcomeHintDidShowKey = @"kRecordWelcomeHintDidShowKey";
static NSString* const kSentHintDidShowKey = @"kSentHintDidShowKey";
static NSString* const kSpinUsageUsageUsageHintDidShowKey = @"kSpinUsageUsageUsageHintDidShowKey";
static NSString* const kViewedHintDidShowKey = @"kViewedHintDidShowKey";
static NSString* const kWelcomeHintDidShowKey = @"kWelcomeHintDidShowKey";
static NSString* const kHoldToRecordAndTapToPlayKey = @"khHldToRecordAndTapToPlayKey";
static NSString* const kInviteSomeoneElseShowedDuringSession = @"inviteSomeoneElseShowedDuringSession";

//static NSString *const kLastUnlockedFeatureKey = @"kLastUnlockedFeatureKey";

@implementation ZZGridActionStoredSettings

@dynamic hintsDidStartRecord;
@dynamic hintsDidStartPlay;
@dynamic deleteFriendHintWasShown;
@dynamic earpieceHintWasShown;
@dynamic frontCameraHintWasShown;
@dynamic inviteHintWasShown;
@dynamic inviteSomeoneHintWasShown;
@dynamic playHintWasShown;
@dynamic recordHintWasShown;
@dynamic recordWelcomeHintWasShown;
@dynamic sentHintWasShown;
@dynamic spinHintWasShown;
@dynamic viewedHintWasShown;
@dynamic welcomeHintWasShown;
@dynamic holdToRecordAndTapToPlayWasShown;
@dynamic isInviteSomeoneElseShowedDuringSession;

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

}

#pragma mark - Hints

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

- (BOOL)abortRecordHintWasShown
{
    return [[NSObject an_objectForKey:kAbortRecordUsageHintDidShowKey] boolValue];
}

- (void)setAbortRecordHintWasShown:(BOOL)abortRecordHintWasShown
{
    [NSObject an_updateBool:abortRecordHintWasShown forKey:kAbortRecordUsageHintDidShowKey];
}

- (BOOL)deleteFriendHintWasShown
{
    return [[NSObject an_objectForKey:kDeleteFriendUsageUsageHintDidShowKey] boolValue];
}

- (void)setDeleteFriendHintWasShown:(BOOL)deleteFriendHintWasShown
{
    [NSObject an_updateBool:deleteFriendHintWasShown forKey:kDeleteFriendUsageUsageHintDidShowKey];
    
}

- (BOOL)earpieceHintWasShown
{
    return [[NSObject an_objectForKey:kEarpieceUsageUsageHintDidShowKey] boolValue];
}

- (void)setEarpieceHintWasShown:(BOOL)earpieceHintWasShown
{
    [NSObject an_updateBool:earpieceHintWasShown forKey:kEarpieceUsageUsageHintDidShowKey];
    
}

- (BOOL)frontCameraHintWasShown
{
    return [[NSObject an_objectForKey:kFrontCameraUsageUsageHintDidShowKey] boolValue];
}

- (void)setFrontCameraHintWasShown:(BOOL)frontCameraHintWasShown
{
    [NSObject an_updateBool:frontCameraHintWasShown forKey:kFrontCameraUsageUsageHintDidShowKey];
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

- (BOOL)spinHintWasShown
{
    return [[NSObject an_objectForKey:kSpinUsageUsageUsageHintDidShowKey] boolValue];
}

- (void)setSpinHintWasShown:(BOOL)spinUsageUsageUsageHintDidShow
{
    [NSObject an_updateBool:spinUsageUsageUsageHintDidShow forKey:kSpinUsageUsageUsageHintDidShowKey];
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

//- (NSUInteger)lastUnlockedFeature
//{
//    NSInteger value = [[NSObject an_objectForKey:kLastUnlockedFeatureKey] integerValue];
//    NSUInteger result = value > 0 ? value : 0;
//    return result;
//}
//
//- (void)setLastUnlockedFeature:(NSUInteger)lastUnlockedFeature
//{
//    [NSObject an_updateInteger:lastUnlockedFeature forKey:kLastUnlockedFeatureKey];
//}


@end

//
//  ZZAuthInteractor.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import CoreTelephony;

#import "ZZAuthInteractor.h"
#import "ZZUserDomainModel.h"
#import "ANErrorBuilder.h"
#import <NBPhoneNumberUtil.h>
#import "ZZAccountTransportService.h"
#import "FEMObjectDeserializer.h"
#import "ZZUserDataProvider.h"
#import "ZZFriendsTransportService.h"
#import "NSObject+ANSafeValues.h"
#import "ZZStoredSettingsManager.h"
#import "NBPhoneNumber.h"
#import "ZZFriendDataProvider.h"
#import "TBMUser.h"
#import "TBMFriend.h"
#import "TBMAppDelegate+Boot.h"
#import "ZZCommonNetworkTransportService.h"
#import "ZZVideoRecorder.h"
#import "ZZFriendDataUpdater.h"
#import "ZZFriendDomainModel.h"
#import "ZZRollbarAdapter.h"

@interface ZZAuthInteractor ()

@property (nonatomic, strong) ZZUserDomainModel *currentUser;

@end

@implementation ZZAuthInteractor

- (void)loadUserData
{
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
    
#ifdef DEBUG_LOGIN_USER
    user.firstName = @"Dkkk";
    user.lastName = @"kkk";
    user.mobileNumber = @"+380974720070";
#endif
    
    if (!ANIsEmpty(user.mobileNumber))
    {
        NSError* error;
        
        NSString *nationalNumber = nil;
        NSNumber *countryCode = [[NBPhoneNumberUtil new] extractCountryCode:user.mobileNumber nationalNumber:&nationalNumber];
        if (!error)
        {
            if (!ANIsEmpty([countryCode stringValue]))
            {
                user.countryCode = [countryCode stringValue];
            }
            if (!ANIsEmpty(nationalNumber))
            {
                user.plainPhoneNumber = nationalNumber;
            }
        }
    }
    [self.output userDataLoadedSuccessfully:user];
}

- (void)registerUser:(ZZUserDomainModel*)model
{
    model.firstName = [self _cleanText:model.firstName];
    model.lastName = [self _cleanText:model.lastName];
    
    model.countryCode = [NSObject an_safeString:model.countryCode];
    model.countryCode = [self _cleanNumber:model.countryCode];
    
    model.plainPhoneNumber = [NSObject an_safeString:model.plainPhoneNumber];
    model.plainPhoneNumber = [self _cleanNumber:model.plainPhoneNumber];
    
    model.mobileNumber = [model.countryCode stringByAppendingString:model.plainPhoneNumber];
    NSError* validationError = [self _validateUserModel:model];
    
    if (!validationError)
    {
        [self.output validationCompletedSuccessfully];
        self.currentUser = [ZZUserDataProvider upsertUserWithModel:model];
        [self registerUserWithModel:self.currentUser forceCall:NO];
    }
    else
    {
        [self.output validationDidFailWithError:validationError];
    }
}

- (void)userRequestCallInsteadSmsCode
{
    [self registerUserWithModel:self.currentUser forceCall:YES];
}

- (void)validateSMSCode:(NSString*)code
{
    [[ZZAccountTransportService verifySMSCodeWithUserModel:self.currentUser code:code] subscribeNext:^(id x) {
       
        ZZUserDomainModel *user = [FEMObjectDeserializer deserializeObjectExternalRepresentation:x
                                                                                    usingMapping:[ZZUserDomainModel mapping]];
        user.isRegistered = YES;
        [ZZUserDataProvider upsertUserWithModel:user];
        
        [[ZZRollbarAdapter shared] updateUserFullName:[user fullName] phone:user.mobileNumber itemID:user.idTbm];
    
        [self.output smsCodeValidationCompletedSuccessfully];
        
        [self loadFriends];
        
    } error:^(NSError *error) {
        //TODO: separate errors
        [self.output smsCodeValidationCompletedWithError:error];
        
    }];
}

- (void)loadFriends
{
    [ZZFriendDataProvider deleteAllFriendsModels];
    
    [[ZZFriendsTransportService loadFriendList] subscribeNext:^(id x) {
        
        ANDispatchBlockToBackgroundQueue(^{
            [self gotFriends:x];
            [self detectInvitee:x];
            [self.output loadedFriendsSuccessfully];
            [self loadS3Credentials];
        });
        
    } error:^(NSError *error) {
        
        [self.output loadFriendsDidFailWithError:error];
    }];
}

- (void)loadS3Credentials
{
    ANDispatchBlockToBackgroundQueue(^{
        [[ZZCommonNetworkTransportService loadS3Credentials] subscribeNext:^(id x) {
            
            self.currentUser.isRegistered = YES;
            [ZZUserDataProvider upsertUserWithModel:self.currentUser];
            [(TBMAppDelegate*)[UIApplication sharedApplication].delegate performDidBecomeActiveActions]; //TODO: call this with new controller
            [self.output registrationFlowCompletedSuccessfully];
            
        } error:^(NSError *error) {
            
            [self.output loadS3CredentialsDidFailWithError:nil]; // TODO: create an error here
        }];
    });
}

- (NSString*)countryCodeFromPhoneSettings
{
    NSString* code = [self _countryCodeByCarrier];
    if (!code.length)
    {
        code = [self _countryCodeForCurrentLocale];
    }
    if (!code.length)
    {
        code = @"us";
    }
    return code;
}


#pragma mark - ZZAccountTransportService

- (void)registerUserWithModel:(ZZUserDomainModel*)user forceCall:(BOOL)forceCall
{
    [self _saveAuthenticatedUserMobileNumberToDefauts:user.mobileNumber]; //TODO: temp
    
    [[ZZAccountTransportService registerUserWithModel:user shouldForceCall:forceCall] subscribeNext:^(NSDictionary *authKeys) {
        
        NSString *auth = [authKeys objectForKey:@"auth"];
        NSString *mkey = [authKeys objectForKey:@"mkey"];
        
        [ZZStoredSettingsManager shared].userID = mkey;
        [ZZStoredSettingsManager shared].authToken = auth;
        
        self.currentUser.mkey = mkey;
        self.currentUser.auth = auth;
        self.currentUser = [ZZUserDataProvider upsertUserWithModel:self.currentUser];
        
        if (!forceCall)
        {
            [self.output registrationCompletedSuccessfullyWithPhoneNumber:user.mobileNumber];
        }
        
    } error:^(NSError *error) {
        [self.output registrationDidFailWithError:error];
    }];
}


#pragma mark - Validation Part

- (NSError*)_validateUserModel:(ZZUserDomainModel*)model
{
    NSError* error;

    if (ANIsEmpty(model.firstName))
    {
        return [ANErrorBuilder errorWithType:ANErrorTypeGeneral code:kFormEmptyRequiredFieldFirstName];
    }

    if (ANIsEmpty(model.lastName))
    {
        return [ANErrorBuilder errorWithType:ANErrorTypeGeneral code:kFormEmptyRequiredFieldLastName];
    }

    if (ANIsEmpty(model.countryCode))
    {
        return [ANErrorBuilder errorWithType:ANErrorTypeGeneral code:kFormEmptyRequiredFieldCountryCode];
    }
    
    if (ANIsEmpty(model.plainPhoneNumber))
    {
        return [ANErrorBuilder errorWithType:ANErrorTypeGeneral code:kFormEmptyRequiredFieldMobilePhoneNumber];
    }
    
    if (![self _isValidPhone:model.mobileNumber code:model.countryCode])
    {
        return [ANErrorBuilder errorWithType:ANErrorTypeGeneral code:kFormInvalidModilePhone];
    }
    return error;
}

- (BOOL)_isValidPhone:(NSString*)phone code:(NSString*)code
{
    NBPhoneNumberUtil *numberUtils = [NBPhoneNumberUtil new];
    NSString* region;
    if (!ANIsEmpty(code))
    {
        region = [numberUtils getRegionCodeForCountryCode:@([code integerValue])];
    }
    if (ANIsEmpty(region) || [region isEqualToString:@"ZZ"])
    {
        region = [self countryCodeFromPhoneSettings];
    }
    
    NSError *error;
    NBPhoneNumber* phoneNumber = [numberUtils parse:phone defaultRegion:region error:&error];
    if (!error)
    {
        return [numberUtils isValidNumber:phoneNumber];
    }
    return NO;
}


#pragma mark - Private

- (NSString*)_countryCodeByCarrier
{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *isoCode = [[networkInfo subscriberCellularProvider] isoCountryCode];
    if (!isoCode)
    {
        isoCode = @"";
    }
    return isoCode;
}

- (NSString*)_countryCodeForCurrentLocale
{
    NSLocale *loc = [NSLocale currentLocale];
    return [[loc objectForKey:NSLocaleCountryCode] lowercaseString];
}



/**
 *  CLEANUP!!!!
 */

- (NSString*)_cleanText:(NSString*)text
{
    NSError *error = nil;
    NSArray *rxs = @[@"\\s+", @"\\W+", @"\\d+"];
    for (NSString *rx in rxs)
    {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:rx
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        text = [regex stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:@""];
    }
    return text;
}

- (NSString*)_cleanNumber:(NSString*)phone
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\D+"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    return [regex stringByReplacingMatchesInString:phone options:0 range:NSMakeRange(0, [phone length]) withTemplate:@""];
}

- (void)gotFriends:(NSArray *)friends
{
    ANDispatchBlockToBackgroundQueue(^{
        for (ZZFriendDomainModel *friend in friends)
        {
            [ZZFriendDataUpdater upsertFriend:friend];
        }
    });
}

- (void)detectInvitee:(NSArray *)friends
{
    NSArray *sorted = [self sortedFriendsByCreatedOn:friends];
    if (sorted)
    {
        ZZFriendDomainModel *firstFriend = sorted.firstObject;
        NSString *firstFriendCreatorMkey = firstFriend.friendshipCreatorMkey;
        ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
        NSString *myMkey = user.mkey;
        user.isInvitee = ![firstFriendCreatorMkey isEqualToString:myMkey];
        self.currentUser = [ZZUserDataProvider upsertUserWithModel:user];
    }
}

- (NSArray *)sortedFriendsByCreatedOn:(NSArray *)friends
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    return [friends sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSComparisonResult result = NSOrderedSame;
        NSDictionary *dict1 = (NSDictionary *) obj1;
        NSDictionary *dict2 = (NSDictionary *) obj2;
        NSDate *date1;
        NSDate *date2;
        
        if ([dict1 isKindOfClass:[NSDictionary class]] && [dict2 isKindOfClass:[NSDictionary class]])
        {
            
            date1 = [dateFormatter dateFromString:dict1[@"connection_created_on"]];
            date2 = [dateFormatter dateFromString:dict2[@"connection_created_on"]];
        }
        
        if (date1 && date2)
        {
            result = [date1 timeIntervalSinceDate:date2] > 0 ? NSOrderedDescending : NSOrderedAscending;
        }
        return result;
    }];
}

- (void)_saveAuthenticatedUserMobileNumberToDefauts:(NSString*)number
{
    NSString* numberWithPlus = [NSString stringWithFormat:@"+%@", number];
    [[NSUserDefaults standardUserDefaults] setObject:numberWithPlus forKey:@"authenticatedMobileNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

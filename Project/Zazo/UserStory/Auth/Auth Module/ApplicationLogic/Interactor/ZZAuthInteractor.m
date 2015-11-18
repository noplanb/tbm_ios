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
#import "ZZCommonNetworkTransportService.h"
#import "ZZFriendDataUpdater.h"
#import "ZZFriendDomainModel.h"
#import "ZZRollbarAdapter.h"
#import "ZZAuthInteractorConstants.h"
#import "ZZNotificationsHandler.h"
#import "ZZRootStateObserver.h"

@interface ZZAuthInteractor ()

@property (nonatomic, strong) ZZUserDomainModel *currentUser;

@end 

@implementation ZZAuthInteractor

- (void)loadUserData
{
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];

#ifdef DEBUG_LOGIN_USER
    user.firstName = @"Isixs";
    user.lastName = @"Sani";
    user.mobileNumber = @"+16507800161";
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

        NSString* mobilePhone = [x objectForKey:@"mobile_number"];

        [ZZStoredSettingsManager shared].mobileNumber = mobilePhone;
        [ZZUserDataProvider upsertUserWithModel:user];

        [[ZZRollbarAdapter shared] updateUserFullName:[user fullName] phone:user.mobileNumber itemID:user.idTbm];

        [self.output smsCodeValidationCompletedSuccessfully];

        [self loadFriends];

        [ZZStoredSettingsManager shared].isPushNotificatonEnabled = YES;
        [ZZNotificationsHandler registerToPushNotifications];

        [[ZZRootStateObserver sharedInstance] notifyWithEvent:ZZRootStateObserverEventsUserAuthorized
                                           notificationObject:nil];

    } error:^(NSError *error) {
        //TODO: separate errors
        [self.output smsCodeValidationCompletedWithError:error];
    }];
}

- (void)loadFriends
{
    [ZZFriendDataProvider deleteAllFriendsModels];

    [[ZZFriendsTransportService loadFriendList] subscribeNext:^(id x) {
        [self.output loadedFriendsSuccessfully];
        [[ZZRootStateObserver sharedInstance] notifyWithEvent:ZZRootStateObserverEventsFriendsAfterAuthorizationLoaded
                                           notificationObject:nil];
        [self.output registrationFlowCompletedSuccessfully];

    } error:^(NSError *error) {

        [self.output loadFriendsDidFailWithError:error];
    }];
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

        NSString *auth = authKeys[@"auth"];
        NSString *mkey = authKeys[@"mkey"];

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
        [self _handleErrorNumberValidationWithError:error];
    }];
}


- (void)_handleErrorNumberValidationWithError:(NSError*)error
{
    
    if ([self.output isNetworkEnabled])
    {
        if (!ANIsEmpty([ZZStoredSettingsManager shared].mobileNumber))
        {
            
            NSError* mobilePhoneError = [NSError errorWithDomain:kErrorDomainWrongMobileType code:kErrorWrongMobileErrorCode userInfo:nil];
            [self.output registrationDidFailWithError:mobilePhoneError];
        }
        else
        {
            [self.output registrationDidFailWithError:error];
        }
    }
    else
    {
        [self.output registrationDidFailWithError:error];
    }
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

- (void)_saveAuthenticatedUserMobileNumberToDefauts:(NSString*)number
{
    NSString* numberWithPlus = [NSString stringWithFormat:@"+%@", number];
    [ZZStoredSettingsManager shared].mobileNumber = numberWithPlus;
    [[NSUserDefaults standardUserDefaults] setObject:numberWithPlus forKey:@"authenticatedMobileNumber"]; //TODO: stored manager
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

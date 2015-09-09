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
#import "TBMDispatch.h"
#import "ZZFriendDataProvider.h"
#import "TBMUser.h"
#import "TBMFriend.h"
#import "TBMS3CredentialsManager.h"

@interface ZZAuthInteractor ()

@property (nonatomic, strong) ZZUserDomainModel *currentUser;

@end

@implementation ZZAuthInteractor

- (void)loadUserData
{
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
    
#ifdef DEBUG_LOGIN_USER
    user.firstName = @"Ol";
    user.lastName = @"P";
    user.mobileNumber = @"+380930880008";
#endif
    
    if (!ANIsEmpty(user.mobileNumber))
    {
        NSError* error;
        NBPhoneNumber *phoneNumber = [[NBPhoneNumberUtil new] parse:user.mobileNumber defaultRegion:@"US" error:&error];
        if (!error)
        {
            user.countryCode = [phoneNumber.countryCode stringValue];
            user.plainPhoneNumber = [phoneNumber.nationalNumber stringValue];
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
        user.isRegistered = YES; // TODO: check server fields
        [ZZUserDataProvider upsertUserWithModel:user];
        
        [TBMDispatch updateRollBarUserWithItemID:user.idTbm username:[user fullName] phoneNumber:user.mobileNumber];
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
        
        [self gotFriends:x];
        [self detectInvitee:x];
        [self.output loadedFriendsSuccessfully];
        
        [self loadS3Credentials];
        
    } error:^(NSError *error) {
        
        [self.output loadFriendsDidFailWithError:error];
    }];
}

- (void)loadS3Credentials
{
    [TBMS3CredentialsManager refreshFromServer:^void (BOOL success){
        if (success)
        {
            self.currentUser.isRegistered = YES;
            [ZZUserDataProvider upsertUserWithModel:self.currentUser];
            [self.output registrationFlowCompletedSuccessfully];
        }
        else
        {
            [self.output loadS3CredentialsDidFailWithError:nil]; // TODO: create an error here
        }
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
    if (ANIsEmpty(region))
    {
        region = [self countryCodeFromPhoneSettings];
    }
    
    NSError *error;
    NBPhoneNumber* phoneNumber = [numberUtils parse:phone defaultRegion:[self countryCodeFromPhoneSettings] error:&error];
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
    for (NSDictionary *fParams in friends)
    {
        [TBMFriend createOrUpdateWithServerParams:fParams complete:nil];
    }
}

- (void)detectInvitee:(NSArray *)friends
{
    NSArray *sorted = [self sortedFriendsByCreatedOn:friends];
    if (sorted)
    {
        NSDictionary *firstFriend = sorted.firstObject;
        NSString *firstFriendCreatorMkey = firstFriend[@"connection_creator_mkey"];
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

@end

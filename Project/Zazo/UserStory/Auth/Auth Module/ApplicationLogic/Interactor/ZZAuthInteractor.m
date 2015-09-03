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

@interface ZZAuthInteractor ()

@property (nonatomic, strong) ZZUserDomainModel *currentUser;

@end

@implementation ZZAuthInteractor

- (void)loadUserData
{
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
    
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
        self.currentUser = model;
        [self registerUserWithModel:model];
    }
    else
    {
        [self.output validationDidFailWithError:validationError];
    }
}

- (void)validateSMSCode:(NSString*)code
{
    [[ZZAccountTransportService registerUserFromModel:self.currentUser withVerificationCode:code] subscribeNext:^(NSDictionary *dict) {
        ZZUserDomainModel *user = [FEMObjectDeserializer deserializeObjectExternalRepresentation:dict usingMapping:[ZZUserDomainModel mapping]];
        user.isRegistered = YES;
        //[ZZUserDataProvider upsertUserWithModel:user];
        
        //        [self loadFriendsFromServer];
        
        [self.output smsCodeValidationCompletedSuccessfully];
        
    } error:^(NSError *error) {
        [self.output smsCodeValidationCompletedWithError:error];
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

- (void)registerUserWithModel:(ZZUserDomainModel *)user
{
    [[ZZAccountTransportService registerUserWithModel:user] subscribeNext:^(NSDictionary *authKeys) {
        
        NSString *auth = [authKeys objectForKey:@"auth"];
        NSString *mkey = [authKeys objectForKey:@"mkey"];
        
        [ZZStoredSettingsManager shared].userID = mkey;
        [ZZStoredSettingsManager shared].authToken = auth;

        [self.output registrationCompletedSuccessfullyWithPhoneNumber:user.mobileNumber];
        
    } error:^(NSError *error) {
        [self.output registrationDidFailWithError:error];
    }];
}

- (void)loadFriendsFromServer
{
    //TODO:
//    [[ZZFriendsTransportService loadFriendList] subscribeNext:^(NSArray *friendArray) {
//        
//    } error:^(NSError *error) {
//        
//    }];
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

@end

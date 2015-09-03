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

@interface ZZAuthInteractor ()

@property (nonatomic, strong) ZZUserDomainModel *currentUser;

@end

@implementation ZZAuthInteractor

- (void)registrationWithFirstName:(NSString*)firstName
                         lastName:(NSString*)lastName
                      countryCode:(NSString*)countryCode
                            phone:(NSString*)phoneNumber
{
    ZZUserDomainModel* model = [ZZUserDomainModel new];
    model.firstName = firstName;
    model.lastName = lastName;
    model.mobileNumber = [NSString stringWithFormat:@"%@%@",[NSObject an_safeString:countryCode], [NSObject an_safeString:phoneNumber]];
    NSError* validationError = [self _validateUserModel:model countryCode:countryCode phoneNumber:phoneNumber];
    
    if (!validationError)
    {
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
        [self.output presentGridModule];
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

        [self.output authDataRecievedForNumber:user.mobileNumber];
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

- (NSError*)_validateUserModel:(ZZUserDomainModel*)model countryCode:(NSString*)countryCode phoneNumber:(NSString*)phoneNumber
{
    NSError* error;

    if (ANIsEmpty(model.firstName))
    {
        return [ANErrorBuilder errorWithType:ANErrorTypeGeneral
                                        code:kFormEmptyRequiredFieldFirstName
                         descriptionArgument:NSLocalizedString(@"auth-controller.firstname.placeholder.title",nil)];
    }

    if (ANIsEmpty(model.lastName))
    {
        return [ANErrorBuilder errorWithType:ANErrorTypeGeneral
                                        code:kFormEmptyRequiredFieldLastName
                         descriptionArgument:NSLocalizedString(@"auth-controller.lastname.placeholder.title",nil)];
    }

    if (ANIsEmpty(countryCode))
    {
        return [ANErrorBuilder errorWithType:ANErrorTypeGeneral
                                        code:kFormEmptyRequiredFieldCountryCode
                         descriptionArgument:NSLocalizedString(@"auth-controller.country.code.title", nil)];
    }
    
    if (ANIsEmpty(phoneNumber))
    {
        return [ANErrorBuilder errorWithType:ANErrorTypeGeneral
                                        code:kFormEmptyRequiredFieldMobilePhoneNumber
                         descriptionArgument:NSLocalizedString(@"auth-controller.phone.placeholder.title", nil)];
    }
    
    if (![self _isValidPhone:model.mobileNumber code:countryCode])
    {
        return [ANErrorBuilder errorWithType:ANErrorTypeGeneral
                                                code:kFormInvalidModilePhone
                         descriptionArgument:NSLocalizedString(@"auth-controller.phone.placeholder.title", nil)]; //TODO: correct title
    }
    return error;
}

- (BOOL)_isValidPhone:(NSString*)phone code:(NSString*)code
{
     NBPhoneNumberUtil *numberUtils = [NBPhoneNumberUtil new];
    
    //get default code by region
    
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

@end

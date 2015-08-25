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
#import "ANGeneralErrorConstants.h"
#import <NBPhoneNumberUtil.h>
#import "ZZAccountTransportService.h"
#import "FEMObjectDeserializer.h"
#import "ZZUserDataProvider.h"
#import "ZZFriendsTransportService.h"

typedef NS_ENUM(NSInteger, ZZTextFieldType)
{
    ZZFirstNameType = 1,
    ZZLastNameType,
    ZZCountryCodeType,
    ZZPhoneNumberType
};

@interface ZZAuthInteractor ()

@property (nonatomic, strong) ZZUserDomainModel *currentUser;

@end
@implementation ZZAuthInteractor

- (void)registrationWithFirstName:(NSString *)firstfName
                     withLastName:(NSString *)lastName
                  withCountryCode:(NSString *)countryCode
                  withPhoneNumber:(NSString *)phoneNumber
{
    if ([self isTextValidWith:firstfName withTextFieldType:ZZFirstNameType] &&
        [self isTextValidWith:lastName withTextFieldType:ZZLastNameType] &&
        [self isTextValidWith:countryCode withTextFieldType:ZZCountryCodeType] &&
        [self isTextValidWith:phoneNumber withTextFieldType:ZZPhoneNumberType] &&
        [self isValidPhone:[NSString stringWithFormat:@"%@%@",countryCode,phoneNumber]])
    {
        ZZUserDomainModel* userModel = [ZZUserDomainModel new];
        userModel.firstName = firstfName;
        userModel.lastName = lastName;
        userModel.mobileNumber = [NSString stringWithFormat:@"%@%@",countryCode,phoneNumber];
        
        self.currentUser = userModel;
        
        [self registerUserWithModel:userModel];
    }
}

- (void)continueRegistrationWithSMSCode:(NSString *)code
{
    [[ZZAccountTransportService registerUserFromModel:self.currentUser withVerificationCode:code] subscribeNext:^(NSDictionary *dict)
    {
        ZZUserDomainModel *user = [FEMObjectDeserializer deserializeObjectExternalRepresentation:dict usingMapping:[ZZUserDomainModel mapping]];
        user.isRegistered = YES;
        //[ZZUserDataProvider upsertUserWithModel:user];
        
        [self loadFriendsFromServer];
    }];
}

#pragma mark - ZZAccountTransportService

- (void)registerUserWithModel:(ZZUserDomainModel *)user
{
    [[ZZAccountTransportService registerUserWithModel:user] subscribeNext:^(NSDictionary *authKeys) {
        
        NSString *auth = [authKeys objectForKey:@"auth"];
        NSString *mkey = [authKeys objectForKey:@"mkey"];
        [[NSUserDefaults standardUserDefaults] setObject:auth forKey:@"auth"];
        [[NSUserDefaults standardUserDefaults] setObject:mkey forKey:@"mkey"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self.output authDataRecievedForNumber:user.mobileNumber];
    }];
}

- (void)loadFriendsFromServer
{
    [[ZZFriendsTransportService loadFriendList] subscribeNext:^(NSArray *friendArray) {
        
    } error:^(NSError *error) {
        
    }];
}

#pragma mark - Validation Part

- (BOOL)isTextValidWith:(NSString *)text withTextFieldType:(NSInteger)textFieldType
{
    BOOL isValid = YES;
    if (ANIsEmpty(text))
    {
        NSError* error = [ANErrorBuilder errorWithType:ANErrorTypeGeneral
                                                  code:kFormEmptyRequiredField
                                   descriptionArgument:[self errorStringWithTypeCode:textFieldType]];
        [self.output validationDidFailWithError:error];
        isValid = NO;
    }
    return isValid;
}

- (NSString *)errorStringWithTypeCode:(NSInteger)code
{
    NSString* errorMessage;
    switch (code) {
        case ZZFirstNameType:
            errorMessage =
            NSLocalizedString(@"auth-controller.firstname.placeholder.title",nil);
            break;
        case ZZLastNameType:
            errorMessage =
            NSLocalizedString(@"auth-controller.lastname.placeholder.title", nil);
            break;
        case ZZCountryCodeType:
            errorMessage = NSLocalizedString(@"auth-controller.country.code.title", nil);
            break;
        case ZZPhoneNumberType:
            errorMessage = NSLocalizedString(@"auth-controller.phone.placeholder.title", nil);
            break;
        default:
            break;
    }
    return errorMessage;
}


- (BOOL)isValidPhone:(NSString *)phone
{
    NBPhoneNumberUtil *numberUtils = [[NBPhoneNumberUtil alloc] init];
    NSError *error;
    NBPhoneNumber *pn = [numberUtils parse:phone defaultRegion:[self countryCodeFromPhoneSettings] error:&error];
    if (error == nil){
        if ([numberUtils isValidNumber:pn]){
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

- (NSString*)countryCodeFromPhoneSettings
{
    NSString* code = [self countryCodeByCarrier];
    if (!code.length)
    {
        code = [self countryCodeForCurrentLocale];
    }
    return code;
}

- (NSString*)countryCodeByCarrier
{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *isoCode = [[networkInfo subscriberCellularProvider] isoCountryCode];
    if (!isoCode)
    {
        isoCode = @"";
    }
    return isoCode;
}

- (NSString*)countryCodeForCurrentLocale
{
    NSLocale *loc = [NSLocale currentLocale];
    return [[loc objectForKey:NSLocaleCountryCode] lowercaseString];
}

@end

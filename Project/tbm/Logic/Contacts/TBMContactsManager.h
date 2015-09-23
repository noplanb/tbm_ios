//
//  TBMContactsManager.h
//  tbm
//
//  Created by Sani Elfishawy on 11/12/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

static const NSString * kContactsManagerFirstNameKey = @"firstName";
static const NSString * kContactsManagerLastNameKey = @"lastName";
static const NSString * kContactsManagerPhoneTypeKey = @"phoneType";
static const NSString * kContactsManagerPhoneNumberKey = @"phoneNumber";
static const NSString * kContactsManagerPhonesSetKey = @"phonesSet";
static const NSString * kContactsManagerPhonesArrayKey = @"phonesArray";


@interface TBMContactsManager : NSObject
// Instantiation (singleton)
+ (instancetype)sharedInstance;

// Public methods
- (void)prefetchOnlyIfHasAccess;
- (NSArray *) getFullNamesHavingAnyPhone;
- (NSDictionary *)contactWithFullname:(NSString *)fullname;
- (NSArray*)fullnamesMatchingSubstr:(NSString *)str limit:(int)limit;
@end
